<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%!
    private String statusText(String status) {
        if ("ON_SALE".equals(status)) return "在售";
        if ("OFF_SHELF".equals(status)) return "已下架";
        if ("SOLD".equals(status)) return "已售出";
        if ("PENDING_REVIEW".equals(status)) return "待审核";
        if ("REJECTED".equals(status)) return "已驳回";
        return status == null ? "-" : status;
    }
%>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");

    List<Product> productList = (List<Product>) request.getAttribute("productList");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "";

%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的商品</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header {
            background: #1677ff; color: white; padding: 14px 24px;
            display: flex; justify-content: space-between; align-items: center;
        }
        .logo { font-size: 18px; font-weight: bold; }
        .nav a {
            color: white; text-decoration: none; margin-left: 16px;
            font-size: 14px; padding: 6px 10px; border-radius: 6px;
        }
        .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 1100px; margin: 32px auto; padding: 0 16px; }
        .page-header {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 20px; flex-wrap: wrap; gap: 12px;
        }
        .page-header h2 { margin: 0; font-size: 24px; }
        .btn {
            display: inline-block; padding: 10px 22px; border-radius: 6px;
            text-decoration: none; font-size: 14px; color: white;
            background: #1677ff; border: none; cursor: pointer;
        }
        .btn:hover { background: #0958d9; }
        .btn-sm { padding: 6px 14px; font-size: 13px; }
        .btn-ghost {
            background: #f5f5f5; color: #333;
            border: 1px solid #d9d9d9;
        }
        .btn-ghost:hover { background: #e8f4ff; color: #1677ff; border-color: #91caff; }
        .btn-warning { background: #fa8c16; }
        .btn-warning:hover { background: #d46b08; }
        .btn-success { background: #52c41a; }
        .btn-success:hover { background: #389e0d; }
        .filter-bar {
            display: flex; gap: 8px; margin-bottom: 20px; flex-wrap: wrap;
        }
        .filter-bar a {
            padding: 6px 16px; border-radius: 20px; text-decoration: none;
            font-size: 13px; background: #fff; color: #555;
            border: 1px solid #d9d9d9;
        }
        .filter-bar a:hover { border-color: #1677ff; color: #1677ff; }
        .filter-bar a.active { background: #1677ff; color: white; border-color: #1677ff; }
        .msg-box {
            margin-bottom: 16px; padding: 12px 16px;
            border-radius: 8px; font-size: 14px;
        }
        .msg-success { background: #f6ffed; border: 1px solid #b7eb8f; color: #389e0d; }
        .msg-error   { background: #fff2f0; border: 1px solid #ffccc7; color: #cf1322; }
        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }
        .product-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            overflow: hidden; display: flex; flex-direction: column;
        }
        .product-card img {
            width: 100%; height: 180px; object-fit: cover;
            background: #f0f0f0;
        }
        .card-body { padding: 14px; flex: 1; display: flex; flex-direction: column; gap: 6px; }
        .card-title {
            font-size: 15px; font-weight: bold; margin: 0;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .card-meta { font-size: 12px; color: #999; }
        .card-price {
            font-size: 17px; font-weight: bold; color: #ff4d4f; margin-top: 2px;
        }
        .card-price span {
            font-size: 12px; font-weight: normal; color: #bbb;
            text-decoration: line-through; margin-left: 6px;
        }
        .card-status {
            display: inline-block; padding: 3px 10px; border-radius: 999px;
            font-size: 12px; font-weight: 500; margin-bottom: 4px;
        }
        .status-ON_SALE        { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .status-OFF_SHELF      { background: #f5f5f5; color: #8c8c8c; border: 1px solid #d9d9d9; }
        .status-SOLD           { background: #fff7e6; color: #d48806; border: 1px solid #ffd591; }
        .status-PENDING_REVIEW { background: #e6f4ff; color: #1677ff; border: 1px solid #91caff; }
        .status-REJECTED       { background: #fff1f0; color: #cf1322; border: 1px solid #ffccc7; }
        .card-actions {
            padding: 10px 14px; border-top: 1px solid #f0f0f0;
            display: flex; gap: 8px; flex-wrap: wrap;
        }
        .empty-box {
            text-align: center; padding: 60px 20px; color: #aaa;
        }
        .empty-box p { margin: 12px 0 20px; font-size: 15px; }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">浏览商品</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <% if ("ADMIN".equals(loginUser.getRoleCode())) { %>
            <a href="${pageContext.request.contextPath}/admin/user-review">用户审核</a>
        <% } %>
        <a href="${pageContext.request.contextPath}/logout">退出登录</a>
    </div>
</div>

<div class="container">
    <div class="page-header">
        <h2>我的商品</h2>
        <a href="${pageContext.request.contextPath}/publish-product" class="btn">发布商品</a>
    </div>

    <% if (successMsg != null) { %>
        <div class="msg-box msg-success"><%= successMsg %></div>
    <% } %>
    <% if (sessionErrorMsg != null) { %>
        <div class="msg-box msg-error"><%= sessionErrorMsg %></div>
    <% } else if (request.getAttribute("errorMsg") != null) { %>
        <div class="msg-box msg-error"><%= request.getAttribute("errorMsg") %></div>
    <% } %>

    <div class="filter-bar">
        <a href="${pageContext.request.contextPath}/my-products"
           class="<%= "".equals(statusFilter) ? "active" : "" %>">全部</a>
        <a href="${pageContext.request.contextPath}/my-products?status=ON_SALE"
           class="<%= "ON_SALE".equals(statusFilter) ? "active" : "" %>">在售</a>
        <a href="${pageContext.request.contextPath}/my-products?status=OFF_SHELF"
           class="<%= "OFF_SHELF".equals(statusFilter) ? "active" : "" %>">已下架</a>
        <a href="${pageContext.request.contextPath}/my-products?status=SOLD"
           class="<%= "SOLD".equals(statusFilter) ? "active" : "" %>">已售出</a>
        <a href="${pageContext.request.contextPath}/my-products?status=PENDING_REVIEW"
           class="<%= "PENDING_REVIEW".equals(statusFilter) ? "active" : "" %>">待审核</a>
        <a href="${pageContext.request.contextPath}/my-products?status=REJECTED"
           class="<%= "REJECTED".equals(statusFilter) ? "active" : "" %>">已驳回</a>
    </div>

    <% if (productList == null || productList.isEmpty()) { %>
        <div class="empty-box">
            <div style="font-size:48px;">📦</div>
            <p>你还没有发布任何商品</p>
            <a href="${pageContext.request.contextPath}/publish-product" class="btn">立即发布</a>
        </div>
    <% } else { %>
        <div class="product-grid">
        <% for (Product p : productList) { %>
            <div class="product-card">
                <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" loading="lazy">
                <% } else { %>
                    <div style="width:100%;height:180px;background:#f0f2f5;display:flex;align-items:center;justify-content:center;color:#ccc;font-size:32px;">📷</div>
                <% } %>

                <div class="card-body">
                    <p class="card-title" title="<%= p.getTitle() %>"><%= p.getTitle() %></p>
                    <div>
                        <span class="card-status status-<%= p.getProductStatus() %>">
                            <%= statusText(p.getProductStatus()) %>
                        </span>
                    </div>
                    <div class="card-price">
                        ¥<%= p.getPrice() %>
                        <% if (p.getOriginalPrice() != null) { %>
                            <span>¥<%= p.getOriginalPrice() %></span>
                        <% } %>
                    </div>
                    <div class="card-meta">
                        <%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %>
                        &nbsp;·&nbsp; 浏览 <%= p.getViewCount() %> 次
                        &nbsp;·&nbsp; <%= p.getCreatedAt() != null ? p.getCreatedAt().toString().substring(0, 10) : "" %>
                    </div>
                </div>

                <div class="card-actions">
                    <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>"
                       class="btn btn-sm btn-ghost">查看详情</a>

                    <% if (!"SOLD".equals(p.getProductStatus())) { %>
                        <a href="${pageContext.request.contextPath}/edit-product?id=<%= p.getProductId() %>"
                           class="btn btn-sm btn-ghost" style="color:#1677ff;border-color:#91caff;">编辑</a>
                    <% } %>

                    <% if ("ON_SALE".equals(p.getProductStatus())) { %>
                        <form method="post" action="${pageContext.request.contextPath}/my-products" style="margin:0;">
                            <input type="hidden" name="action" value="offshelf">
                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                            <button type="submit" class="btn btn-sm btn-warning"
                                onclick="return confirm('确定下架该商品吗？');">下架</button>
                        </form>
                    <% } else if ("OFF_SHELF".equals(p.getProductStatus())) { %>
                        <form method="post" action="${pageContext.request.contextPath}/my-products" style="margin:0;">
                            <input type="hidden" name="action" value="onshelf">
                            <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                            <button type="submit" class="btn btn-sm btn-success"
                                onclick="return confirm('确定重新上架该商品吗？');">重新上架</button>
                        </form>
                    <% } %>
                </div>
            </div>
        <% } %>
        </div>
    <% } %>
</div>

</body>
</html>
