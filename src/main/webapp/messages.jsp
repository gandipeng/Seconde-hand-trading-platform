<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="java.util.*" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Map<String, Object>> conversations = (List<Map<String, Object>>) request.getAttribute("conversations");
    if (conversations == null) conversations = new ArrayList<>();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>私信 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header {
            height: 56px; background: #1677ff; color: white;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }
        .logo { font-size: 18px; font-weight: bold; }
        .nav a { color: white; text-decoration: none; margin-left: 14px; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        .nav a:hover { background: rgba(255,255,255,0.16); }

        .container { max-width: 760px; margin: 32px auto; padding: 0 16px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 20px; }

        .conv-list { display: flex; flex-direction: column; gap: 2px; }
        .conv-item {
            background: white; border-radius: 12px;
            display: flex; align-items: center; gap: 14px;
            padding: 14px 16px; text-decoration: none; color: inherit;
            transition: background 0.15s, box-shadow 0.15s;
            box-shadow: 0 1px 4px rgba(0,0,0,0.04);
        }
        .conv-item:hover { background: #f0f7ff; box-shadow: 0 4px 12px rgba(22,119,255,0.08); }

        .avatar {
            width: 46px; height: 46px; border-radius: 50%;
            background: #1677ff; color: white; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; font-weight: bold;
        }
        .conv-info { flex: 1; min-width: 0; }
        .conv-name { font-size: 15px; font-weight: bold; margin-bottom: 4px; }
        .conv-preview {
            font-size: 13px; color: #999;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .conv-right { text-align: right; flex-shrink: 0; }
        .conv-time { font-size: 12px; color: #bbb; margin-bottom: 6px; }
        .unread-badge {
            display: inline-block; background: #ff4d4f; color: white;
            font-size: 11px; font-weight: bold;
            min-width: 18px; height: 18px; padding: 0 5px;
            border-radius: 9px; text-align: center; line-height: 18px;
        }
        .empty-box { text-align: center; padding: 60px 20px; color: #aaa; }
        .empty-icon { font-size: 52px; margin-bottom: 12px; }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/orders">我的订单</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <div class="page-title">&#128172; 我的私信</div>

    <% if (conversations.isEmpty()) { %>
        <div class="empty-box">
            <div class="empty-icon">&#128172;</div>
            <div>还没有私信，去浏览商品并联系卖家吧</div>
        </div>
    <% } else { %>
        <div class="conv-list">
        <% for (Map<String, Object> conv : conversations) {
            /* Bug D 修复：改用 ((Number)).intValue() 安全取值
               原 (int) 直接强转在部分 JVM / 运行时会抛 ClassCastException */
            int otherId   = ((Number) conv.get("otherId")).intValue();
            int unread    = ((Number) conv.get("unreadCount")).intValue();
            String otherNickname = (String) conv.get("otherNickname");
            String lastContent   = (String) conv.get("lastContent");
            Object lastTime      = conv.get("lastTime");
            String initial = (otherNickname != null && otherNickname.length() > 0)
                ? String.valueOf(otherNickname.charAt(0)).toUpperCase() : "?";
            String timeStr = "";
            if (lastTime != null) {
                String ts = lastTime.toString();
                timeStr = ts.length() >= 16 ? ts.substring(5, 16) : ts;
            }
        %>
            <a class="conv-item"
               href="${pageContext.request.contextPath}/messages?with=<%= otherId %>">
                <div class="avatar"><%= initial %></div>
                <div class="conv-info">
                    <div class="conv-name"><%= otherNickname %></div>
                    <div class="conv-preview"><%= lastContent != null ? lastContent : "" %></div>
                </div>
                <div class="conv-right">
                    <div class="conv-time"><%= timeStr %></div>
                    <% if (unread > 0) { %>
                        <span class="unread-badge"><%= unread > 99 ? "99+" : unread %></span>
                    <% } %>
                </div>
            </a>
        <% } %>
        </div>
    <% } %>
</div>

</body>
</html>
