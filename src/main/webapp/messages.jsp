<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Map<String, Object>> conversations =
        (List<Map<String, Object>>) request.getAttribute("conversations");
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
        .nav a {
            color: white; text-decoration: none; margin-left: 14px;
            font-size: 14px; padding: 6px 12px; border-radius: 6px;
        }
        .nav a:hover { background: rgba(255,255,255,0.16); }

        .page { max-width: 680px; margin: 36px auto; padding: 0 16px; }

        .card {
            background: white; border-radius: 14px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07); overflow: hidden;
        }
        .card-header {
            padding: 20px 24px 16px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 18px; font-weight: bold;
        }

        .conv-list { }
        .conv-item {
            display: flex; align-items: center; gap: 14px;
            padding: 16px 24px;
            border-bottom: 1px solid #f7f7f7;
            text-decoration: none; color: inherit;
            transition: background 0.15s;
        }
        .conv-item:hover { background: #f0f7ff; }
        .conv-item:last-child { border-bottom: none; }

        .avatar {
            width: 44px; height: 44px; border-radius: 50%;
            background: #1677ff; color: white;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; font-weight: bold; flex-shrink: 0;
        }

        .conv-info { flex: 1; min-width: 0; }
        .conv-name {
            font-size: 15px; font-weight: bold;
            display: flex; align-items: center; gap: 8px;
        }
        .conv-last {
            font-size: 13px; color: #999; margin-top: 3px;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }

        .conv-right { text-align: right; flex-shrink: 0; }
        .conv-time { font-size: 12px; color: #bbb; }
        .badge {
            display: inline-block; margin-top: 6px;
            background: #ff4d4f; color: white;
            font-size: 11px; border-radius: 10px;
            padding: 2px 7px; min-width: 20px; text-align: center;
        }

        .empty-box {
            padding: 60px 20px; text-align: center; color: #aaa;
        }
        .empty-box .icon { font-size: 48px; margin-bottom: 12px; }
        .empty-box p { font-size: 15px; }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">浏览商品</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/messages" style="background:rgba(255,255,255,0.2);">私信</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="page">
    <div class="card">
        <div class="card-header">💬 私信</div>

        <% if (conversations == null || conversations.isEmpty()) { %>
            <div class="empty-box">
                <div class="icon">📭</div>
                <p>还没有任何对话</p>
                <p style="font-size:13px;">去商品详情页给卖家发私信吧</p>
            </div>
        <% } else { %>
            <div class="conv-list">
            <% for (Map<String, Object> conv : conversations) {
                int otherId = (int) conv.get("otherId");
                String otherNick = (String) conv.get("otherNickname");
                String lastContent = (String) conv.get("lastContent");
                Timestamp lastTime = (Timestamp) conv.get("lastTime");
                int unread = (int) conv.get("unreadCount");
                String initial = otherNick != null && otherNick.length() > 0
                        ? String.valueOf(otherNick.charAt(0)).toUpperCase() : "?";
                String timeStr = "";
                if (lastTime != null) {
                    timeStr = lastTime.toString().substring(0, 16).replace("T", " ");
                }
            %>
                <a class="conv-item" href="${pageContext.request.contextPath}/messages?with=<%= otherId %>">
                    <div class="avatar"><%= initial %></div>
                    <div class="conv-info">
                        <div class="conv-name">
                            <%= otherNick %>
                            <% if (unread > 0) { %>
                                <span class="badge"><%= unread %></span>
                            <% } %>
                        </div>
                        <div class="conv-last"><%= lastContent != null ? lastContent : "" %></div>
                    </div>
                    <div class="conv-right">
                        <div class="conv-time"><%= timeStr %></div>
                    </div>
                </a>
            <% } %>
            </div>
        <% } %>
    </div>
</div>

</body>
</html>
