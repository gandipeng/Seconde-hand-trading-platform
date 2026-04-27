package com.minzu.servlet;

import com.minzu.entity.Product;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/**
 * /favorite          POST  -> 收藏 / 取消收藏（AJAX，返回 JSON）
 * /my-favorites      GET   -> 我的收藏列表页
 */
@WebServlet(urlPatterns = {"/favorite", "/my-favorites"})
public class FavoriteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String uri = request.getRequestURI();
        if (uri.endsWith("/my-favorites")) {
            showFavoriteList(request, response, loginUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/my-favorites");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");

        PrintWriter out = response.getWriter();

        if (loginUser == null) {
            out.print("{\"success\":false,\"msg\":\"请先登录\",\"needLogin\":true}");
            return;
        }

        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            out.print("{\"success\":false,\"msg\":\"参数错误\"}");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"msg\":\"参数错误\"}");
            return;
        }

        int userId = loginUser.getUserId();

        try (Connection conn = DBUtil.getConnection()) {

            // 1. 查询是否已收藏
            String checkSql = "SELECT favorite_id FROM favorites WHERE user_id=? AND product_id=?";
            boolean alreadyFav = false;
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    alreadyFav = rs.next();
                }
            }

            if (alreadyFav) {
                // 2a. 取消收藏
                String delSql = "DELETE FROM favorites WHERE user_id=? AND product_id=?";
                try (PreparedStatement ps = conn.prepareStatement(delSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, productId);
                    ps.executeUpdate();
                }
                // 更新商品收藏计数
                updateFavoriteCount(conn, productId, -1);

                int newCount = getFavoriteCount(conn, productId);
                out.print("{\"success\":true,\"favorited\":false,\"count\":" + newCount + "}");

            } else {
                // 2b. 添加收藏
                String insSql = "INSERT INTO favorites (user_id, product_id, created_at) VALUES (?,?,NOW())";
                try (PreparedStatement ps = conn.prepareStatement(insSql)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, productId);
                    ps.executeUpdate();
                }
                updateFavoriteCount(conn, productId, 1);

                int newCount = getFavoriteCount(conn, productId);
                out.print("{\"success\":true,\"favorited\":true,\"count\":" + newCount + "}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"msg\":\"服务器异常：" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    // ---- 我的收藏列表 ----
    private void showFavoriteList(HttpServletRequest request, HttpServletResponse response,
                                  User loginUser) throws ServletException, IOException {
        String sql =
            "SELECT p.product_id, p.title, p.price, p.original_price, " +
            "       p.cover_image_url, p.publish_status, p.view_count, p.favorite_count, " +
            "       p.created_at, c.category_name, u.nickname AS seller_name, " +
            "       f.created_at AS favorited_at " +
            "FROM favorites f " +
            "JOIN products p ON p.product_id = f.product_id " +
            "LEFT JOIN categories c ON c.category_id = p.category_id " +
            "LEFT JOIN users u ON u.user_id = p.seller_id " +
            "WHERE f.user_id = ? " +
            "ORDER BY f.created_at DESC";

        List<Product> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setTitle(rs.getString("title"));
                    p.setPrice(rs.getBigDecimal("price"));
                    BigDecimal op = rs.getBigDecimal("original_price");
                    p.setOriginalPrice(op);
                    p.setCoverImageUrl(rs.getString("cover_image_url"));
                    p.setProductStatus(rs.getString("publish_status"));
                    p.setViewCount(rs.getInt("view_count"));
                    p.setFavoriteCount(rs.getInt("favorite_count"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setSellerName(rs.getString("seller_name"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("favoriteList", list);
        request.getRequestDispatcher("/my-favorites.jsp").forward(request, response);
    }

    private void updateFavoriteCount(Connection conn, int productId, int delta) throws SQLException {
        String sql = "UPDATE products SET favorite_count = GREATEST(0, favorite_count + ?) WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, delta);
            ps.setInt(2, productId);
            ps.executeUpdate();
        }
    }

    private int getFavoriteCount(Connection conn, int productId) throws SQLException {
        String sql = "SELECT favorite_count FROM products WHERE product_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }
}
