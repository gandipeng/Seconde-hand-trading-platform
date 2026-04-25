<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Product product = (Product) request.getAttribute("product");
    List<Map<String, Object>> categories = (List<Map<String, Object>>) request.getAttribute("categories");

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑商品 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }

        .header {
            height: 56px; background: #1677ff; color: white;
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }
        .header .logo { font-size: 18px; font-weight: bold; }
        .header .nav a {
            color: white; text-decoration: none; margin-left: 14px;
            font-size: 14px; padding: 6px 12px; border-radius: 6px;
        }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }

        .page { max-width: 920px; margin: 32px auto; padding: 0 16px; }

        .card {
            background: white; border-radius: 14px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06); overflow: hidden;
        }
        .card-top {
            padding: 24px 28px 12px; border-bottom: 1px solid #f0f0f0;
        }
        .card-top h2 { margin: 0 0 8px; font-size: 24px; color: #1f1f1f; }
        .card-top p { margin: 0; color: #8c8c8c; font-size: 14px; }

        .msg-box { margin: 16px 28px 0; padding: 12px 14px; border-radius: 8px; font-size: 14px; }
        .msg-success { background:#f6ffed; border:1px solid #b7eb8f; color:#389e0d; }
        .msg-error   { background:#fff2f0; border:1px solid #ffccc7; color:#cf1322; }

        .form-area { padding: 24px 28px 28px; }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 18px 20px; }
        .form-item { display: flex; flex-direction: column; }
        .form-item.full { grid-column: 1 / span 2; }
        .form-item label { font-size: 14px; font-weight: bold; color: #333; margin-bottom: 8px; }
        .required { color: #ff4d4f; margin-left: 4px; }
        .form-item input, .form-item select, .form-item textarea {
            width: 100%; padding: 11px 12px; border: 1px solid #d9d9d9;
            border-radius: 8px; font-size: 14px; background: #fff;
            outline: none; transition: all 0.2s;
        }
        .form-item input:focus, .form-item select:focus, .form-item textarea:focus {
            border-color: #1677ff; box-shadow: 0 0 0 3px rgba(22,119,255,0.12);
        }
        .form-item textarea { min-height: 130px; resize: vertical; }
        .hint { margin-top: 6px; font-size: 12px; color: #999; }

        .cover-preview {
            margin-top: 10px; display: flex; align-items: center; gap: 14px;
        }
        .cover-preview img {
            width: 90px; height: 90px; object-fit: cover;
            border-radius: 8px; border: 1px solid #e0e0e0;
        }
        .cover-preview span { font-size: 12px; color: #999; }

        .section-title { margin: 4px 0 18px; font-size: 16px; font-weight: bold; color: #1677ff; }

        .action-bar { margin-top: 28px; display: flex; gap: 12px; align-items: center; }
        .btn-primary {
            background: #1677ff; color: white; border: none;
            padding: 11px 24px; border-radius: 8px; font-size: 14px;
            cursor: pointer; transition: background 0.2s;
        }
        .btn-primary:hover { background: #0958d9; }
        .btn-secondary {
            display: inline-block; text-decoration: none; color: #555;
            background: white; border: 1px solid #d9d9d9;
            padding: 10px 22px; border-radius: 8px; font-size: 14px;
            transition: all 0.2s;
        }
        .btn-secondary:hover { color: #1677ff; border-color: #1677ff; }

        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-item.full { grid-column: auto; }
            .action-bar { flex-direction: column; align-items: stretch; }
            .btn-primary, .btn-secondary { text-align: center; width: 100%; }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
    </div>
</div>

<div class="page">
    <div class="card">
        <div class="card-top">
            <h2>编辑商品</h2>
            <p>修改商品信息后点击保存，封面图不选则保留原图。</p>
        </div>

        <% if (successMsg != null) { %>
            <div class="msg-box msg-success"><%= successMsg %></div>
        <% } %>
        <% if (sessionErrorMsg != null) { %>
            <div class="msg-box msg-error"><%= sessionErrorMsg %></div>
        <% } else if (request.getAttribute("errorMsg") != null) { %>
            <div class="msg-box msg-error"><%= request.getAttribute("errorMsg") %></div>
        <% } %>

        <div class="form-area">
            <div class="section-title">商品信息</div>

            <form action="${pageContext.request.contextPath}/edit-product" method="post" enctype="multipart/form-data">
                <input type="hidden" name="productId" value="<%= product.getProductId() %>">

                <div class="form-grid">

                    <div class="form-item full">
                        <label>商品标题 <span class="required">*</span></label>
                        <input type="text" name="title" maxlength="120" required
                               value="<%= product.getTitle() %>"
                               placeholder="例如：高等数学教材、宿舍小电扇"/>
                    </div>

                    <div class="form-item">
                        <label>售价 <span class="required">*</span></label>
                        <input type="number" name="price" step="0.01" min="0" required
                               value="<%= product.getPrice() %>"
                               placeholder="请输入售价"/>
                    </div>

                    <div class="form-item">
                        <label>原价</label>
                        <input type="number" name="originalPrice" step="0.01" min="0"
                               value="<%= product.getOriginalPrice() != null ? product.getOriginalPrice() : "" %>"
                               placeholder="选填"/>
                    </div>

                    <div class="form-item">
                        <label>商品成色 <span class="required">*</span></label>
                        <select name="conditionLevel" required>
                            <option value="">--请选择--</option>
                            <option value="NEW"          <%= "NEW".equals(product.getConditionLevel())           ? "selected" : "" %>>全新</option>
                            <option value="NINETY_NEW"   <%= "NINETY_NEW".equals(product.getConditionLevel())   ? "selected" : "" %>>九成新</option>
                            <option value="EIGHTY_NEW"   <%= "EIGHTY_NEW".equals(product.getConditionLevel())   ? "selected" : "" %>>八成新</option>
                            <option value="SEVENTY_NEW"  <%= "SEVENTY_NEW".equals(product.getConditionLevel())  ? "selected" : "" %>>七成新及以下</option>
                        </select>
                    </div>

                    <div class="form-item">
                        <label>商品分类 <span class="required">*</span></label>
                        <select name="categoryId" required>
                            <option value="">请选择分类</option>
                            <% if (categories != null) { for (Map<String,Object> cat : categories) { %>
                                <option value="<%= cat.get("categoryId") %>"
                                    <%= cat.get("categoryId").equals(product.getCategoryId()) ? "selected" : "" %>>
                                    <%= cat.get("categoryName") %>
                                </option>
                            <% } } %>
                        </select>
                    </div>

                    <div class="form-item full">
                        <label>商品描述</label>
                        <textarea name="description" rows="6"
                                  placeholder="请填写商品使用情况、是否有瑕疵、交易方式等信息"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-item full">
                        <label>封面图片（不选则保留原图）</label>
                        <input type="file" name="coverImage" accept="image/*"/>
                        <div class="hint">支持 jpg/png/jpeg，单张不超过 10MB。</div>
                        <% if (product.getCoverImageUrl() != null && !product.getCoverImageUrl().isEmpty()) { %>
                            <div class="cover-preview">
                                <img src="<%= product.getCoverImageUrl() %>" alt="封面预览">
                                <span>当前封面图，重新选择则替换</span>
                            </div>
                        <% } %>
                    </div>

                </div>

                <div class="action-bar">
                    <button type="submit" class="btn-primary">保存修改</button>
                    <a href="${pageContext.request.contextPath}/my-products" class="btn-secondary">返回我的商品</a>
                    <a href="${pageContext.request.contextPath}/product-detail?id=<%= product.getProductId() %>" class="btn-secondary">查看商品详情</a>
                </div>
            </form>
        </div>
    </div>
</div>

</body>
</html>
