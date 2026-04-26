<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Map<String,Object>> productList = (List<Map<String,Object>>) request.getAttribute("productList");
    if (productList == null) productList = new ArrayList<>();
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = "pending";
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg");
    session.removeAttribute("successMsg");
    // Bug B 修复：提前计算 tab 激活类，避免 class 属性中嵌入 \" 导致 Jasper 编译失败
    String tabPending = "pending".equals(tab) ? " active" : "";
    String tabOnSale  = "on_sale".equals(tab) ? " active" : "";
    String tabReject  = "rejected".equals(tab) ? " active" : "";
    boolean isPending = "pending".equals(tab);
%>
<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>商品审核 - 管理后台</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark px-4">
  <a class="navbar-brand" href="<%=request.getContextPath()%>/index.jsp">民大二手 &middot; 管理后台</a>
  <div class="d-flex gap-3">
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/admin/users">用户管理</a>
    <a class="nav-link text-white fw-bold" href="<%=request.getContextPath()%>/admin/products">商品审核</a>
    <a class="nav-link text-white" href="<%=request.getContextPath()%>/logout">退出</a>
  </div>
</nav>
<div class="container-fluid py-4 px-4">
  <h4 class="mb-3">&#128230; 商品审核</h4>
  <% if (errMsg != null) { %><div class="alert alert-danger"><%=errMsg%></div><% } %>
  <% if (sucMsg != null) { %><div class="alert alert-success"><%=sucMsg%></div><% } %>
  <ul class="nav nav-tabs mb-4">
    <li class="nav-item"><a class='nav-link<%= tabPending %>' href="?tab=pending">待审核</a></li>
    <li class="nav-item"><a class='nav-link<%= tabOnSale %>'  href="?tab=on_sale">已通过</a></li>
    <li class="nav-item"><a class='nav-link<%= tabReject %>'  href="?tab=rejected">已驳回</a></li>
  </ul>
  <% if (productList.isEmpty()) { %>
    <p class="text-muted">暂无商品</p>
  <% } else { %>
  <div class="table-responsive">
    <table class="table table-hover bg-white shadow-sm align-middle">
      <thead class="table-dark">
        <tr>
          <th>ID</th><th>封面</th><th>标题</th><th>分类</th><th>价格</th>
          <th>新旧</th><th>发布人</th><th>学号</th><th>时间</th>
          <% if (isPending) { %><th>操作</th><% } %>
        </tr>
      </thead>
      <tbody>
      <% for (Map<String,Object> p : productList) { %>
        <tr>
          <td><%=p.get("productId")%></td>
          <td>
            <% String img = (String) p.get("coverImageUrl");
               if (img != null && !img.isEmpty()) { %>
              <img src="<%=img%>" width="56" height="56" style="object-fit:cover;border-radius:6px" alt="">
            <% } else { %><span class="text-muted">无图</span><% } %>
          </td>
          <td><%=p.get("title")%></td>
          <td><%=p.get("categoryName") != null ? p.get("categoryName") : "—"%></td>
          <td>&yen;<%=p.get("price")%></td>
          <td><%=p.get("conditionLevel") != null ? p.get("conditionLevel") : "—"%></td>
          <td><%=p.get("sellerName")%></td>
          <td><%=p.get("sellerNo")%></td>
          <td><small><%=p.get("createdAt")%></small></td>
          <% if (isPending) { %>
          <td>
            <form method="post" action="<%=request.getContextPath()%>/admin/products" class="d-inline">
              <input type="hidden" name="productId" value="<%=p.get("productId")%>">
              <input type="hidden" name="tab" value="pending">
              <input type="hidden" name="action" value="approve">
              <button class="btn btn-sm btn-success">通过</button>
            </form>
            <form method="post" action="<%=request.getContextPath()%>/admin/products" class="d-inline ms-1">
              <input type="hidden" name="productId" value="<%=p.get("productId")%>">
              <input type="hidden" name="tab" value="pending">
              <input type="hidden" name="action" value="reject">
              <button class="btn btn-sm btn-danger">驳回</button>
            </form>
          </td>
          <% } %>
        </tr>
      <% } %>
      </tbody>
    </table>
  </div>
  <% } %>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
