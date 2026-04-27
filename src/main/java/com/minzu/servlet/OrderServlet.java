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

    private static final int PAGE_SIZE = 10;

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

        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) {
                page = Math.max(1, Integer.parseInt(pageStr.trim()));
            }
        } catch (NumberFormatException ignored) {
        }

        String whereClause = "sell".equals(type) ? "o.seller_id = ?" : "o.buyer_id = ?";

        int totalCount = 0;
        int totalPages = 1;
        List<Map<String, Object>> orderList = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection()) {
            String countSql = "SELECT COUNT(*) FROM orders o WHERE " + whereClause;
            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setInt(1, loginUser.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalCount = rs.getInt(1);
                    }
                }
            }

            totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
            if (totalPages < 1) {
                totalPages = 1;
            }
            if (page > totalPages) {
                page = totalPages;
            }
            int offset = (page - 1) * PAGE_SIZE;

            String sql =
                    "SELECT o.order_id, o.order_no, o.product_id, o.deal_price, o.quantity, " +
                    "o.order_status, o.buyer_note, o.seller_note, o.pickup_code, " +
                    "o.created_at, o.paid_at, o.completed_at, o.cancelled_at, " +
                    "IFNULL(o.updated_at, o.created_at) AS updated_at, " +
                    "p.title, p.cover_image_url, " +
                    "bu.nickname AS buyer_name, se.nickname AS seller_name " +
                    "FROM orders o " +
                    "LEFT JOIN products p ON o.product_id = p.product_id " +
                    "LEFT JOIN users bu ON o.buyer_id = bu.user_id " +
                    "LEFT JOIN users se ON o.seller_id = se.user_id " +
                    "WHERE " + whereClause +
                    " ORDER BY o.created_at DESC" +
                    " LIMIT ? OFFSET ?";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, loginUser.getUserId());
                ps.setInt(2, PAGE_SIZE);
                ps.setInt(3, offset);

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
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载订单失败：" + e.getMessage());
        }

        request.setAttribute("type", type);
        request.setAttribute("orderList", orderList);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/my-orders.jsp").forward(request, response);
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
                "SELECT product_id, seller_id, price, publish_status " +
                "FROM products WHERE product_id = ? AND IFNULL(is_deleted, 0) = 0 FOR UPDATE";

        String checkSql =
                "SELECT 1 FROM orders " +
                "WHERE product_id = ? AND order_status IN ('CREATED','PAID_OFFLINE','DISPUTED') " +
                "LIMIT 1";

        String insertSql =
                "INSERT INTO orders " +
                "(order_no, product_id, buyer_id, seller_id, deal_price, quantity, order_status, buyer_note) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'CREATED', ?)";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement productPs = conn.prepareStatement(productSql)) {
                    productPs.setInt(1, productId);
                    try (ResultSet rs = productPs.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            request.getSession().setAttribute("errorMsg", "商品不存在");
                            response.sendRedirect(request.getContextPath() + "/product-list");
                            return;
                        }

                        int sellerId = rs.getInt("seller_id");
                        BigDecimal price = rs.getBigDecimal("price");
                        String publishStatus = rs.getString("publish_status");

                        if (sellerId == loginUser.getUserId()) {
                            conn.rollback();
                            request.getSession().setAttribute("errorMsg", "不能购买自己的商品");
                            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                            return;
                        }

                        if (!"ON_SALE".equalsIgnoreCase(publishStatus)) {
                            conn.rollback();
                            request.getSession().setAttribute("errorMsg", "该商品当前不可交易");
                            response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                            return;
                        }

                        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                            checkPs.setInt(1, productId);
                            try (ResultSet checkRs = checkPs.executeQuery()) {
                                if (checkRs.next()) {
                                    conn.rollback();
                                    request.getSession().setAttribute("errorMsg", "该商品已有进行中的订单，请稍后再试");
                                    response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
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
                                conn.commit();
                                request.getSession().setAttribute("successMsg", "订单已创建，请等待卖家确认");
                                response.sendRedirect(request.getContextPath() + "/orders?type=buy");
                            } else {
                                conn.rollback();
                                request.getSession().setAttribute("errorMsg", "下单失败，请重试");
                                response.sendRedirect(request.getContextPath() + "/product-detail?id=" + productId);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "下单失败：" + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/product-list");
        }
    }

    private String generatePickupCode() {
        return String.format("%06d", new Random().nextInt(1_000_000));
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
            sql = "UPDATE orders SET order_status='PAID_OFFLINE', paid_at=NOW(), pickup_code=? " +
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

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);

            Integer productId = lockProductForOrder(conn, orderId);
            if (productId == null) {
                conn.rollback();
                request.getSession().setAttribute("errorMsg", "订单不存在或商品已被删除");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if (("PAID_OFFLINE".equals(targetStatus) || "COMPLETED".equals(targetStatus))
                    && hasOtherActiveOrders(conn, productId, orderId)) {
                conn.rollback();
                request.getSession().setAttribute("errorMsg", "该商品存在其他进行中的订单，请先处理后再继续");
                response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
                return;
            }

            if ("PAID_OFFLINE".equals(targetStatus)) {
                ps.setString(1, generatePickupCode());
                ps.setInt(2, orderId);
                ps.setInt(3, loginUser.getUserId());
            } else if ("DISPUTED".equals(targetStatus)) {
                ps.setInt(1, orderId);
                ps.setInt(2, loginUser.getUserId());
                ps.setInt(3, loginUser.getUserId());
            } else {
                ps.setInt(1, orderId);
                ps.setInt(2, loginUser.getUserId());
            }

            int rows = ps.executeUpdate();
            if (rows > 0) {
                if ("COMPLETED".equals(targetStatus)) {
                    String updateProductSql =
                            "UPDATE products SET publish_status = 'SOLD' " +
                            "WHERE product_id = ? AND publish_status IN ('ON_SALE', 'OFF_SHELF')";
                    try (PreparedStatement updPs = conn.prepareStatement(updateProductSql)) {
                        updPs.setInt(1, productId);
                        updPs.executeUpdate();
                    }
                }

                conn.commit();
                String msg = "COMPLETED".equals(targetStatus) ? "订单已完成，商品已标记为已售"
                           : "PAID_OFFLINE".equals(targetStatus) ? "已确认线下成交，取货码已生成"
                           : "订单状态已更新";
                request.getSession().setAttribute("successMsg", msg);
            } else {
                conn.rollback();
                request.getSession().setAttribute("errorMsg", "操作失败，可能订单状态已变更或无权操作");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/orders?type=" + type);
    }

    private Integer lockProductForOrder(Connection conn, int orderId) throws SQLException {
        String sql =
                "SELECT p.product_id " +
                "FROM orders o " +
                "JOIN products p ON p.product_id = o.product_id " +
                "WHERE o.order_id = ? AND IFNULL(p.is_deleted, 0) = 0 " +
                "FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("product_id") : null;
            }
        }
    }

    private boolean hasOtherActiveOrders(Connection conn, int productId, int currentOrderId) throws SQLException {
        String sql =
                "SELECT 1 FROM orders " +
                "WHERE product_id = ? AND order_id <> ? " +
                "AND order_status IN ('CREATED','PAID_OFFLINE','DISPUTED') " +
                "LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, currentOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
