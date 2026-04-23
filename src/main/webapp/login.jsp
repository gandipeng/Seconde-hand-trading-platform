<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>用户登录 - 民大二手交易平台</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f5f7fa;
        }
        .login-box {
            width: 360px;
            margin: 100px auto;
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
        }
        input {
            width: 100%;
            height: 38px;
            margin: 10px 0;
            padding: 0 10px;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            height: 40px;
            background: #1677ff;
            color: white;
            border: none;
            cursor: pointer;
        }
        .error {
            color: red;
            text-align: center;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<div class="login-box">
    <h2>民大二手交易平台登录</h2>

    <%
        String errorMsg = (String) request.getAttribute("errorMsg");
        if (errorMsg != null) {
    %>
        <div class="error"><%= errorMsg %></div>
    <%
        }
    %>

    <form action="${pageContext.request.contextPath}/login" method="post">
        <input type="text" name="account" placeholder="请输入学号/工号" required />
        <input type="password" name="password" placeholder="请输入密码" required />
        <button type="submit">登录</button>
    </form>
</div>
</body>
</html>