<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="com.minzu.entity.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品列表</title>
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
            transition: background 0.2s;
        }

        .header .nav a:hover {
            background: rgba(255,255,255,0.16);
        }

        .container {
            max-width: 1200px;
            margin: 28px auto;
            padding: 0 16px;
        }

        .page-title {
            margin-bottom: 18px;
        }

        .page-title h2 {
            margin: 0 0 6px;
            font-size: 28px;
            color: #1f1f1f;
        }

        .page-title p {
            margin: 0;
            color: #8c8c8c;
            font-size: 14px;
        }

        .toolbar {
            margin-bottom: 20px;
            display: flex;
            justify-content: flex-end;
        }

        .publish-btn {
            display: inline-block;
            background: #1677ff;
            color: white;
            text-decoration: none;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 14px;
            transition: background 0.2s;
        }

        .publish-btn:hover {
            background: #0958d9;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }

        .product-card {
            background: #fff;
            border-radius: 14px;
            overflow: hidden;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .product-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 28px rgba(0,0,0,0.09);
        }

        .product-image {
            width: 100%;
            height: 180px;
            object-fit: cover;
            display: block;
            background: #f0f2f5;
        }

        .no-image {
            width: 100%;
            height: 180px;
            background: #f0f2f5;
            color: #999;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .card-body {
            padding: 16px;
        }

        .product-title {
            margin: 0 0 10px;
            font-size: 18px;
            color: #1f1f1f;
            line-height: 1.4;
            min-height: 50px;
        }

        .price {
            color: #ff4d4f;
            font-size: 22px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .meta {
            color: #666;
            font-size: 13px;
            line-height: 1.8;
            margin-bottom: 12px;
        }

        .action-row {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 8px;
            align-items: center;
        }

        .detail-link {
            display: inline-block;
            color: #1677ff;
            text-decoration: none;
            font-size: 14px;
            font-weight: bold;
        }

        .detail-link:hover {
            text-decoration: underline;
        }

        .delete-form {
            display: inline-block;
            margin: 0;
        }

        .delete-btn {
            background: #fff1f0;
            color: #cf1322;
            border: 1px solid #ffccc7;
            padding: 7px 12px;
            border-radius: 6px;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .delete-btn:hover {
            background: #ffe7e6;
        }

        .success-box {
            margin-bottom: 18px;
            padding: 12px 16px;
            background: #f6ffed;
            border: 1px solid #b7eb8f;
            color: #389e0d;
            border-radius: 10px;
            font-size: 14px;
            box-shadow: 0 4px 12px rgba(56, 158, 13, 0.06);
        }
        .empty-box {
            background: #fff;
            border-radius: 14px;
            padding: 48px 20px;
            text-align: center;
            color: #999;
            box-shadow: 0 8px 24px rgba(0,0,0,0.05);
        }

        @media (max-width: 768px) {
            .header {
                padding: 0 14px;
            }

            .header .logo {
                font-size: 16px;
            }

            .header .nav a {
                margin-left: 8px;
                padding: 4px 8px;
                font-size: 13px;
            }

            .page-title h2 {
                font-size: 24px;
            }

            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/publish-product">发布商品</a>
    </div>
</div>

<div class="container">
    <%
           String successMsg = (String) session.getAttribute("successMsg");
           if (successMsg != null) {
               session.removeAttribute("successMsg");
           }
    %>

    <% if (successMsg != null) { %>
           <div class="success-box"><%= successMsg %></div>
    <% } %>
    <div class="page-title">
        <h2>商品列表</h2>
        <p>浏览平台当前在售的二手商品，点击即可查看详情。</p>
    </div>

    <div class="toolbar">
        <a class="publish-btn" href="${pageContext.request.contextPath}/publish-product">+ 发布商品</a>
    </div>

    <%
        // 如果你的 Servlet 里是 request.setAttribute("productList", productList);
        // 就把下面这一行改成：request.getAttribute("productList")
        List<Product> productList = (List<Product>) request.getAttribute("products");
        User loginUser = (User) session.getAttribute("loginUser");

        if (productList != null && !productList.isEmpty()) {
    %>
        <div class="grid">
            <%
                for (Product p : productList) {
                    boolean canDelete = false;
                    if (loginUser != null) {
                        boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
                        boolean isOwner = loginUser.getUserId() == p.getSellerId();
                        canDelete = isAdmin || isOwner;
                    }
            %>
                <div class="product-card">
                    <% if (p.getCoverImageUrl() != null && !"".equals(p.getCoverImageUrl())) { %>
                        <img src="<%= p.getCoverImageUrl() %>" alt="商品封面" class="product-image"/>
                    <% } else { %>
                        <div class="no-image">暂无图片</div>
                    <% } %>

                    <div class="card-body">
                        <h3 class="product-title"><%= p.getTitle() %></h3>

                        <div class="price">¥ <%= p.getPrice() %></div>

                        <div class="meta">
                            成色：<%= p.getConditionLevel() != null ? p.getConditionLevel() : "未填写" %><br/>
                            分类：<%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %><br/>
                            卖家：<%= p.getSellerName() != null ? p.getSellerName() : "未知卖家" %>
                        </div>

                        <div class="action-row">
                            <a class="detail-link"
                               href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>">
                                查看详情
                            </a>

                            <% if (canDelete) { %>
                                <form action="${pageContext.request.contextPath}/delete-product"
                                      method="post"
                                      class="delete-form"
                                      onsubmit="return confirm('确定要删除这个商品吗？');">
                                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                    <button type="submit" class="delete-btn">删除商品</button>
                                </form>
                            <% } %>
                        </div>
                    </div>
                </div>
            <%
                }
            %>
        </div>
    <%
        } else {
    %>
        <div class="empty-box">
            当前暂无商品，快去发布第一件商品吧。
        </div>
    <%
        }
    %>
</div>

</body>
</html>