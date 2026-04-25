package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

@WebServlet("/orders")
public class OrderServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String type = request.getParameter("type");
        if (type == null || (!"buy".equals(type) && !"sell".equals(type))) {
            type = "buy";
        }

        String sql =
                "SELECT o.order_id, o.order_no, o.product_id, o.deal_price, o.quantity, " +
                "o.order_status, o.buyer_note, o.seller_note, o.pickup_code, " +
                "o.created_at, o.paid_at, o.completed_at, o.cancelled_at, o.updated_at, " +
                "p.title, p.cover_image_url, " +
                "bu.real_name AS buyer_name, se.real_name AS seller_name " +
                "FROM orders o " +
                "LEFT JOIN products p ON o.product_id = p.product_id " +
                "LEFT JOIN users bu ON o.buyer_id = bu.user_id " +
                "LEFT JOIN users se ON o.seller_id = se.user_id " +
                "WHERE " + ("sell".equals(type) ? "o.seller_id = ?" : "o.buyer_id = ?") +
                " ORDER BY o.created_at DESC";

        List<Map<String, Object>> orderList = new ArrayList<>();

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, loginUser.getUserId());

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("orderId", rs.getInt("order_id"));
                    row.put("orderNo", rs.getString("order_no"));
                    row.put("productId", rs.getInt("product_id"));
                    row.put("title", rs.getString("title"));
                    row.put("coverImageUrl", rs.getString("cover_image_url"));
                    row.put("dealPrice", rs.getBigDecimal("deal_price"));
                    row.put("quantity", rs.getInt("quantity"));
                    row.put("orderStatus", rs.getString("order_status"));
                    row.put("buyerNote", rs.getString("buyer_note"));
                    row.put("sellerNote", rs.getString("seller_note"));
                    row.put("pickupCode", rs.getString("pickup_code"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    row.put("paidAt", rs.getTimestamp("paid_at"));
                    row.put("completedAt", rs.getTimestamp("completed_at"));
                    row.put("cancelledAt", rs.getTimestamp("cancelled_at"));
                    row.put("updatedAt", rs.getTimestamp("updated_at"));
                    row.put("buyerName", rs.getString("buyer_name"));
                    row.put("sellerName", rs.getString("seller_name"));
                    orderList.add(row);
                }
            }

            request.setAttribute("type", type);
            request.setAttribute("orderList", orderList);
            request.getRequestDispatcher("/my-orders.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载订单失败：" + e.getMessage());
            request.setAttribute("type", type);
            request.setAttribute("orderList", orderList);
            request.getRequestDispatcher("/my-orders.jsp").forward(request, response);
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

        if ("create".equals(action)) {
            createOrder(request, response, loginUser);
        } else if ("cancel".equals(action)) {
            updateOrderStatus(request, response, loginUser, "CANCELLED");
        } else if ("paid".equals(action)) {
            updateOrderStatus(request, response, loginUser, "PAID_OFFLINE");
        } else if ("complete".equals(action)) {
            updateOrderStatus(request, response, loginUser, "COMPLETED");
        } else if ("dispute".equals(action)) {
            updateOrderStatus(request, response, loginUser, "DISPUTED");
        } else {
            response.sendRedirect(request.getContextPath() + "/orders");
        }
    }

    private void createOrder(HttpServletRequest request, HttpServletResponse response, User loginUser)
            throws IOException {

        String productIdStr = request.getParameter("productId");
        String buyerNote = request.getParameter("buyerNote");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            request.getSession().setAttribute("errorMsg", "商品ID不能为空");
            response.sendRedirect(request.getContextPath() + "/product-list");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("errorMsg", "商品ID格式错误");
            response.sendRedirect(request.getContextPath() + "/product-list");
            return;
        }

        String productSql =
                "SELECT product_id, seller_id, title, price, publish_status " +
                "FROM products WHERE product_id = ? AND IFNULL(is_deleted, 0) = 0";

        String checkSql =
                "SELECT 1 FROM orders " +
                "WHERE product_id = ? AND buyer_id = ? AND order_status IN ('CREATED','PAID_OFFLINE','DISPUTED')";

        String insertSql =
                "INSERT INTO orders " +
                "(order_no, product_id, buyer_id, seller_id, deal_price, quantity, order_status, buyer_note) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'CREATED', ?)";

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement productPs = conn.prepareStatement(productSql)
        ) {
            productPs.setInt(1, productId);

            try (ResultSet rs = productPs.executeQuery()) {
                if (!rs.next()) {
                    request.getSession().setAttribute("errorMsg", "商品不存在");
                    response.sendRedirect(request.getContextPath() + "/product-list");
                    return;
                }

                int sellerId = rs.getInt("seller_id");
                BigDecimal price = rs.getBigDecimal("price");
                String publishStatus = rs.getString("publish_status");

                if (sellerId == loginUser.getUserId()) {
                    request.getSession().setAttribute("errorMsg", "不能购买自己的商品");
                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                    return;
                }

                // 修正：使用数据库实际枚举值 ON_SALE
                if (!"ON_SALE".equalsIgnoreCase(publishStatus)) {
                    request.getSession().setAttribute("errorMsg", "该商品当前不可交易");
                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                    return;
                }

                try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                    checkPs.setInt(1, productId);
                    checkPs.setInt(2, loginUser.getUserId());
                    try (ResultSet checkRs = checkPs.executeQuery()) {
                        if (checkRs.next()) {
                            request.getSession().setAttribute("errorMsg", "你已经对该商品发起过订单，请在\"我的订单\"中查看");
                            response.sendRedirect(request.getContextPath() + "/orders?type=buy");
                            return;
                        }
                    }
                }

                String orderNo = "ORD" + System.currentTimeMillis();

                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    insertPs.setString(1, orderNo);
                    insertPs.setInt(2, productId);
                    insertPs.setInt(3, loginUser.getUserId());
                    insertPs.setInt(4, sellerId);
                    insertPs.setBigDecimal(5, price);
                    insertPs.setInt(6, 1);
                    insertPs.setString(7, (buyerNote != null && !buyerNote.trim().isEmpty()) ? buyerNote.trim() : null);

                    int rows = insertPs.executeUpdate();
                    if (rows > 0) {
                        request.getSession().setAttribute("successMsg", "订单已创建，请等待卖家确认");
                        response.sendRedirect(request.getContextPath() + "/orders?type=buy");
                    } else {
                        request.getSession().setAttribute("errorMsg", "下单失败，请重试");
                        response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "下单失败：" + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/product-list");
        }
    }

    private void updateOrderStatus(HttpServletRequest request, HttpServletResponse response,
                                   User loginUser, String targetStatus) throws IOException {

        String orderIdStr = request.getParameter("orderId");
        String type = request.getParameter("type");
        if (type == null || (!"buy".equals(type) && !"sell".equals(type))) {
            type = "buy";
        }

        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
            return;
        }

        String sql;

        if ("CANCELLED".equals(targetStatus)) {
            sql = "UPDATE orders SET order_status='CANCELLED', cancelled_at=NOW() " +
                  "WHERE order_id=? AND buyer_id=? AND order_status='CREATED'";
        } else if ("PAID_OFFLINE".equals(targetStatus)) {
            sql = "UPDATE orders SET order_status='PAID_OFFLINE', paid_at=NOW() " +
                  "WHERE order_id=? AND seller_id=? AND order_status='CREATED'";
        } else if ("COMPLETED".equals(targetStatus)) {
            sql = "UPDATE orders SET order_status='COMPLETED', completed_at=NOW() " +
                  "WHERE order_id=? AND buyer_id=? AND order_status='PAID_OFFLINE'";
        } else if ("DISPUTED".equals(targetStatus)) {
            sql = "UPDATE orders SET order_status='DISPUTED' " +
                  "WHERE order_id=? AND (buyer_id=? OR seller_id=?) " +
                  "AND order_status IN ('CREATED','PAID_OFFLINE')";
        } else {
            response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
            return;
        }

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            if ("DISPUTED".equals(targetStatus)) {
                ps.setInt(1, orderId);
                ps.setInt(2, loginUser.getUserId());
                ps.setInt(3, loginUser.getUserId());
            } else {
                ps.setInt(1, orderId);
                ps.setInt(2, loginUser.getUserId());
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                request.getSession().setAttribute("successMsg", "订单状态已更新");
            } else {
                request.getSession().setAttribute("errorMsg", "操作失败，可能订单状态已变更或无权操作");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
    }
}
