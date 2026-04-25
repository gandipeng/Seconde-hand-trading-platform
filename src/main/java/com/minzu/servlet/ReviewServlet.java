package com.minzu.servlet;

import com.minzu.entity.Review;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /review
 *   GET  ?orderId=xx          -> 渲染评价填写页 (review.jsp)
 *   GET  ?view=sent|received  -> 我的评价列表 (my-reviews.jsp)
 *   POST action=submit        -> 提交评价
 */
@WebServlet("/review")
public class ReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String view = req.getParameter("view");

        // ----- 评价列表 -----
        if ("sent".equals(view) || "received".equals(view)) {
            loadReviewList(req, resp, loginUser, view);
            return;
        }

        // ----- 填写评价页 -----
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null) {
            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
            return;
        }
        int orderId;
        try { orderId = Integer.parseInt(orderIdStr.trim()); }
        catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
            return;
        }

        // 查订单基本信息，确认订单已完成且当前用户有资格评价
        String orderSql =
            "SELECT o.order_id, o.product_id, o.buyer_id, o.seller_id, o.order_status, " +
            "p.title AS product_title " +
            "FROM orders o LEFT JOIN products p ON o.product_id=p.product_id " +
            "WHERE o.order_id=? AND o.order_status='COMPLETED' " +
            "AND (o.buyer_id=? OR o.seller_id=?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(orderSql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, loginUser.getUserId());
            ps.setInt(3, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    req.getSession().setAttribute("errorMsg", "订单不存在或不符合评价条件");
                    resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
                    return;
                }
                // 检查是否已评价
                String role = (rs.getInt("buyer_id") == loginUser.getUserId()) ? "BUYER" : "SELLER";
                String checkSql = "SELECT 1 FROM reviews WHERE order_id=? AND reviewer_id=? AND role=?";
                try (PreparedStatement chk = conn.prepareStatement(checkSql)) {
                    chk.setInt(1, orderId);
                    chk.setInt(2, loginUser.getUserId());
                    chk.setString(3, role);
                    try (ResultSet cr = chk.executeQuery()) {
                        if (cr.next()) {
                            req.getSession().setAttribute("errorMsg", "你已经评价过此订单");
                            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
                            return;
                        }
                    }
                }
                req.setAttribute("orderId", orderId);
                req.setAttribute("productTitle", rs.getString("product_title"));
                req.setAttribute("role", role);
                req.getRequestDispatcher("/review.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "加载评价页失败：" + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String orderIdStr = req.getParameter("orderId");
        String scoreStr   = req.getParameter("score");
        String content    = req.getParameter("content");

        if (orderIdStr == null || scoreStr == null) {
            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
            return;
        }

        int orderId, score;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
            score   = Integer.parseInt(scoreStr.trim());
            if (score < 1 || score > 5) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMsg", "评分参数非法");
            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
            return;
        }

        String orderSql =
            "SELECT buyer_id, seller_id, product_id FROM orders " +
            "WHERE order_id=? AND order_status='COMPLETED' AND (buyer_id=? OR seller_id=?)";

        String checkSql  = "SELECT 1 FROM reviews WHERE order_id=? AND reviewer_id=? AND role=?";
        String insertSql =
            "INSERT INTO reviews (order_id, reviewer_id, reviewed_id, product_id, score, content, role) " +
            "VALUES (?,?,?,?,?,?,?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement orderPs = conn.prepareStatement(orderSql)) {

            orderPs.setInt(1, orderId);
            orderPs.setInt(2, loginUser.getUserId());
            orderPs.setInt(3, loginUser.getUserId());

            try (ResultSet rs = orderPs.executeQuery()) {
                if (!rs.next()) {
                    req.getSession().setAttribute("errorMsg", "订单不存在或无权评价");
                    resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
                    return;
                }
                int buyerId   = rs.getInt("buyer_id");
                int sellerId  = rs.getInt("seller_id");
                int productId = rs.getInt("product_id");
                String role   = (buyerId == loginUser.getUserId()) ? "BUYER" : "SELLER";
                int reviewedId = "BUYER".equals(role) ? sellerId : buyerId;

                // 幂等检查
                try (PreparedStatement chk = conn.prepareStatement(checkSql)) {
                    chk.setInt(1, orderId);
                    chk.setInt(2, loginUser.getUserId());
                    chk.setString(3, role);
                    try (ResultSet cr = chk.executeQuery()) {
                        if (cr.next()) {
                            req.getSession().setAttribute("errorMsg", "你已经评价过此订单");
                            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
                            return;
                        }
                    }
                }

                try (PreparedStatement ins = conn.prepareStatement(insertSql)) {
                    ins.setInt(1, orderId);
                    ins.setInt(2, loginUser.getUserId());
                    ins.setInt(3, reviewedId);
                    ins.setInt(4, productId);
                    ins.setInt(5, score);
                    ins.setString(6, (content != null && !content.trim().isEmpty()) ? content.trim() : null);
                    ins.setString(7, role);
                    ins.executeUpdate();
                }
                req.getSession().setAttribute("successMsg", "评价提交成功！");
                resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "提交评价失败：" + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/orders?type=buy");
        }
    }

    private void loadReviewList(HttpServletRequest req, HttpServletResponse resp,
                                 User loginUser, String view)
            throws ServletException, IOException {
        String sql;
        if ("sent".equals(view)) {
            sql = "SELECT r.*, p.title AS product_title, " +
                  "ru.real_name AS reviewer_name, rd.real_name AS reviewed_name " +
                  "FROM reviews r " +
                  "LEFT JOIN products p ON r.product_id=p.product_id " +
                  "LEFT JOIN users ru ON r.reviewer_id=ru.user_id " +
                  "LEFT JOIN users rd ON r.reviewed_id=rd.user_id " +
                  "WHERE r.reviewer_id=? ORDER BY r.created_at DESC";
        } else {
            sql = "SELECT r.*, p.title AS product_title, " +
                  "ru.real_name AS reviewer_name, rd.real_name AS reviewed_name " +
                  "FROM reviews r " +
                  "LEFT JOIN products p ON r.product_id=p.product_id " +
                  "LEFT JOIN users ru ON r.reviewer_id=ru.user_id " +
                  "LEFT JOIN users rd ON r.reviewed_id=rd.user_id " +
                  "WHERE r.reviewed_id=? ORDER BY r.created_at DESC";
        }
        List<Review> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setOrderId(rs.getInt("order_id"));
                    r.setReviewerId(rs.getInt("reviewer_id"));
                    r.setReviewedId(rs.getInt("reviewed_id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setScore(rs.getInt("score"));
                    r.setContent(rs.getString("content"));
                    r.setRole(rs.getString("role"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setReviewerName(rs.getString("reviewer_name"));
                    r.setReviewedName(rs.getString("reviewed_name"));
                    r.setProductTitle(rs.getString("product_title"));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载评价失败：" + e.getMessage());
        }
        req.setAttribute("reviews", list);
        req.setAttribute("view", view);
        req.getRequestDispatcher("/my-reviews.jsp").forward(req, resp);
    }

    private User getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        return u;
    }
}
