<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.minzu.entity.Review" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) reviews = new ArrayList<>();
    String view = (String) request.getAttribute("view");
    if (view == null) view = "sent";
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg");
    session.removeAttribute("successMsg");
    // Bug C 修复：提前计算 active 类，避免 class 属性中嵌入 \" 导致 Jasper 编译失败
    String sentActive     = "sent".equals(view)     ? " active" : "";
    String receivedActive = "received".equals(view) ? " active" : "";
%>
<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>我的评价 - 民大二手</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark px-4">
  <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">民大二手</a>
  <div class="d-flex gap-3">
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/orders?type=buy">我的订单</a>
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/profile">个人信息</a>
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/logout">退出</a>
  </div>
</nav>
<div class="container py-4" style="max-width:860px">
  <h4 class="mb-3">&#11088; 我的评价</h4>
  <% if (errMsg != null) { %><div class="alert alert-danger"><%=errMsg%></div><% } %>
  <% if (sucMsg != null) { %><div class="alert alert-success"><%=sucMsg%></div><% } %>
  <ul class="nav nav-tabs mb-4">
    <li class="nav-item">
      <a class='nav-link<%= sentActive %>' href="<%=request.getContextPath()%>/review?view=sent">我发出的评价</a>
    </li>
    <li class="nav-item">
      <a class='nav-link<%= receivedActive %>' href="<%=request.getContextPath()%>/review?view=received">收到的评价</a>
    </li>
  </ul>
  <% if (reviews.isEmpty()) { %>
    <div class="text-center text-muted py-5"><p>暂无评价记录</p></div>
  <% } else { %>
    <% for (Review r : reviews) { %>
    <div class="card mb-3 shadow-sm">
      <div class="card-body">
        <div class="d-flex justify-content-between align-items-start">
          <div>
            <span class="fw-semibold"><%=r.getProductTitle() != null ? r.getProductTitle() : "已删除商品"%></span>
            <span class="badge bg-secondary ms-2"><%="BUYER".equals(r.getRole()) ? "买家评价" : "卖家评价"%></span>
          </div>
          <div class="text-warning">
            <% for (int i = 0; i < r.getScore(); i++) { %>&#9733;<% } %>
            <% for (int i = r.getScore(); i < 5; i++) { %><span class="text-muted">&#9733;</span><% } %>
          </div>
        </div>
        <% if (r.getContent() != null && !r.getContent().isEmpty()) { %>
          <p class="mt-2 mb-1"><%=r.getContent()%></p>
        <% } %>
        <small class="text-muted">
          <% if ("sent".equals(view)) { %>评价对象：<%=r.getReviewedName()%>
          <% } else { %>评价人：<%=r.getReviewerName()%><% } %>
          &nbsp;&middot;&nbsp;<%=r.getCreatedAt()%>
        </small>
      </div>
    </div>
    <% } %>
  <% } %>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
