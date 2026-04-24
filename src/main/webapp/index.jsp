<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<html>
<head>
    <title>民大二手交易平台</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f7fa;
            margin: 0;
        }

        .header {
            background: #1677ff;
            color: white;
            padding: 14px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 18px;
            font-weight: bold;
        }

        .nav a {
            color: white;
            text-decoration: none;
            margin-left: 16px;
            font-size: 14px;
            padding: 6px 10px;
            border-radius: 6px;
        }

        .nav a:hover {
            background: rgba(255, 255, 255, 0.16);
        }

        .main {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
        }

        h1 {
            font-size: 26px;
            margin-bottom: 8px;
        }

        p {
            color: #555;
        }

        .btn-group {
            margin-top: 24px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-block;
            padding: 12px 28px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 15px;
            color: white;
            background: #1677ff;
        }

        .btn:hover {
            background: #0958d9;
        }

        .admin-btn {
            background: #722ed1;
        }

        .admin-btn:hover {
            background: #531dab;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">浏览商品</a>

        <% if ("ADMIN".equals(loginUser.getRoleCode())) { %>
            <a href="${pageContext.request.contextPath}/admin/user-review">用户审核</a>
        <% } %>

        <a href="${pageContext.request.contextPath}/logout">退出登录</a>
    </div>
</div>

<div class="main">
    <h1>欢迎你，<%= loginUser.getRealName() %> 👋</h1>
    <p>
        学号/工号：<%= loginUser.getStudentOrStaffNo() %>
        &nbsp;|&nbsp;
        角色：<%= loginUser.getRoleCode() %>
    </p>

    <div class="btn-group">
        <a href="${pageContext.request.contextPath}/product-list" class="btn">📦 浏览商品</a>

        <% if ("ADMIN".equals(loginUser.getRoleCode())) { %>
            <a href="${pageContext.request.contextPath}/admin/user-review" class="btn admin-btn">🛡 用户审核</a>
        <% } %>
    </div>
</div>

</body>
</html>