<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册</title>
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
            letter-spacing: 1px;
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
            max-width: 520px;
            margin: 40px auto;
            padding: 0 16px;
        }

        .card {
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 28px rgba(0,0,0,0.06);
            overflow: hidden;
        }

        .card-header {
            padding: 24px 24px 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .card-header h2 {
            margin: 0 0 8px;
            font-size: 26px;
            color: #1f1f1f;
        }

        .card-header p {
            margin: 0;
            color: #8c8c8c;
            font-size: 14px;
        }

        .form-area {
            padding: 24px;
        }

        .form-item {
            margin-bottom: 18px;
        }

        .form-item label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: bold;
        }

        .required {
            color: #ff4d4f;
        }

        .form-item input {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #d9d9d9;
            border-radius: 8px;
            font-size: 14px;
            outline: none;
            transition: all 0.2s;
        }

        .form-item input:focus {
            border-color: #1677ff;
            box-shadow: 0 0 0 3px rgba(22,119,255,0.12);
        }

        .hint {
            margin-top: 6px;
            font-size: 12px;
            color: #999;
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

        .btn-row {
            margin-top: 22px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .btn-primary {
            background: #1677ff;
            color: white;
            border: none;
            padding: 11px 22px;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
        }

        .btn-primary:hover {
            background: #0958d9;
        }

        .btn-default {
            display: inline-block;
            text-decoration: none;
            color: #555;
            background: #fff;
            border: 1px solid #d9d9d9;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
        }

        .btn-default:hover {
            color: #1677ff;
            border-color: #1677ff;
        }

        .bottom-link {
            margin-top: 16px;
            font-size: 14px;
            color: #666;
        }

        .bottom-link a {
            color: #1677ff;
            text-decoration: none;
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/login">登录</a>
    </div>
</div>

<div class="container">
    <div class="card">
        <div class="card-header">
            <h2>用户注册</h2>
            <p>注册后即可登录平台，发布和管理自己的商品。</p>
        </div>

        <div class="form-area">
            <% if (request.getAttribute("errorMsg") != null) { %>
                <div class="error-box"><%= request.getAttribute("errorMsg") %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-item">
                    <label>学号/工号 <span class="required">*</span></label>
                    <input type="text" name="studentOrStaffNo" required
                           value="<%= request.getParameter("studentOrStaffNo") == null ? "" : request.getParameter("studentOrStaffNo") %>">
                </div>

                <div class="form-item">
                    <label>真实姓名 <span class="required">*</span></label>
                    <input type="text" name="realName" required
                           value="<%= request.getParameter("realName") == null ? "" : request.getParameter("realName") %>">
                </div>

                <div class="form-item">
                    <label>昵称</label>
                    <input type="text" name="nickname"
                           value="<%= request.getParameter("nickname") == null ? "" : request.getParameter("nickname") %>">
                </div>

                <div class="form-item">
                    <label>密码 <span class="required">*</span></label>
                    <input type="password" name="password" required>
                    <div class="hint">建议至少 6 位。</div>
                </div>

                <div class="form-item">
                    <label>确认密码 <span class="required">*</span></label>
                    <input type="password" name="confirmPassword" required>
                </div>

                <div class="btn-row">
                    <button type="submit" class="btn-primary">立即注册</button>
                    <a href="${pageContext.request.contextPath}/login" class="btn-default">返回登录</a>
                </div>
            </form>

            <div class="bottom-link">
                已有账号？<a href="${pageContext.request.contextPath}/login">去登录</a>
            </div>
        </div>
    </div>
</div>

</body>
</html>