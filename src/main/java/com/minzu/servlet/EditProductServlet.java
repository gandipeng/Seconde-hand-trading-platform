package com.minzu.servlet;

import com.minzu.entity.Product;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/edit-product")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 50 * 1024 * 1024
)
public class EditProductServlet extends HttpServlet {

    // GET：显示编辑页，回填商品现有数据
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String productIdStr = request.getParameter("id");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/my-products");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/my-products");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {

            // fix: product_status → publish_status（与数据库字段一致）
            String sql = "SELECT p.product_id, p.seller_id, p.category_id, p.title, p.product_desc, " +
                    "p.price, p.original_price, p.condition_level, p.cover_image_url, p.publish_status " +
                    "FROM products p " +
                    "WHERE p.product_id = ? AND p.seller_id = ? AND IFNULL(p.is_deleted,0) = 0";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, productId);
                ps.setInt(2, loginUser.getUserId());

                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        request.getSession().setAttribute("errorMsg", "找不到商品，或您无权编辑该商品");
                        response.sendRedirect(request.getContextPath() + "/my-products");
                        return;
                    }

                    Product product = new Product();
                    product.setProductId(rs.getInt("product_id"));
                    product.setSellerId(rs.getInt("seller_id"));
                    product.setCategoryId(rs.getInt("category_id"));
                    product.setTitle(rs.getString("title"));
                    product.setDescription(rs.getString("product_desc"));
                    product.setPrice(rs.getBigDecimal("price"));
                    product.setOriginalPrice(rs.getBigDecimal("original_price"));
                    product.setConditionLevel(rs.getString("condition_level"));
                    product.setCoverImageUrl(rs.getString("cover_image_url"));
                    // fix: 读取字段名同步修正为 publish_status
                    product.setProductStatus(rs.getString("publish_status"));

                    request.setAttribute("product", product);
                }
            }

            // 查询分类列表
            String catSql = "SELECT category_id, category_name FROM categories ORDER BY category_id";
            try (PreparedStatement ps2 = conn.prepareStatement(catSql);
                 ResultSet rs2 = ps2.executeQuery()) {
                List<Map<String, Object>> categories = new ArrayList<>();
                while (rs2.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("categoryId", rs2.getInt("category_id"));
                    map.put("categoryName", rs2.getString("category_name"));
                    categories.add(map);
                }
                request.setAttribute("categories", categories);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "加载商品失败：" + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/my-products");
            return;
        }

        request.getRequestDispatcher("/edit-product.jsp").forward(request, response);
    }

    // POST：处理更新
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String productIdStr = request.getParameter("productId");
        String title        = request.getParameter("title");
        String description  = request.getParameter("description");
        String priceStr     = request.getParameter("price");
        String originalPriceStr = request.getParameter("originalPrice");
        String conditionLevel   = request.getParameter("conditionLevel");
        String categoryIdStr    = request.getParameter("categoryId");

        if (productIdStr == null || title == null || title.trim().isEmpty()
                || priceStr == null || priceStr.trim().isEmpty()
                || conditionLevel == null || conditionLevel.trim().isEmpty()
                || categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            request.getSession().setAttribute("errorMsg", "请填写完整信息");
            response.sendRedirect(request.getContextPath() + "/edit-product?id=" + productIdStr);
            return;
        }

        int productId;
        BigDecimal price;
        BigDecimal originalPrice = null;
        int categoryId;

        try {
            productId  = Integer.parseInt(productIdStr.trim());
            price      = new BigDecimal(priceStr.trim());
            categoryId = Integer.parseInt(categoryIdStr.trim());
            if (originalPriceStr != null && !originalPriceStr.trim().isEmpty()) {
                originalPrice = new BigDecimal(originalPriceStr.trim());
            }
        } catch (Exception e) {
            request.getSession().setAttribute("errorMsg", "价格或分类格式有误");
            response.sendRedirect(request.getContextPath() + "/edit-product?id=" + productIdStr);
            return;
        }

        // 处理封面图（可选，不上传则保留原图）
        String uploadPath = getServletContext().getRealPath("/") + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String newCoverImageUrl = null;
        try {
            Part coverPart = request.getPart("coverImage");
            if (coverPart != null && coverPart.getSize() > 0) {
                newCoverImageUrl = saveFile(coverPart, uploadPath, request);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();

            // 加载当前商品（验证归属权）
            String checkSql = "SELECT cover_image_url FROM products " +
                    "WHERE product_id = ? AND seller_id = ? AND IFNULL(is_deleted,0)=0";
            String currentCover = null;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, productId);
                ps.setInt(2, loginUser.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        request.getSession().setAttribute("errorMsg", "找不到商品或无权编辑");
                        response.sendRedirect(request.getContextPath() + "/my-products");
                        return;
                    }
                    currentCover = rs.getString("cover_image_url");
                }
            }

            // 如果没有上传新封面，保留原图
            String finalCover = (newCoverImageUrl != null) ? newCoverImageUrl : currentCover;

            String updateSql = "UPDATE products SET " +
                    "category_id=?, title=?, product_desc=?, price=?, original_price=?, " +
                    "condition_level=?, cover_image_url=?, updated_at=NOW() " +
                    "WHERE product_id=? AND seller_id=? AND IFNULL(is_deleted,0)=0";

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setInt(1, categoryId);
                ps.setString(2, title.trim());
                ps.setString(3, description != null ? description.trim() : "");
                ps.setBigDecimal(4, price);
                if (originalPrice != null) {
                    ps.setBigDecimal(5, originalPrice);
                } else {
                    ps.setNull(5, Types.DECIMAL);
                }
                ps.setString(6, conditionLevel);
                ps.setString(7, finalCover);
                ps.setInt(8, productId);
                ps.setInt(9, loginUser.getUserId());

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    request.getSession().setAttribute("successMsg", "商品信息已更新");
                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                } else {
                    request.getSession().setAttribute("errorMsg", "更新失败，请重试");
                    response.sendRedirect(request.getContextPath() + "/edit-product?id=" + productId);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "更新失败：" + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/edit-product?id=" + productId);
        } finally {
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }

    private String saveFile(Part part, String uploadPath, HttpServletRequest request) throws Exception {
        String submittedFileName = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        if (submittedFileName == null || submittedFileName.trim().isEmpty()) return null;
        String ext = "";
        int dot = submittedFileName.lastIndexOf(".");
        if (dot != -1) ext = submittedFileName.substring(dot);
        String newFileName = UUID.randomUUID().toString().replace("-", "") + ext;
        part.write(uploadPath + File.separator + newFileName);
        return request.getContextPath() + "/uploads/" + newFileName;
    }
}
