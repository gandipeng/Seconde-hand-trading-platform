package com.minzu.servlet;

import com.minzu.entity.Message;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /messages          GET  -> 会话列表
 * /messages          POST -> 发送消息（form submit）
 * /messages?with=xx  GET  -> 与某用户的聊天记录
 */
@WebServlet("/messages")
public class MessageServlet extends HttpServlet {

    // ==================== GET ====================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String withStr = request.getParameter("with");
        String productIdStr = request.getParameter("productId");

        if (withStr != null && !withStr.trim().isEmpty()) {
            showChat(request, response, loginUser, withStr, productIdStr);
        } else {
            showConversationList(request, response, loginUser);
        }
    }

    // ==================== POST ====================
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

        String receiverIdStr = request.getParameter("receiverId");
        String content       = request.getParameter("content");
        String productIdStr  = request.getParameter("productId");

        // Bug 2 修复：验证失败时 redirect 回聊天页而非直接跳消息列表，
        // 避免用户看起来像是「发送没有反应」
        if (receiverIdStr == null || content == null || content.trim().isEmpty()) {
            String back = request.getContextPath() + "/messages";
            if (receiverIdStr != null && !receiverIdStr.trim().isEmpty()) {
                back += "?with=" + receiverIdStr.trim();
                if (productIdStr != null && !productIdStr.trim().isEmpty()) {
                    back += "&productId=" + productIdStr.trim();
                }
            }
            response.sendRedirect(back);
            return;
        }

        int receiverId;
        try {
            receiverId = Integer.parseInt(receiverIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        if (receiverId == loginUser.getUserId()) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        Integer productId = null;
        if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            try { productId = Integer.parseInt(productIdStr.trim()); } catch (Exception ignored) {}
        }

        String sql = "INSERT INTO messages (sender_id, receiver_id, product_id, content, is_read, created_at) " +
                     "VALUES (?, ?, ?, ?, 0, NOW())";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, loginUser.getUserId());
            ps.setInt(2, receiverId);
            if (productId != null) ps.setInt(3, productId);
            else ps.setNull(3, Types.INTEGER);
            ps.setString(4, content.trim());
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }

        String redirect = request.getContextPath() + "/messages?with=" + receiverId;
        if (productId != null) redirect += "&productId=" + productId;
        response.sendRedirect(redirect);
    }

    // ========== 会话列表 ==========
    private void showConversationList(HttpServletRequest request, HttpServletResponse response,
                                      User loginUser) throws ServletException, IOException {
        int me = loginUser.getUserId();

        String sql =
            "SELECT " +
            "  other_id, " +
            "  u.nickname AS other_nickname, " +
            "  last_content, " +
            "  last_time, " +
            "  unread_count " +
            "FROM ( " +
            "  SELECT " +
            "    IF(sender_id = ?, receiver_id, sender_id) AS other_id, " +
            "    SUBSTRING_INDEX(GROUP_CONCAT(content ORDER BY created_at DESC SEPARATOR '|||'), '|||', 1) AS last_content, " +
            "    MAX(created_at) AS last_time, " +
            "    SUM(IF(receiver_id = ? AND is_read = 0, 1, 0)) AS unread_count " +
            "  FROM messages " +
            "  WHERE sender_id = ? OR receiver_id = ? " +
            "  GROUP BY other_id " +
            ") t " +
            "JOIN users u ON u.user_id = t.other_id " +
            "ORDER BY last_time DESC";

        List<Map<String, Object>> conversations = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, me);
            ps.setInt(2, me);
            ps.setInt(3, me);
            ps.setInt(4, me);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> conv = new LinkedHashMap<>();
                    conv.put("otherId",       rs.getInt("other_id"));
                    conv.put("otherNickname", rs.getString("other_nickname"));
                    conv.put("lastContent",   rs.getString("last_content"));
                    conv.put("lastTime",      rs.getTimestamp("last_time"));
                    conv.put("unreadCount",   rs.getInt("unread_count"));
                    conversations.add(conv);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("conversations", conversations);
        request.getRequestDispatcher("/messages.jsp").forward(request, response);
    }

    // ========== 聊天详情 ==========
    private void showChat(HttpServletRequest request, HttpServletResponse response,
                          User loginUser, String withStr, String productIdStr)
            throws ServletException, IOException {

        int me = loginUser.getUserId();
        int otherId;
        try {
            otherId = Integer.parseInt(withStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        if (otherId == me) {
            response.sendRedirect(request.getContextPath() + "/messages");
            return;
        }

        Integer productId = null;
        if (productIdStr != null && !productIdStr.trim().isEmpty()) {
            try { productId = Integer.parseInt(productIdStr.trim()); } catch (Exception ignored) {}
        }

        request.setAttribute("otherId",       otherId);
        request.setAttribute("otherNickname", "用户" + otherId);
        request.setAttribute("product",       null);
        request.setAttribute("chatList",      new ArrayList<>());
        request.setAttribute("productId",     productId);

        try (Connection conn = DBUtil.getConnection()) {

            String userSql = "SELECT nickname FROM users WHERE user_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(userSql)) {
                ps.setInt(1, otherId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        request.setAttribute("otherNickname", rs.getString("nickname"));
                    } else {
                        response.sendRedirect(request.getContextPath() + "/messages");
                        return;
                    }
                }
            }

            if (productId != null) {
                String pSql = "SELECT product_id, title, cover_image_url, price FROM products WHERE product_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(pSql)) {
                    ps.setInt(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            Map<String, Object> product = new LinkedHashMap<>();
                            product.put("productId",  rs.getInt("product_id"));
                            product.put("title",       rs.getString("title"));
                            product.put("coverUrl",    rs.getString("cover_image_url"));
                            product.put("price",       rs.getBigDecimal("price"));
                            request.setAttribute("product", product);
                        }
                    }
                }
            }

            String msgSql =
                "SELECT m.message_id, m.sender_id, m.receiver_id, m.content, " +
                "       m.is_read, m.created_at, " +
                "       s.nickname AS sender_nickname " +
                "FROM messages m " +
                "JOIN users s ON s.user_id = m.sender_id " +
                "WHERE ((m.sender_id = ? AND m.receiver_id = ?) " +
                "    OR (m.sender_id = ? AND m.receiver_id = ?)) " +
                "ORDER BY m.created_at ASC " +
                "LIMIT 200";

            List<Message> chatList = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(msgSql)) {
                ps.setInt(1, me);      ps.setInt(2, otherId);
                ps.setInt(3, otherId); ps.setInt(4, me);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Message msg = new Message();
                        msg.setMessageId(rs.getInt("message_id"));
                        msg.setSenderId(rs.getInt("sender_id"));
                        msg.setReceiverId(rs.getInt("receiver_id"));
                        msg.setContent(rs.getString("content"));
                        msg.setRead(rs.getBoolean("is_read"));
                        msg.setCreatedAt(rs.getTimestamp("created_at"));
                        msg.setSenderNickname(rs.getString("sender_nickname"));
                        chatList.add(msg);
                    }
                }
            }
            request.setAttribute("chatList", chatList);

            String markSql = "UPDATE messages SET is_read=1 " +
                             "WHERE receiver_id=? AND sender_id=? AND is_read=0";
            try (PreparedStatement ps = conn.prepareStatement(markSql)) {
                ps.setInt(1, me);
                ps.setInt(2, otherId);
                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载聊天记录失败，请稍后重试：" + e.getMessage());
        }

        request.getRequestDispatcher("/message-chat.jsp").forward(request, response);
    }
}
