<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg"); session.removeAttribute("successMsg");
    String uNo       = (String) request.getAttribute("u_no");       if(uNo==null) uNo="";
    String uRealName = (String) request.getAttribute("u_realName"); if(uRealName==null) uRealName="";
    String uNickname = (String) request.getAttribute("u_nickname"); if(uNickname==null) uNickname="";
    String uPhone    = (String) request.getAttribute("u_phone");    if(uPhone==null) uPhone="";
    String uEmail    = (String) request.getAttribute("u_email");    if(uEmail==null) uEmail="";
    String uRole     = (String) request.getAttribute("u_role");     if(uRole==null) uRole="";
%>
<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>个人信息 - 民大二手</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark px-4">
  <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">民大二手</a>
  <div class="d-flex gap-3">
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/orders?type=buy">我的订单</a>
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/review?view=sent">我的评价</a>
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/logout">退出</a>
  </div>
</nav>
<div class="container py-4" style="max-width:640px">
  <h4 class="mb-4">👤 个人信息</h4>
  <% if(errMsg!=null){ %><div class="alert alert-danger"><%=errMsg%></div><% } %>
  <% if(sucMsg!=null){ %><div class="alert alert-success"><%=sucMsg%></div><% } %>

  <div class="card shadow-sm mb-4">
    <div class="card-header fw-semibold">基本资料</div>
    <div class="card-body">
      <form method="post" action="<%=request.getContextPath()%>/profile">
        <div class="mb-3">
          <label class="form-label">学号 / 工号</label>
          <input type="text" class="form-control" value="<%=uNo%>" disabled>
        </div>
        <div class="mb-3">
          <label class="form-label">真实姓名</label>
          <input type="text" class="form-control" value="<%=uRealName%>" disabled>
        </div>
        <div class="mb-3">
          <label class="form-label">昵称</label>
          <input type="text" class="form-control" name="nickname"
                 value="<%=uNickname%>" maxlength="30" placeholder="设置昵称（选填）">
        </div>
        <div class="mb-3">
          <label class="form-label">手机号</label>
          <input type="tel" class="form-control" name="phone"
                 value="<%=uPhone%>" maxlength="20" placeholder="联系手机（选填）">
        </div>
        <div class="mb-3">
          <label class="form-label">邮箱</label>
          <input type="email" class="form-control" name="email"
                 value="<%=uEmail%>" maxlength="100" placeholder="联系邮箱（选填）">
        </div>
        <button type="submit" class="btn btn-primary">保存基本资料</button>
      </form>
    </div>
  </div>

  <div class="card shadow-sm">
    <div class="card-header fw-semibold">修改密码（不修改则留空）</div>
    <div class="card-body">
      <form method="post" action="<%=request.getContextPath()%>/profile">
        <input type="hidden" name="nickname" value="<%=uNickname%>">
        <input type="hidden" name="phone"    value="<%=uPhone%>">
        <input type="hidden" name="email"    value="<%=uEmail%>">
        <div class="mb-3">
          <label class="form-label">当前密码</label>
          <input type="password" class="form-control" name="oldPassword" placeholder="输入当前密码">
        </div>
        <div class="mb-3">
          <label class="form-label">新密码</label>
          <input type="password" class="form-control" name="newPassword" placeholder="6-16 位字母/数字">
        </div>
        <div class="mb-3">
          <label class="form-label">确认新密码</label>
          <input type="password" class="form-control" name="confirmPassword" placeholder="再次输入新密码">
        </div>
        <button type="submit" class="btn btn-warning">修改密码</button>
      </form>
    </div>
  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
