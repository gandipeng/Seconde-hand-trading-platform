package com.minzu.servlet;

import com.minzu.entity.Product;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/product-detail")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = (User) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String productIdStr = request.getParameter("id");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            request.setAttribute("errorMsg", "商品ID不能为空");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            request.setAttribute("errorMsg", "商品ID格式错误");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        String sql =
                "SELECT p.product_id, p.seller_id, u.real_name AS seller_name, " +
                "p.category_id, c.category_name, p.title, p.product_desc, " +
                "p.price, p.original_price, p.condition_level, p.cover_image_url, " +
                "p.publish_status, p.view_count, p.favorite_count, p.created_at " +
                "FROM products p " +
                "LEFT JOIN users u ON p.seller_id = u.user_id " +
                "LEFT JOIN categories c ON p.category_id = c.category_id " +
                "WHERE p.product_id = ? AND p.is_deleted = 0";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSellerId(rs.getInt("seller_id"));
                    p.setSellerName(rs.getString("seller_name"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setTitle(rs.getString("title"));
                    p.setDescription(rs.getString("product_desc"));
                    p.setPrice(rs.getBigDecimal("price"));
                    p.setOriginalPrice(rs.getBigDecimal("original_price"));
                    p.setConditionLevel(rs.getString("condition_level"));
                    p.setCoverImageUrl(rs.getString("cover_image_url"));
                    p.setProductStatus(rs.getString("publish_status"));
                    p.setViewCount(rs.getInt("view_count"));
                    p.setFavoriteCount(rs.getInt("favorite_count"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));

                    // ① 浏览量 +1
                    try (PreparedStatement viewPs = conn.prepareStatement(
                            "UPDATE products SET view_count = view_count + 1 WHERE product_id = ?")) {
                        viewPs.setInt(1, productId);
                        viewPs.executeUpdate();
                        // 同步到内存对象，页面显示不会偏低 1
                        p.setViewCount(p.getViewCount() + 1);
                    }

                    // ② 查询详情图列表
                    List<String> detailImages = new ArrayList<>();
                    String imageSql = "SELECT image_url FROM product_images " +
                            "WHERE product_id = ? ORDER BY sort_order ASC, image_id ASC";
                    try (PreparedStatement imagePs = conn.prepareStatement(imageSql)) {
                        imagePs.setInt(1, productId);
                        try (ResultSet imageRs = imagePs.executeQuery()) {
                            while (imageRs.next()) {
                                detailImages.add(imageRs.getString("image_url"));
                            }
                        }
                    }

                    // ③ 查询当前登录用户是否已收藏该商品
                    boolean isFavorited = false;
                    String favSql = "SELECT 1 FROM favorites WHERE user_id = ? AND product_id = ?";
                    try (PreparedStatement favPs = conn.prepareStatement(favSql)) {
                        favPs.setInt(1, loginUser.getUserId());
                        favPs.setInt(2, productId);
                        try (ResultSet favRs = favPs.executeQuery()) {
                            isFavorited = favRs.next();
                        }
                    }

                    request.setAttribute("product", p);
                    request.setAttribute("detailImages", detailImages);
                    request.setAttribute("isFavorited", isFavorited);
                    request.getRequestDispatcher("/product-detail.jsp").forward(request, response);

                } else {
                    request.setAttribute("errorMsg", "商品不存在或已下架");
                    request.getRequestDispatcher("/error.jsp").forward(request, response);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "获取商品详情失败：" + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
}
