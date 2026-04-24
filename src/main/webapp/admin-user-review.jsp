<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户审核</title>
    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f7fa;
            color: #333;
        }

        .header {
            height: 56px;
            background: #1677ff;
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }

        .header .logo {
            font-size: 18px;
            font-weight: bold;
        }

        .header .nav a {
            color: #fff;
            text-decoration: none;
            margin-left: 14px;
            font-size: 14px;
            padding: 6px 12px;
            border-radius: 6px;
        }

        .header .nav a:hover {
            background: rgba(255,255,255,0.16);
        }

        .container {
            max-width: 1100px;
            margin: 32px auto;
            padding: 0 16px;
        }

        .page-title {
            margin-bottom: 18px;
        }

        .page-title h2 {
            margin: 0 0 8px;
            font-size: 28px;
            color: #1f1f1f;
        }

        .page-title p {
            margin: 0;
            color: #8c8c8c;
            font-size: 14px;
        }

        .success-box {
            margin-bottom: 18px;
            padding: 12px 14px;
            background: #f6ffed;
            border: 1px solid #b7eb8f;
            color: #389e0d;
            border-radius: 8px;
            font-size: 14px;
        }

        .error-box {
            margin-bottom: 18px;
            padding: 12px 14px;
            background: #fff2f0;
            border: 1px solid #ffccc7;
            color: #cf1322;
            border-radius: 8px;
            font-size: 14px;
        }

        .table-card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 28px rgba(0,0,0,0.06);
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead {
            background: #fafafa;
        }

        th, td {
            padding: 14px 16px;
            border-bottom: 1px solid #f0f0f0;
            text-align: left;
            font-size: 14px;
        }

        th {
            color: #555;
        }

        tr:hover td {
            background: #fcfcfc;
        }

        .empty-box {
            padding: 28px;
            text-align: center;
            color: #999;
            font-size: 14px;
        }

        .btn {
            display: inline-block;
            text-decoration: none;
            padding: 8px 14px;
            border-radius: 6px;
            font-size: 13px;
            margin-right: 8px;
        }

        .btn-approve {
            background: #1677ff;
            color: #fff;
        }

        .btn-approve:hover {
            background: #0958d9;
        }

        .btn-reject {
            background: #fff2f0;
            color: #cf1322;
            border: 1px solid #ffccc7;
        }

        .btn-reject:hover {
            background: #fff1f0;
        }

        .tag {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 12px;
            background: #fff7e6;
            color: #d48806;
            border: 1px solid #ffd591;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台 - 管理后台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/logout">退出登录</a>
    </div>
</div>

<div class="container">
    <div class="page-title">
        <h2>用户审核</h2>
        <p>管理员可对新注册用户进行审核，通过后用户即可正常登录系统。</p>
    </div>

    <%
        String successMsg = (String) session.getAttribute("successMsg");
        if (successMsg != null) {
            session.removeAttribute("successMsg");
        }

        String sessionErrorMsg = (String) session.getAttribute("errorMsg");
        if (sessionErrorMsg != null) {
            session.removeAttribute("errorMsg");
        }

        List<User> userList = (List<User>) request.getAttribute("userList");
    %>

    <% if (successMsg != null) { %>
        <div class="success-box"><%= successMsg %></div>
    <% } %>

    <% if (sessionErrorMsg != null) { %>
        <div class="error-box"><%= sessionErrorMsg %></div>
    <% } else if (request.getAttribute("errorMsg") != null) { %>
        <div class="error-box"><%= request.getAttribute("errorMsg") %></div>
    <% } %>

    <div class="table-card">
        <% if (userList == null || userList.isEmpty()) { %>
            <div class="empty-box">当前没有待审核用户。</div>
        <% } else { %>
            <table>
                <thead>
                <tr>
                    <th>用户ID</th>
                    <th>学号/工号</th>
                    <th>真实姓名</th>
                    <th>昵称</th>
                    <th>角色</th>
                    <th>状态</th>
                    <th>操作</th>
                </tr>
                </thead>
                <tbody>
                <% for (User u : userList) { %>
                    <tr>
                        <td><%= u.getUserId() %></td>
                        <td><%= u.getStudentOrStaffNo() %></td>
                        <td><%= u.getRealName() %></td>
                        <td><%= u.getNickname() == null ? "-" : u.getNickname() %></td>
                        <td><%= u.getRoleCode() %></td>
                        <td><span class="tag"><%= u.getAccountStatus() %></span></td>
                        <td>
                            <a class="btn btn-approve"
                               href="${pageContext.request.contextPath}/admin/approve-user?userId=<%= u.getUserId() %>"
                               onclick="return confirm('确定审核通过该用户吗？');">通过</a>

                            <a class="btn btn-reject"
                               href="${pageContext.request.contextPath}/admin/reject-user?userId=<%= u.getUserId() %>"
                               onclick="return confirm('确定将该用户设为禁用吗？');">禁用</a>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</div>

</body>
</html>