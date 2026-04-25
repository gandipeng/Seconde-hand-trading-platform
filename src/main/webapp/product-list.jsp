<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="com.minzu.entity.User" %>
<%
    List<Product> productList = (List<Product>) request.getAttribute("products");
    User loginUser  = (User) session.getAttribute("loginUser");
    String keyword  = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String catId    = request.getAttribute("categoryId") != null ? (String) request.getAttribute("categoryId") : "";
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int) request.getAttribute("totalPages")  : 1;
    int totalCount  = request.getAttribute("totalCount")  != null ? (int) request.getAttribute("totalCount")  : 0;

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品列表 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header {
            height: 56px; background: #1677ff; color: #fff;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }
        .header .logo { font-size: 18px; font-weight: bold; letter-spacing: 1px; }
        .header .nav a {
            color: #fff; text-decoration: none; margin-left: 14px;
            font-size: 14px; padding: 6px 12px; border-radius: 6px; transition: background 0.2s;
        }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 1200px; margin: 28px auto; padding: 0 16px 48px; }
        /* 搜索栏 */
        .search-bar {
            display: flex; gap: 10px; align-items: center;
            background: #fff; padding: 14px 20px; border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.06); margin-bottom: 22px; flex-wrap: wrap;
        }
        .search-bar input[type=text] {
            flex: 1; min-width: 180px; padding: 9px 14px; border: 1px solid #ddd;
            border-radius: 8px; font-size: 14px; outline: none; transition: border-color 0.2s;
        }
        .search-bar input[type=text]:focus { border-color: #1677ff; }
        .search-bar button {
            padding: 9px 22px; background: #1677ff; color: #fff; border: none;
            border-radius: 8px; font-size: 14px; cursor: pointer; transition: background 0.2s;
        }
        .search-bar button:hover { background: #0958d9; }
        .search-bar a.reset {
            padding: 9px 16px; color: #666; font-size: 14px; text-decoration: none;
            border: 1px solid #ddd; border-radius: 8px; transition: all 0.2s;
        }
        .search-bar a.reset:hover { border-color: #1677ff; color: #1677ff; }
        /* 工具栏 */
        .toolbar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 18px;
        }
        .result-info { font-size: 14px; color: #888; }
        .publish-btn {
            display: inline-block; background: #1677ff; color: white;
            text-decoration: none; padding: 10px 18px;
            border-radius: 8px; font-size: 14px; transition: background 0.2s;
        }
        .publish-btn:hover { background: #0958d9; }
        /* 卡片网格 */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }
        .product-card {
            background: #fff; border-radius: 14px; overflow: hidden;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .product-card:hover { transform: translateY(-4px); box-shadow: 0 12px 28px rgba(0,0,0,0.09); }
        .product-image { width: 100%; height: 180px; object-fit: cover; display: block; background: #f0f2f5; }
        .no-image {
            width: 100%; height: 180px; background: #f0f2f5; color: #999;
            display: flex; align-items: center; justify-content: center; font-size: 14px;
        }
        .card-body { padding: 16px; }
        .product-title { margin: 0 0 10px; font-size: 17px; color: #1f1f1f; line-height: 1.4; min-height: 48px; }
        .price { color: #ff4d4f; font-size: 22px; font-weight: bold; margin-bottom: 10px; }
        .meta { color: #666; font-size: 13px; line-height: 1.9; margin-bottom: 12px; }
        .action-row { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 8px; align-items: center; }
        .detail-link {
            display: inline-block; color: #1677ff; text-decoration: none;
            font-size: 14px; font-weight: bold;
        }
        .detail-link:hover { text-decoration: underline; }
        .delete-btn {
            background: #fff1f0; color: #cf1322; border: 1px solid #ffccc7;
            padding: 7px 12px; border-radius: 6px; font-size: 13px; cursor: pointer; transition: all 0.2s;
        }
        .delete-btn:hover { background: #ffe7e6; }
        /* 消息 */
        .msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .msg-success { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .msg-error   { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
        /* 空状态 */
        .empty-box {
            background: #fff; border-radius: 14px; padding: 60px 20px;
            text-align: center; color: #999; box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }
        .empty-icon { font-size: 48px; margin-bottom: 12px; }
        /* 分页 */
        .pagination {
            display: flex; justify-content: center; align-items: center;
            gap: 8px; margin-top: 36px; flex-wrap: wrap;
        }
        .page-btn {
            min-width: 36px; height: 36px; padding: 0 10px;
            border-radius: 8px; border: 1px solid #ddd;
            background: #fff; color: #555; text-decoration: none;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 14px; transition: all 0.18s;
        }
        .page-btn:hover { border-color: #1677ff; color: #1677ff; }
        .page-btn.active { background: #1677ff; color: #fff; border-color: #1677ff; }
        .page-btn.disabled { pointer-events: none; color: #bbb; border-color: #eee; }
        .page-info { font-size: 13px; color: #999; }
        @media (max-width: 768px) {
            .header { padding: 0 14px; }
            .grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 480px) {
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <% if (loginUser != null) { %>
            <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
            <a href="${pageContext.request.contextPath}/orders">我的订单</a>
            <a href="${pageContext.request.contextPath}/messages">私信</a>
            <a href="${pageContext.request.contextPath}/my-favorites">我的收藏</a>
            <a href="${pageContext.request.contextPath}/logout">退出</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login">登录</a>
        <% } %>
    </div>
</div>

<div class="container">

    <% if (successMsg != null) { %>
        <div class="msg msg-success">✅ <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="msg msg-error">❌ <%= errorMsg %></div>
    <% } %>

    <%-- 搜索栏 --%>
    <form class="search-bar" method="get" action="${pageContext.request.contextPath}/product-list">
        <input type="text" name="keyword" placeholder="搜索商品名称…"
               value="<%= keyword != null ? keyword : "" %>">
        <button type="submit">🔍 搜索</button>
        <% if (keyword != null && !keyword.isEmpty()) { %>
            <a class="reset" href="${pageContext.request.contextPath}/product-list">重置</a>
        <% } %>
    </form>

    <div class="toolbar">
        <span class="result-info">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                “<strong><%= keyword %></strong>” 的搜索结果，共 <%= totalCount %> 件商品
            <% } else { %>
                全部商品，共 <%= totalCount %> 件
            <% } %>
        </span>
        <a class="publish-btn" href="${pageContext.request.contextPath}/publish-product">+ 发布商品</a>
    </div>

    <% if (productList != null && !productList.isEmpty()) { %>
        <div class="grid">
        <% for (Product p : productList) {
               boolean canDelete = false;
               if (loginUser != null) {
                   boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
                   boolean isOwner = loginUser.getUserId() == p.getSellerId();
                   canDelete = isAdmin || isOwner;
               }
        %>
            <div class="product-card">
                <% if (p.getCoverImageUrl() != null && !"".equals(p.getCoverImageUrl())) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="商品封面" class="product-image" loading="lazy">
                <% } else { %>
                    <div class="no-image">暂无图片</div>
                <% } %>
                <div class="card-body">
                    <h3 class="product-title"><%= p.getTitle() %></h3>
                    <div class="price">¥ <%= p.getPrice() %></div>
                    <div class="meta">
                        成色：<%= p.getConditionLevel() != null ? p.getConditionLevel() : "未填写" %><br>
                        分类：<%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %><br>
                        卖家：<%= p.getSellerName() != null ? p.getSellerName() : "未知卖家" %>
                    </div>
                    <div class="action-row">
                        <a class="detail-link"
                           href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>">
                            查看详情
                        </a>
                        <% if (canDelete) { %>
                            <form action="${pageContext.request.contextPath}/delete-product"
                                  method="post" style="margin:0;"
                                  onsubmit="return confirm('确定要删除这个商品吗？');">
                                <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                <button type="submit" class="delete-btn">删除</button>
                            </form>
                        <% } %>
                    </div>
                </div>
            </div>
        <% } %>
        </div>

        <%-- 分页导航 --%>
        <% if (totalPages > 1) {
               String kw = (keyword != null && !keyword.isEmpty()) ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "";
               String ci = (catId != null && !catId.isEmpty()) ? "&categoryId=" + catId : "";
               String baseUrl = request.getContextPath() + "/product-list?" + kw.replaceFirst("^&", "") + ci;
               // 修正拼接逻辑：确保基础 URL 正确
               String sep = (kw.isEmpty() && ci.isEmpty()) ? "" : "&";
        %>
        <div class="pagination">
            <a class="page-btn <%= currentPage == 1 ? "disabled" : "" %>"
               href="<%= request.getContextPath() %>/product-list?page=<%= currentPage - 1 %><%= kw %><%= ci %>">&laquo;</a>

            <% int startP = Math.max(1, currentPage - 2);
               int endP   = Math.min(totalPages, currentPage + 2);
               if (startP > 1) { %>
                <a class="page-btn" href="<%= request.getContextPath() %>/product-list?page=1<%= kw %><%= ci %>">1</a>
                <% if (startP > 2) { %><span style="color:#bbb">…</span><% } %>
            <% }
               for (int pp = startP; pp <= endP; pp++) { %>
                <a class="page-btn <%= pp == currentPage ? "active" : "" %>"
                   href="<%= request.getContextPath() %>/product-list?page=<%= pp %><%= kw %><%= ci %>"><%= pp %></a>
            <% }
               if (endP < totalPages) { %>
                <% if (endP < totalPages - 1) { %><span style="color:#bbb">…</span><% } %>
                <a class="page-btn" href="<%= request.getContextPath() %>/product-list?page=<%= totalPages %><%= kw %><%= ci %>"><%= totalPages %></a>
            <% } %>

            <a class="page-btn <%= currentPage == totalPages ? "disabled" : "" %>"
               href="<%= request.getContextPath() %>/product-list?page=<%= currentPage + 1 %><%= kw %><%= ci %>">&raquo;</a>

            <span class="page-info">共 <%= totalCount %> 件 / 第 <%= currentPage %> 页 / 共 <%= totalPages %> 页</span>
        </div>
        <% } %>

    <% } else { %>
        <div class="empty-box">
            <div class="empty-icon">🛒</div>
            <div><% if (keyword != null && !keyword.isEmpty()) { %>
                没有找到匹配“<strong><%= keyword %></strong>”的商品
            <% } else { %>当前暂无商品，快去发布第一件商品吧。<% } %></div>
        </div>
    <% } %>
</div>

</body>
</html>
