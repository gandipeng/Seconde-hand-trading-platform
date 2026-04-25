<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    Object orderIdObj    = request.getAttribute("orderId");
    Object productTitleObj = request.getAttribute("productTitle");
    Object roleObj       = request.getAttribute("role");
    int orderId = orderIdObj != null ? (int)orderIdObj : 0;
    String productTitle  = productTitleObj != null ? productTitleObj.toString() : "";
    String role          = roleObj != null ? roleObj.toString() : "BUYER";
%>
<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>评价交易 - 民大二手</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
<style>
  body{background:#f8f9fa;}
  .star-group label{font-size:2rem;color:#ccc;cursor:pointer;transition:color .15s;}
  .star-group input[type=radio]{display:none;}
  .star-group input[type=radio]:checked ~ label,
  .star-group label:hover,
  .star-group label:hover ~ label{color:#ffc107;}
  .star-group{display:flex;flex-direction:row-reverse;justify-content:flex-end;}
</style>
</head>
<body>
<nav class="navbar navbar-dark bg-dark px-4">
  <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">民大二手</a>
  <div class="d-flex gap-3">
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/orders?type=buy">我的订单</a>
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/logout">退出</a>
  </div>
</nav>
<div class="container py-5" style="max-width:600px">
  <h4 class="mb-4">📝 评价交易</h4>
  <div class="card shadow-sm mb-4">
    <div class="card-body">
      <p class="text-muted mb-1">商品：<strong><%=productTitle%></strong></p>
      <p class="text-muted">你的身份：<span class="badge bg-primary"><%="BUYER".equals(role)?"买家":"卖家"%></span></p>
    </div>
  </div>
  <form method="post" action="<%=request.getContextPath()%>/review">
    <input type="hidden" name="orderId" value="<%=orderId%>">
    <div class="mb-4">
      <label class="form-label fw-semibold">评分（必填）</label>
      <div class="star-group">
        <input type="radio" id="s5" name="score" value="5"><label for="s5">★</label>
        <input type="radio" id="s4" name="score" value="4"><label for="s4">★</label>
        <input type="radio" id="s3" name="score" value="3" checked><label for="s3">★</label>
        <input type="radio" id="s2" name="score" value="2"><label for="s2">★</label>
        <input type="radio" id="s1" name="score" value="1"><label for="s1">★</label>
      </div>
    </div>
    <div class="mb-4">
      <label class="form-label fw-semibold">评价内容（可选）</label>
      <textarea class="form-control" name="content" rows="4" maxlength="300"
        placeholder="分享你的交易体验..."></textarea>
    </div>
    <div class="d-flex gap-2">
      <button type="submit" class="btn btn-primary px-4">提交评价</button>
      <a href="<%=request.getContextPath()%>/orders?type=buy" class="btn btn-outline-secondary">返回订单</a>
    </div>
  </form>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
