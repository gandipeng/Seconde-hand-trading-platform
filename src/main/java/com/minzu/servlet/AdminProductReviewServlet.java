package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /admin/products
 *   GET  -> 待审核商品列表 (admin-product-review.jsp)
 *   POST action=approve|reject  productId=xx
 */
@WebServlet("/admin/products")
public class AdminProductReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getAdminUser(req, resp);
        if (loginUser == null) return;

        String tab = req.getParameter("tab");
        if (tab == null) tab = "pending";

        String statusFilter;
        switch (tab) {
            case "on_sale":  statusFilter = "ON_SALE";       break;
            case "rejected": statusFilter = "REJECTED";      break;
            default:         statusFilter = "PENDING_REVIEW"; tab = "pending"; break;
        }

        String sql =
            "SELECT p.product_id, p.title, p.price, p.publish_status, p.created_at, " +
            "p.cover_image_url, p.condition_level, c.category_name, " +
            "u.real_name AS seller_name, u.student_or_staff_no " +
            "FROM products p " +
            "LEFT JOIN users u ON p.seller_id=u.user_id " +
            "LEFT JOIN categories c ON p.category_id=c.category_id " +
            "WHERE p.publish_status=? AND IFNULL(p.is_deleted,0)=0 " +
            "ORDER BY p.created_at DESC";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, statusFilter);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("productId",    rs.getInt("product_id"));
                    row.put("title",        rs.getString("title"));
                    row.put("price",        rs.getBigDecimal("price"));
                    row.put("publishStatus",rs.getString("publish_status"));
                    row.put("createdAt",    rs.getTimestamp("created_at"));
                    row.put("coverImageUrl",rs.getString("cover_image_url"));
                    row.put("conditionLevel",rs.getString("condition_level"));
                    row.put("categoryName", rs.getString("category_name"));
                    row.put("sellerName",   rs.getString("seller_name"));
                    row.put("sellerNo",     rs.getString("student_or_staff_no"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载商品列表失败：" + e.getMessage());
        }

        req.setAttribute("productList", list);
        req.setAttribute("tab", tab);
        req.getRequestDispatcher("/admin-product-review.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getAdminUser(req, resp);
        if (loginUser == null) return;

        String action      = req.getParameter("action");
        String productIdStr = req.getParameter("productId");
        String tab         = req.getParameter("tab");
        if (tab == null) tab = "pending";

        if (productIdStr == null || (! "approve".equals(action) && !"reject".equals(action))) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        int productId;
        try { productId = Integer.parseInt(productIdStr.trim()); }
        catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        String newStatus = "approve".equals(action) ? "ON_SALE" : "REJECTED";
        String sql = "UPDATE products SET publish_status=? WHERE product_id=? AND publish_status='PENDING_REVIEW'";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setInt(2, productId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                req.getSession().setAttribute("successMsg",
                    "approve".equals(action) ? "商品已审核通过" : "商品已驳回");
            } else {
                req.getSession().setAttribute("errorMsg", "操作失败，商品状态可能已变更");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/products?tab=" + tab);
    }

    private User getAdminUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        if (!"ADMIN".equals(u.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return null;
        }
        return u;
    }
}
