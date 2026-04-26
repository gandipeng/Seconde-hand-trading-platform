<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Message" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    int me = loginUser.getUserId();
    int otherId = (Integer) request.getAttribute("otherId");
    String otherNickname = (String) request.getAttribute("otherNickname");
    Map<String, Object> product = (Map<String, Object>) request.getAttribute("product");
    List<Message> chatList = (List<Message>) request.getAttribute("chatList");
    Integer productId = (Integer) request.getAttribute("productId");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= otherNickname %> - 私信</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa;
               display: flex; flex-direction: column; height: 100dvh; }

        /* ---- 顶部导航 ---- */
        .header {
            height: 56px; background: #1677ff; color: white; flex-shrink: 0;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 20px; box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }
        .header-left { display: flex; align-items: center; gap: 12px; }
        .back-btn {
            color: white; text-decoration: none;
            font-size: 22px; line-height: 1;
        }
        .header-title { font-size: 16px; font-weight: bold; }
        .logo-link { color: white; text-decoration: none; font-size: 15px; }

        /* ---- 商品卡片 ---- */
        .product-bar {
            background: white; border-bottom: 1px solid #f0f0f0; flex-shrink: 0;
            padding: 10px 16px; display: flex; align-items: center; gap: 12px;
        }
        .product-bar img {
            width: 44px; height: 44px; border-radius: 8px; object-fit: cover;
            background: #f0f0f0;
        }
        .product-bar-info { flex: 1; min-width: 0; }
        .product-bar-title {
            font-size: 13px; font-weight: bold;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .product-bar-price { font-size: 13px; color: #ff4d4f; margin-top: 2px; }
        .product-bar a {
            font-size: 12px; color: #1677ff; text-decoration: none;
            border: 1px solid #91caff; padding: 4px 10px; border-radius: 20px;
            white-space: nowrap;
        }

        /* ---- 消息区 ---- */
        .chat-body {
            flex: 1; overflow-y: auto; padding: 16px;
            display: flex; flex-direction: column; gap: 12px;
        }

        .msg-row { display: flex; gap: 8px; }
        .msg-row.mine { flex-direction: row-reverse; }

        .avatar {
            width: 36px; height: 36px; border-radius: 50%;
            background: #1677ff; color: white; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 14px; font-weight: bold;
        }
        .msg-row.mine .avatar { background: #52c41a; }

        .bubble-wrap { display: flex; flex-direction: column; max-width: 68%; }
        .msg-row.mine .bubble-wrap { align-items: flex-end; }

        .bubble {
            padding: 10px 14px; border-radius: 16px;
            font-size: 14px; line-height: 1.6; word-break: break-word;
            background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        }
        .msg-row.mine .bubble {
            background: #1677ff; color: white;
        }
        .bubble-time {
            font-size: 11px; color: #bbb; margin-top: 4px;
            padding: 0 4px;
        }

        /* ---- 输入区 ---- */
        .chat-input-area {
            background: white; border-top: 1px solid #f0f0f0;
            padding: 12px 16px; flex-shrink: 0;
        }
        .chat-input-area form {
            display: flex; gap: 10px; align-items: flex-end;
        }
        .chat-input-area textarea {
            flex: 1; padding: 10px 12px; border: 1px solid #d9d9d9;
            border-radius: 10px; font-size: 14px; resize: none;
            outline: none; min-height: 42px; max-height: 120px;
            font-family: inherit; line-height: 1.5;
        }
        .chat-input-area textarea:focus {
            border-color: #1677ff;
            box-shadow: 0 0 0 3px rgba(22,119,255,0.1);
        }
        .send-btn {
            background: #1677ff; color: white; border: none;
            padding: 10px 20px; border-radius: 10px; font-size: 14px;
            cursor: pointer; height: 42px; white-space: nowrap;
        }
        .send-btn:hover { background: #0958d9; }

        .empty-chat {
            margin: auto; text-align: center; color: #ccc;
            font-size: 14px; padding: 40px 0;
        }

        @media (max-width: 640px) {
            .bubble-wrap { max-width: 80%; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="header-left">
        <a class="back-btn" href="${pageContext.request.contextPath}/messages">&#8592;</a>
        <div class="header-title"><%= otherNickname %></div>
    </div>
    <a class="logo-link" href="${pageContext.request.contextPath}/index.jsp">🏫 民大二手</a>
</div>

<% if (product != null) { %>
<div class="product-bar">
    <% String coverUrl = (String) product.get("coverUrl"); %>
    <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
        <img src="<%= coverUrl %>" alt="商品图">
    <% } else { %>
        <div style="width:44px;height:44px;border-radius:8px;background:#f0f2f5;
                    display:flex;align-items:center;justify-content:center;font-size:20px;">📦</div>
    <% } %>
    <div class="product-bar-info">
        <div class="product-bar-title"><%= product.get("title") %></div>
        <div class="product-bar-price">¥<%= product.get("price") %></div>
    </div>
    <a href="${pageContext.request.contextPath}/product-detail?id=<%= product.get("productId") %>">查看商品</a>
</div>
<% } %>

<div class="chat-body" id="chatBody">
<% if (chatList == null || chatList.isEmpty()) { %>
    <div class="empty-chat">还没有消息，发一条开始聊天吧 👋</div>
<% } else {
    for (Message msg : chatList) {
        boolean isMine = msg.getSenderId() == me;
        String initial = msg.getSenderNickname() != null && msg.getSenderNickname().length() > 0
            ? String.valueOf(msg.getSenderNickname().charAt(0)).toUpperCase() : "?";
        String timeStr = "";
        if (msg.getCreatedAt() != null) {
            timeStr = msg.getCreatedAt().toString().substring(0, 16);
        }
%>
    <div class="msg-row <%= isMine ? "mine" : "" %>">
        <div class="avatar"><%= initial %></div>
        <div class="bubble-wrap">
            <div class="bubble"><%= msg.getContent() %></div>
            <div class="bubble-time"><%= timeStr %></div>
        </div>
    </div>
<% } } %>
</div>

<%-- Bug 2 修复：onsubmit 前端非空校验，防止空消息静默提交后被服务端 redirect 到列表页 --%>
<div class="chat-input-area">
    <form method="post" action="${pageContext.request.contextPath}/messages" id="msgForm"
          onsubmit="var v=document.getElementById('msgInput').value.trim(); if(!v){alert('消息内容不能为空');return false;}">
        <input type="hidden" name="receiverId" value="<%= otherId %>">
        <% if (productId != null) { %>
            <input type="hidden" name="productId" value="<%= productId %>">
        <% } %>
        <textarea name="content" id="msgInput" placeholder="输入消息…" rows="1"
                  onkeydown="handleKey(event)"></textarea>
        <button type="submit" class="send-btn">发送</button>
    </form>
</div>

<script>
    // 自动滚到底部
    (function() {
        var body = document.getElementById('chatBody');
        if (body) body.scrollTop = body.scrollHeight;
    })();

    // Ctrl+Enter 或 Enter（非 Shift）发送
    function handleKey(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            var val = document.getElementById('msgInput').value.trim();
            if (!val) { alert('消息内容不能为空'); return; }
            document.getElementById('msgForm').submit();
        }
    }

    // textarea 自动伸缩
    document.getElementById('msgInput').addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
</script>

</body>
</html>
