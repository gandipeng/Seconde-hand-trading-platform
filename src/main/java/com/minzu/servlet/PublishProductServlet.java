package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@WebServlet("/publish-product")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 50 * 1024 * 1024
)
public class PublishProductServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "D:/uploads/minzu-secondhand";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = (User) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String sql = "SELECT category_id, category_name FROM categories ORDER BY category_id";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<java.util.Map<String, Object>> categories = new ArrayList<>();
            while (rs.next()) {
                java.util.Map<String, Object> map = new java.util.HashMap<>();
                map.put("categoryId", rs.getInt("category_id"));
                map.put("categoryName", rs.getString("category_name"));
                categories.add(map);
            }
            request.setAttribute("categories", categories);
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.getRequestDispatcher("/publish-product.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User loginUser = (User) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        String originalPriceStr = request.getParameter("originalPrice");
        String conditionLevel = request.getParameter("conditionLevel");
        String categoryIdStr = request.getParameter("categoryId");

        Part coverPart = request.getPart("coverImage");
        List<Part> detailImageParts = new ArrayList<>();
        for (Part part : request.getParts()) {
            if ("detailImages".equals(part.getName()) && part.getSize() > 0) {
                detailImageParts.add(part);
            }
        }

        if (title == null || title.trim().isEmpty()
                || priceStr == null || priceStr.trim().isEmpty()
                || conditionLevel == null || conditionLevel.trim().isEmpty()
                || categoryIdStr == null || categoryIdStr.trim().isEmpty()
                || coverPart == null || coverPart.getSize() == 0) {
            request.setAttribute("errorMsg", "请填写完整信息并上传封面图");
            doGet(request, response);
            return;
        }

        BigDecimal price;
        BigDecimal originalPrice = null;
        int categoryId;

        try {
            price = new BigDecimal(priceStr.trim());
            if (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) {
                originalPrice = new BigDecimal(originalPriceStr.trim());
            }
            categoryId = Integer.parseInt(categoryIdStr.trim());
        } catch (Exception e) {
            request.setAttribute("errorMsg", "价格或分类格式有误");
            doGet(request, response);
            return;
        }

        File uploadDir = new File(UPLOAD_DIR);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        Connection conn = null;
        PreparedStatement psProduct = null;
        PreparedStatement psImage = null;
        ResultSet generatedKeys = null;

        try {
            String coverImageUrl = saveFile(coverPart, UPLOAD_DIR, request);

            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String insertProductSql =
                    "INSERT INTO products " +
                            "(seller_id, category_id, title, product_desc, price, original_price, " +
                            "condition_level, cover_image_url, publish_status, " +
                            "is_textbook_zone, is_graduation_zone, view_count, favorite_count, is_deleted, created_at, updated_at) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PENDING_REVIEW', 0, 0, 0, 0, 0, NOW(), NOW())";

            psProduct = conn.prepareStatement(insertProductSql, Statement.RETURN_GENERATED_KEYS);
            psProduct.setInt(1, loginUser.getUserId());
            psProduct.setInt(2, categoryId);
            psProduct.setString(3, title.trim());
            psProduct.setString(4, description != null ? description.trim() : "");
            psProduct.setBigDecimal(5, price);

            if (originalPrice != null) {
                psProduct.setBigDecimal(6, originalPrice);
            } else {
                psProduct.setNull(6, Types.DECIMAL);
            }

            psProduct.setString(7, conditionLevel);
            psProduct.setString(8, coverImageUrl);

            psProduct.executeUpdate();

            generatedKeys = psProduct.getGeneratedKeys();
            long productId = 0;
            if (generatedKeys.next()) {
                productId = generatedKeys.getLong(1);
            } else {
                throw new RuntimeException("发布失败：未获取到商品ID");
            }

            String insertImageSql =
                    "INSERT INTO product_images (product_id, image_url, sort_order, created_at) " +
                            "VALUES (?, ?, ?, NOW())";

            psImage = conn.prepareStatement(insertImageSql);

            int sortOrder = 1;
            for (Part part : detailImageParts) {
                String imageUrl = saveFile(part, UPLOAD_DIR, request);
                psImage.setLong(1, productId);
                psImage.setString(2, imageUrl);
                psImage.setInt(3, sortOrder++);
                psImage.addBatch();
            }

            psImage.executeBatch();
            conn.commit();
            request.getSession().setAttribute("successMsg", "商品已提交审核，请等待管理员处理");
            response.sendRedirect(request.getContextPath() + "/my-products");

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            request.setAttribute("errorMsg", "发布失败：" + e.getMessage());
            doGet(request, response);
        } finally {
            try { if (generatedKeys != null) generatedKeys.close(); } catch (Exception ignored) {}
            try { if (psImage != null) psImage.close(); } catch (Exception ignored) {}
            try { if (psProduct != null) psProduct.close(); } catch (Exception ignored) {}
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (Exception ignored) {}
        }
    }

    private String saveFile(Part part, String uploadPath, HttpServletRequest request) throws Exception {
        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) return null;
        String ext = "";
        int dotIndex = submittedFileName.lastIndexOf(".");
        if (dotIndex != -1) ext = submittedFileName.substring(dotIndex);
        String newFileName = UUID.randomUUID().toString().replace("-", "") + ext;
        part.write(uploadPath + File.separator + newFileName);
        return request.getContextPath() + "/uploads/" + newFileName;
    }
}
