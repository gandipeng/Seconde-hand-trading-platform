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

@WebServlet("/my-products")
public class MyProductsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String statusFilter = request.getParameter("status");

        StringBuilder sql = new StringBuilder(
                "SELECT p.product_id, p.seller_id, p.title, p.price, p.original_price, " +
                "p.condition_level, p.cover_image_url, p.publish_status, p.view_count, " +
                "p.favorite_count, p.created_at, c.category_name " +
                "FROM products p " +
                "LEFT JOIN categories c ON p.category_id = c.category_id " +
                "WHERE p.seller_id = ? AND IFNULL(p.is_deleted, 0) = 0"
        );

        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND p.publish_status = ?");
        }
        sql.append(" ORDER BY p.created_at DESC");

        List<Product> productList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            ps.setInt(1, loginUser.getUserId());
            if (statusFilter != null && !statusFilter.trim().isEmpty()) {
                ps.setString(2, statusFilter.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSellerId(rs.getInt("seller_id"));
                    p.setTitle(rs.getString("title"));
                    p.setPrice(rs.getBigDecimal("price"));
                    p.setOriginalPrice(rs.getBigDecimal("original_price"));
                    p.setConditionLevel(rs.getString("condition_level"));
                    p.setCoverImageUrl(rs.getString("cover_image_url"));
                    p.setProductStatus(rs.getString("publish_status"));
                    p.setViewCount(rs.getInt("view_count"));
                    p.setFavoriteCount(rs.getInt("favorite_count"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setCategoryName(rs.getString("category_name"));
                    productList.add(p);
                }
            }

            request.setAttribute("productList", productList);
            request.setAttribute("statusFilter", statusFilter);
            request.getRequestDispatcher("/my-products.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载失败：" + e.getMessage());
            request.getRequestDispatcher("/my-products.jsp").forward(request, response);
        }
    }

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

        String action = request.getParameter("action");
        String productIdStr = request.getParameter("productId");

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

        if ("offshelf".equals(action)) {
            updateStatus(request, response, loginUser.getUserId(), productId,
                    "ON_SALE", "OFF_SHELF", "商品已下架");
        } else if ("onshelf".equals(action)) {
            updateStatus(request, response, loginUser.getUserId(), productId,
                    "OFF_SHELF", "ON_SALE", "商品已重新上架");
        } else {
            response.sendRedirect(request.getContextPath() + "/my-products");
        }
    }

    private void updateStatus(HttpServletRequest request, HttpServletResponse response,
                              int loginUserId, int productId, String fromStatus,
                              String newStatus, String successMsg) throws IOException {

        String sql = "UPDATE products SET publish_status = ?, updated_at = NOW() " +
                "WHERE product_id = ? AND seller_id = ? AND publish_status = ? " +
                "AND IFNULL(is_deleted, 0) = 0";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, productId);
            ps.setInt(3, loginUserId);
            ps.setString(4, fromStatus);
            int rows = ps.executeUpdate();

            if (rows > 0) {
                request.getSession().setAttribute("successMsg", successMsg);
            } else {
                request.getSession().setAttribute("errorMsg", "操作失败，商品状态可能已变更");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/my-products");
    }
}
