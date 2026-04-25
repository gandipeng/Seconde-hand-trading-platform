<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.User" %>
<%
    Product product = (Product) request.getAttribute("product");
    List<String> detailImages = (List<String>) request.getAttribute("detailImages");
    User loginUser = (User) session.getAttribute("loginUser");

    boolean canDelete = false;
    boolean isOwner = false;
    boolean isFavorited = false;
    if (loginUser != null && product != null) {
        boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
        isOwner = loginUser.getUserId() == product.getSellerId();
        canDelete = isAdmin || isOwner;
        Boolean favAttr = (Boolean) request.getAttribute("isFavorited");
        isFavorited = favAttr != null && favAttr;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>商品详情 - 民大二手交易平台</title>
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

        .container { max-width: 1180px; margin: 28px auto; padding: 0 16px 32px; }
        .back-bar { margin-bottom: 16px; }
        .back-bar a { color: #1677ff; text-decoration: none; font-size: 14px; }

        .detail-card { background: #fff; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.06); overflow: hidden; }
        .detail-main { display: grid; grid-template-columns: 1.05fr 0.95fr; gap: 28px; padding: 24px; }
        .gallery-box { min-width: 0; }
        .main-image-wrap { width: 100%; background: #f3f5f7; border-radius: 14px; overflow: hidden; border: 1px solid #eef0f3; }
        .main-image { width: 100%; height: 440px; object-fit: cover; display: block; cursor: zoom-in; background: #f0f2f5; }

        .thumb-list { margin-top: 14px; display: flex; flex-wrap: wrap; gap: 10px; }
        .thumb-item { width: 78px; height: 78px; border-radius: 10px; overflow: hidden; border: 2px solid transparent; background: #f3f5f7; cursor: pointer; padding: 0; }
        .thumb-item.active { border-color: #1677ff; }
        .thumb-item img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .thumb-empty { width: 78px; height: 78px; border-radius: 10px; background: #f0f2f5; color: #999; display: flex; align-items: center; justify-content: center; font-size: 12px; }

        .info-box { min-width: 0; }
        .title { margin: 0 0 14px; font-size: 30px; line-height: 1.35; color: #1f1f1f; }
        .price-row { margin-bottom: 18px; padding: 16px 18px; background: #fff7f7; border-radius: 12px; border: 1px solid #ffe1e1; }
        .price-now { color: #ff4d4f; font-size: 32px; font-weight: bold; }
        .price-old { margin-top: 6px; color: #999; font-size: 14px; text-decoration: line-through; }

        .meta-panel { background: #fafbfc; border: 1px solid #eef0f3; border-radius: 12px; padding: 14px 16px; }
        .meta-item { display: flex; padding: 10px 0; border-bottom: 1px dashed #e8ebef; font-size: 14px; }
        .meta-item:last-child { border-bottom: none; }
        .meta-label { width: 88px; color: #888; flex-shrink: 0; }
        .meta-value { color: #333; word-break: break-all; }

        .desc-section, .images-section { margin-top: 22px; background: #fff; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.05); overflow: hidden; }
        .section-title { margin: 0; padding: 18px 22px; font-size: 18px; color: #1f1f1f; border-bottom: 1px solid #f0f0f0; background: #fcfcfd; }
        .section-body { padding: 22px; }
        .description { color: #444; line-height: 1.9; white-space: pre-wrap; word-break: break-word; }
        .detail-images { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; }
        .detail-image-card { background: #fff; border: 1px solid #eef0f3; border-radius: 12px; overflow: hidden; }
        .detail-image { width: 100%; height: 220px; object-fit: cover; display: block; cursor: zoom-in; background: #f0f2f5; }
        .empty-block { padding: 40px 20px; text-align: center; color: #999; background: #fff; border-radius: 16px; box-shadow: 0 10px 28px rgba(0,0,0,0.05); }

        .btn-row { margin-top: 22px; display: flex; gap: 12px; flex-wrap: wrap; align-items: center; }
        .btn { display: inline-flex; align-items: center; gap: 6px; text-decoration: none; padding: 10px 18px; border-radius: 8px; font-size: 14px; transition: all 0.2s; border: none; cursor: pointer; }
        .btn-default { background: #fff; color: #555; border: 1px solid #d9d9d9; }
        .btn-default:hover { color: #1677ff; border-color: #1677ff; }
        .btn-message { background: #f0f7ff; color: #1677ff; border: 1px solid #91caff; }
        .btn-message:hover { background: #e0efff; }
        .btn-order { background: #ff4d4f; color: #fff; border: none; }
        .btn-order:hover { background: #d9363e; }

        .btn-fav {
            background: #fff; color: #999;
            border: 1px solid #d9d9d9;
            min-width: 100px; justify-content: center;
        }
        .btn-fav:hover { border-color: #ff4d4f; color: #ff4d4f; }
        .btn-fav.active { background: #fff1f0; color: #ff4d4f; border-color: #ffb3b3; }
        .btn-fav .fav-icon { font-size: 16px; transition: transform 0.2s; }
        .btn-fav.active .fav-icon { animation: heartBeat 0.35s ease; }
        @keyframes heartBeat {
            0%   { transform: scale(1); }
            40%  { transform: scale(1.35); }
            70%  { transform: scale(0.9); }
            100% { transform: scale(1); }
        }

        .delete-form { display: inline-block; margin: 0; }
        .delete-btn { background: #fff1f0; color: #cf1322; border: 1px solid #ffccc7; padding: 10px 18px; border-radius: 8px; font-size: 14px; cursor: pointer; transition: all 0.2s; }
        .delete-btn:hover { background: #ffe7e6; }

        .image-preview-mask { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.78); z-index: 9999; align-items: center; justify-content: center; padding: 30px; }
        .image-preview-mask.show { display: flex; }
        .image-preview-big { max-width: 92vw; max-height: 88vh; border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.35); background: #fff; }
        .image-preview-close { position: absolute; top: 18px; right: 24px; color: #fff; font-size: 36px; cursor: pointer; line-height: 1; }

        @media (max-width: 900px) { .detail-main { grid-template-columns: 1fr; } .main-image { height: 320px; } }
        @media (max-width: 768px) {
            .header { padding: 0 14px; } .header .logo { font-size: 16px; }
            .container { margin-top: 18px; } .detail-main { padding: 16px; gap: 18px; }
            .section-body { padding: 16px; } .title { font-size: 24px; } .price-now { font-size: 28px; }
            .detail-images { grid-template-columns: 1fr; } .detail-image { height: 240px; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <% if (loginUser != null) { %>
            <a href="${pageContext.request.contextPath}/my-favorites">我的收藏</a>
            <a href="${pageContext.request.contextPath}/messages">私信</a>
            <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
            <a href="${pageContext.request.contextPath}/orders">我的订单</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login">登录</a>
        <% } %>
    </div>
</div>

<div class="container">
    <div class="back-bar">
        <a href="${pageContext.request.contextPath}/product-list">← 返回商品列表</a>
    </div>

    <% if (product == null) { %>
        <div class="empty-block">商品不存在或已下架。</div>
    <% } else {
        String cover = product.getCoverImageUrl();
    %>

    <div class="detail-card">
        <div class="detail-main">
            <div class="gallery-box">
                <div class="main-image-wrap">
                    <% if (cover != null && !"".equals(cover)) { %>
                        <img id="mainPreviewImage" src="<%= cover %>" alt="商品主图"
                             class="main-image" onclick="openImagePreview(this.src)">
                    <% } else if (detailImages != null && !detailImages.isEmpty()) { %>
                        <img id="mainPreviewImage" src="<%= detailImages.get(0) %>" alt="商品主图"
                             class="main-image" onclick="openImagePreview(this.src)">
                    <% } else { %>
                        <div style="height:440px;display:flex;align-items:center;justify-content:center;color:#999;">暂无图片</div>
                    <% } %>
                </div>

                <div class="thumb-list">
                    <% if (cover != null && !"".equals(cover)) { %>
                        <button type="button" class="thumb-item active" onclick="changeMainImage('<%= cover %>', this)">
                            <img src="<%= cover %>" alt="封面图">
                        </button>
                    <% } %>
                    <% if (detailImages != null && !detailImages.isEmpty()) {
                           for (String img : detailImages) { %>
                        <button type="button" class="thumb-item" onclick="changeMainImage('<%= img %>', this)">
                            <img src="<%= img %>" alt="详情图">
                        </button>
                    <%     } } %>
                    <% if ((cover == null || "".equals(cover)) && (detailImages == null || detailImages.isEmpty())) { %>
                        <div class="thumb-empty">暂无图</div>
                    <% } %>
                </div>
            </div>

            <div class="info-box">
                <h1 class="title"><%= product.getTitle() %></h1>

                <div class="price-row">
                    <div class="price-now">¥ <%= product.getPrice() %></div>
                    <% if (product.getOriginalPrice() != null) { %>
                        <div class="price-old">原价：¥ <%= product.getOriginalPrice() %></div>
                    <% } %>
                </div>

                <div class="meta-panel">
                    <div class="meta-item"><div class="meta-label">商品成色</div><div class="meta-value"><%= product.getConditionLevel() != null ? product.getConditionLevel() : "未填写" %></div></div>
                    <div class="meta-item"><div class="meta-label">商品分类</div><div class="meta-value"><%= product.getCategoryName() != null ? product.getCategoryName() : "未分类" %></div></div>
                    <div class="meta-item"><div class="meta-label">卖家</div><div class="meta-value"><%= product.getSellerName() != null ? product.getSellerName() : "未知卖家" %></div></div>
                    <div class="meta-item"><div class="meta-label">浏览量</div><div class="meta-value"><%= product.getViewCount() %></div></div>
                    <div class="meta-item">
                        <div class="meta-label">收藏量</div>
                        <div class="meta-value" id="favCountDisplay"><%= product.getFavoriteCount() %></div>
                    </div>
                    <div class="meta-item"><div class="meta-label">发布时间</div><div class="meta-value"><%= product.getCreatedAt() != null ? product.getCreatedAt() : "暂无" %></div></div>
                </div>

                <div class="btn-row">
                    <a href="${pageContext.request.contextPath}/product-list" class="btn btn-default">返回列表</a>

                    <%-- 收藏按钮（自己的商品不显示） --%>
                    <% if (loginUser != null && !isOwner) { %>
                        <button id="favBtn"
                                class="btn btn-fav <%= isFavorited ? "active" : "" %>"
                                onclick="toggleFavorite(<%= product.getProductId() %>)">
                            <span class="fav-icon"><%= isFavorited ? "♥" : "♡" %></span>
                            <span id="favBtnText"><%= isFavorited ? "已收藏" : "收藏" %></span>
                        </button>
                    <% } else if (loginUser == null) { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-fav">
                            <span class="fav-icon">♡</span> 登录后收藏
                        </a>
                    <% } %>

                    <%-- 发起交易按钮（非商品本人、已登录、商品可用） --%>
                    <% if (loginUser == null) { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-order">🛒 登录后发起交易</a>
                    <% } else if (!isOwner) { %>
                        <form action="${pageContext.request.contextPath}/orders" method="post"
                              style="display:inline-block;margin:0;"
                              onsubmit="return confirm('确定要向卖家发起交易请求吗？');">
                            <input type="hidden" name="action" value="create">
                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                            <button type="submit" class="btn btn-order">🛒 发起交易</button>
                        </form>
                    <% } %>

                    <%-- 联系卖家 / 编辑商品 --%>
                    <% if (loginUser == null) { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-message">💬 登录后联系卖家</a>
                    <% } else if (isOwner) { %>
                        <a href="${pageContext.request.contextPath}/edit-product?id=<%= product.getProductId() %>" class="btn btn-message">✏️ 编辑商品</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/messages?with=<%= product.getSellerId() %>&productId=<%= product.getProductId() %>" class="btn btn-message">💬 联系卖家</a>
                    <% } %>

                    <% if (canDelete) { %>
                        <form action="${pageContext.request.contextPath}/delete-product"
                              method="post" class="delete-form"
                              onsubmit="return confirm('确定要删除这个商品吗？');">
                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                            <button type="submit" class="delete-btn">删除商品</button>
                        </form>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

    <div class="desc-section">
        <h2 class="section-title">商品描述</h2>
        <div class="section-body">
            <div class="description">
                <%= product.getDescription() != null && !"".equals(product.getDescription().trim())
                        ? product.getDescription() : "卖家暂时没有填写商品描述。" %>
            </div>
        </div>
    </div>

    <div class="images-section">
        <h2 class="section-title">详情图片</h2>
        <div class="section-body">
            <% if (detailImages != null && !detailImages.isEmpty()) { %>
                <div class="detail-images">
                    <% for (String img : detailImages) { %>
                        <div class="detail-image-card">
                            <img src="<%= img %>" alt="商品详情图" class="detail-image" onclick="openImagePreview('<%= img %>')">
                        </div>
                    <% } %>
                </div>
            <% } else { %>
                <div style="color:#999;">暂无详情图片。</div>
            <% } %>
        </div>
    </div>

    <% } %>
</div>

<div id="imagePreviewMask" class="image-preview-mask" onclick="closeImagePreview()">
    <span class="image-preview-close" onclick="closeImagePreview(event)">&#215;</span>
    <img id="imagePreviewBig" class="image-preview-big" src="" alt="大图预览">
</div>

<script>
function toggleFavorite(productId) {
    var btn = document.getElementById('favBtn');
    var icon = btn.querySelector('.fav-icon');
    var text = document.getElementById('favBtnText');
    var countEl = document.getElementById('favCountDisplay');
    btn.disabled = true;

    var form = new FormData();
    form.append('productId', productId);

    fetch('${pageContext.request.contextPath}/favorite', { method: 'POST', body: form })
    .then(function(r){ return r.json(); })
    .then(function(data){
        if (data.needLogin) {
            window.location.href = '${pageContext.request.contextPath}/login';
            return;
        }
        if (data.success) {
            if (data.favorited) {
                btn.classList.add('active');
                icon.textContent = '♥';
                text.textContent = '已收藏';
                icon.style.animation = 'none';
                icon.offsetWidth;
                icon.style.animation = '';
            } else {
                btn.classList.remove('active');
                icon.textContent = '♡';
                text.textContent = '收藏';
            }
            if (countEl && data.count !== undefined) {
                countEl.textContent = data.count;
            }
        } else {
            alert(data.msg || '操作失败');
        }
        btn.disabled = false;
    })
    .catch(function(){
        alert('网络错误，请重试');
        btn.disabled = false;
    });
}

function changeMainImage(src, btn) {
    var mainImg = document.getElementById('mainPreviewImage');
    if (mainImg) mainImg.src = src;
    document.querySelectorAll('.thumb-item').forEach(function(t){ t.classList.remove('active'); });
    if (btn) btn.classList.add('active');
}
function openImagePreview(src) {
    document.getElementById('imagePreviewBig').src = src;
    document.getElementById('imagePreviewMask').classList.add('show');
}
function closeImagePreview(event) {
    if (event) event.stopPropagation();
    document.getElementById('imagePreviewMask').classList.remove('show');
    document.getElementById('imagePreviewBig').src = '';
}
document.addEventListener('keydown', function(e){ if (e.key === 'Escape') closeImagePreview(); });
</script>

</body>
</html>
