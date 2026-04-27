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

@WebServlet("/product-list")
public class ProductListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = null;
        HttpSession session = request.getSession(false);
        if (session != null) {
            loginUser = (User) session.getAttribute("loginUser");
        }

        String keyword     = request.getParameter("keyword");
        String categoryIdStr = request.getParameter("categoryId");

        // 分页
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr.trim()));
        } catch (NumberFormatException ignored) {}

        // 拼装 WHERE 条件
        StringBuilder where = new StringBuilder("WHERE p.publish_status = 'ON_SALE' AND p.is_deleted = 0");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" AND p.title LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            where.append(" AND p.category_id = ?");
            params.add(Integer.parseInt(categoryIdStr));
        }

        // 总数查询
        String countSql = "SELECT COUNT(*) FROM products p " + where;
        int totalCount = 0;
        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(countSql)
        ) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCount = rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }

        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PAGE_SIZE;

        String sql = "SELECT p.product_id, p.seller_id, u.real_name AS seller_name, " +
                "p.category_id, c.category_name, p.title, p.product_desc, " +
                "p.price, p.condition_level, p.publish_status, p.cover_image_url, p.created_at " +
                "FROM products p " +
                "LEFT JOIN users u ON p.seller_id = u.user_id " +
                "LEFT JOIN categories c ON p.category_id = c.category_id " +
                where + " ORDER BY p.created_at DESC LIMIT ? OFFSET ?";

        List<Product> products = new ArrayList<>();

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            int idx = 1;
            for (Object p : params) ps.setObject(idx++, p);
            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx,   offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSellerId(rs.getInt("seller_id"));
                    p.setSellerName(rs.getString("seller_name"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setTitle(rs.getString("title"));
                    p.setDescription(rs.getString("product_desc"));
                    p.setPrice(rs.getBigDecimal("price"));
                    p.setConditionLevel(rs.getString("condition_level"));
                    p.setProductStatus(rs.getString("publish_status"));
                    p.setCoverImageUrl(rs.getString("cover_image_url"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    products.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "获取商品列表失败：" + e.getMessage());
        }

        request.setAttribute("products",    products);
        request.setAttribute("loginUser",   loginUser);
        request.setAttribute("keyword",     keyword);
        request.setAttribute("categoryId",  categoryIdStr);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages",  totalPages);
        request.setAttribute("totalCount",  totalCount);
        request.getRequestDispatcher("/product-list.jsp").forward(request, response);
    }
}
