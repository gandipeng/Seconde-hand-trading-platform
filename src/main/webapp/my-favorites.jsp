<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Product> favoriteList = (List<Product>) request.getAttribute("favoriteList");

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的收藏 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }

        .header {
            height: 56px; background: #1677ff; color: white;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }
        .logo { font-size: 18px; font-weight: bold; }
        .nav a {
            color: white; text-decoration: none; margin-left: 14px;
            font-size: 14px; padding: 6px 12px; border-radius: 6px;
        }
        .nav a:hover { background: rgba(255,255,255,0.16); }

        .container { max-width: 1100px; margin: 32px auto; padding: 0 16px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .page-header h2 { margin: 0; font-size: 24px; }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: 20px;
        }

        .product-card {
            background: #fff; border-radius: 12px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.06);
            overflow: hidden; display: flex; flex-direction: column;
            transition: box-shadow 0.2s, transform 0.15s;
        }
        .product-card:hover { box-shadow: 0 6px 20px rgba(0,0,0,0.1); transform: translateY(-2px); }

        .card-cover { position: relative; }
        .card-cover img { width: 100%; height: 180px; object-fit: cover; background: #f0f0f0; display: block; }
        .no-cover { width: 100%; height: 180px; background: #f0f2f5; display: flex; align-items: center; justify-content: center; font-size: 36px; color: #ccc; }

        /* 已售出蒙层 */
        .sold-mask {
            position: absolute; inset: 0;
            background: rgba(0,0,0,0.45);
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 20px; font-weight: bold; letter-spacing: 2px;
            pointer-events: none;
        }

        .card-body { padding: 14px; flex: 1; display: flex; flex-direction: column; gap: 5px; }
        .card-title { font-size: 15px; font-weight: bold; margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .card-meta { font-size: 12px; color: #999; }
        .card-price { font-size: 17px; font-weight: bold; color: #ff4d4f; }
        .card-price span { font-size: 12px; font-weight: normal; color: #bbb; text-decoration: line-through; margin-left: 6px; }

        .card-actions {
            padding: 10px 14px; border-top: 1px solid #f0f0f0;
            display: flex; gap: 8px;
        }
        .btn {
            display: inline-block; padding: 7px 14px; border-radius: 6px;
            text-decoration: none; font-size: 13px; border: none; cursor: pointer;
            transition: all 0.15s;
        }
        .btn-ghost { background: #f5f5f5; color: #333; border: 1px solid #d9d9d9; }
        .btn-ghost:hover { background: #e8f4ff; color: #1677ff; border-color: #91caff; }
        .btn-unfav { background: #fff1f0; color: #cf1322; border: 1px solid #ffccc7; }
        .btn-unfav:hover { background: #ffe7e6; }

        .empty-box { text-align: center; padding: 60px 20px; color: #aaa; }
        .empty-box .icon { font-size: 52px; margin-bottom: 12px; }
        .empty-box p { font-size: 15px; margin: 0 0 20px; }
        .btn-primary { background: #1677ff; color: white; padding: 10px 24px; border-radius: 8px; text-decoration: none; font-size: 14px; }
        .btn-primary:hover { background: #0958d9; }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">浏览商品</a>
        <a href="${pageContext.request.contextPath}/my-favorites" style="background:rgba(255,255,255,0.2);">我的收藏</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/messages">私信</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <div class="page-header">
        <h2>❤️ 我的收藏</h2>
        <span style="font-size:14px;color:#999;">共 <%= favoriteList != null ? favoriteList.size() : 0 %> 件商品</span>
    </div>

    <% if (successMsg != null) { %>
        <div style="background:#f6ffed;border:1px solid #b7eb8f;color:#389e0d;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:14px;">
            <%= successMsg %>
        </div>
    <% } %>

    <% if (favoriteList == null || favoriteList.isEmpty()) { %>
        <div class="empty-box">
            <div class="icon">❤️</div>
            <p>还没有收藏任何商品</p>
            <a href="${pageContext.request.contextPath}/product-list" class="btn-primary">去逐郊商品</a>
        </div>
    <% } else { %>
        <div class="product-grid">
        <% for (Product p : favoriteList) {
            boolean isSold = "SOLD".equals(p.getProductStatus());
            boolean isOffline = "OFFLINE".equals(p.getProductStatus());
        %>
            <div class="product-card" id="card-<%= p.getProductId() %>">
                <div class="card-cover">
                    <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                        <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" loading="lazy">
                    <% } else { %>
                        <div class="no-cover">📦</div>
                    <% } %>
                    <% if (isSold) { %><div class="sold-mask">已售出</div><% } %>
                    <% if (isOffline) { %><div class="sold-mask" style="background:rgba(0,0,0,0.3);">已下架</div><% } %>
                </div>

                <div class="card-body">
                    <p class="card-title" title="<%= p.getTitle() %>"><%= p.getTitle() %></p>
                    <div class="card-price">
                        ¥<%= p.getPrice() %>
                        <% if (p.getOriginalPrice() != null) { %>
                            <span>¥<%= p.getOriginalPrice() %></span>
                        <% } %>
                    </div>
                    <div class="card-meta">
                        <%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %>
                        &nbsp;·&nbsp; <%= p.getSellerName() != null ? p.getSellerName() : "未知" %>
                    </div>
                </div>

                <div class="card-actions">
                    <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>"
                       class="btn btn-ghost">查看详情</a>
                    <button class="btn btn-unfav" onclick="unfavorite(<%= p.getProductId() %>, this)">
                        取消收藏
                    </button>
                </div>
            </div>
        <% } %>
        </div>
    <% } %>
</div>

<script>
function unfavorite(productId, btn) {
    if (!confirm('确定取消收藏吗？')) return;
    btn.disabled = true;
    btn.textContent = '处理中…';

    var form = new FormData();
    form.append('productId', productId);

    fetch('${pageContext.request.contextPath}/favorite', {
        method: 'POST',
        body: form
    })
    .then(function(r){ return r.json(); })
    .then(function(data){
        if (data.success) {
            var card = document.getElementById('card-' + productId);
            if (card) {
                card.style.transition = 'opacity 0.3s, transform 0.3s';
                card.style.opacity = '0';
                card.style.transform = 'scale(0.95)';
                setTimeout(function(){ card.remove(); }, 320);
            }
        } else {
            alert(data.msg || '操作失败');
            btn.disabled = false;
            btn.textContent = '取消收藏';
        }
    })
    .catch(function(){
        alert('网络错误，请重试');
        btn.disabled = false;
        btn.textContent = '取消收藏';
    });
}
</script>

</body>
</html>
