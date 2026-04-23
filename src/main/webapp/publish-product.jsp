<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布商品</title>
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
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            box-shadow: 0 2px 8px rgba(22,119,255,0.18);
        }

        .header .title {
            font-size: 18px;
            font-weight: bold;
            letter-spacing: 1px;
        }

        .header .nav a {
            color: white;
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

        .page {
            max-width: 920px;
            margin: 32px auto;
            padding: 0 16px;
        }

        .card {
            background: white;
            border-radius: 14px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            overflow: hidden;
        }

        .card-top {
            padding: 24px 28px 12px;
            border-bottom: 1px solid #f0f0f0;
        }

        .card-top h2 {
            margin: 0 0 8px;
            font-size: 24px;
            color: #1f1f1f;
        }

        .card-top p {
            margin: 0;
            color: #8c8c8c;
            font-size: 14px;
        }

        .error-box {
            margin: 20px 28px 0;
            padding: 12px 14px;
            background: #fff2f0;
            border: 1px solid #ffccc7;
            color: #cf1322;
            border-radius: 8px;
            font-size: 14px;
        }

        .form-area {
            padding: 24px 28px 28px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px 20px;
        }

        .form-item {
            display: flex;
            flex-direction: column;
        }

        .form-item.full {
            grid-column: 1 / span 2;
        }

        .form-item label {
            font-size: 14px;
            font-weight: bold;
            color: #333;
            margin-bottom: 8px;
        }

        .required {
            color: #ff4d4f;
            margin-left: 4px;
        }

        .form-item input,
        .form-item select,
        .form-item textarea {
            width: 100%;
            padding: 11px 12px;
            border: 1px solid #d9d9d9;
            border-radius: 8px;
            font-size: 14px;
            background: #fff;
            outline: none;
            transition: all 0.2s;
        }

        .form-item input:focus,
        .form-item select:focus,
        .form-item textarea:focus {
            border-color: #1677ff;
            box-shadow: 0 0 0 3px rgba(22,119,255,0.12);
        }

        .form-item textarea {
            min-height: 130px;
            resize: vertical;
        }

        .hint {
            margin-top: 6px;
            font-size: 12px;
            color: #999;
        }

        .section-title {
            margin: 4px 0 18px;
            font-size: 16px;
            font-weight: bold;
            color: #1677ff;
        }

        .action-bar {
            margin-top: 28px;
            display: flex;
            gap: 12px;
            align-items: center;
        }

        .btn-primary {
            background: #1677ff;
            color: white;
            border: none;
            padding: 11px 24px;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-primary:hover {
            background: #0958d9;
        }

        .btn-secondary {
            display: inline-block;
            text-decoration: none;
            color: #555;
            background: white;
            border: 1px solid #d9d9d9;
            padding: 10px 22px;
            border-radius: 8px;
            font-size: 14px;
            transition: all 0.2s;
        }

        .btn-secondary:hover {
            color: #1677ff;
            border-color: #1677ff;
        }

        .tips {
            margin-top: 20px;
            padding: 14px 16px;
            background: #f8fbff;
            border: 1px dashed #b7d7ff;
            border-radius: 10px;
            color: #666;
            font-size: 13px;
            line-height: 1.8;
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }

            .form-item.full {
                grid-column: auto;
            }

            .header {
                padding: 0 14px;
            }

            .header .title {
                font-size: 16px;
            }

            .header .nav a {
                margin-left: 8px;
                padding: 4px 8px;
                font-size: 13px;
            }

            .card-top,
            .form-area {
                padding-left: 18px;
                padding-right: 18px;
            }

            .action-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .btn-primary,
            .btn-secondary {
                text-align: center;
                width: 100%;
            }
        }
    </style>
</head>
<body>

<div class="header">
    <div class="title">🏫 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
    </div>
</div>

<div class="page">
    <div class="card">
        <div class="card-top">
            <h2>发布商品</h2>
            <p>填写商品基本信息后，提交即可上架到平台展示。</p>
        </div>

        <c:if test="${not empty errorMsg}">
            <div class="error-box">${errorMsg}</div>
        </c:if>

        <div class="form-area">
            <div class="section-title">商品信息</div>

            <form action="${pageContext.request.contextPath}/publish-product" method="post" enctype="multipart/form-data">
                <div class="form-grid">

                    <div class="form-item full">
                        <label>
                            商品标题
                            <span class="required">*</span>
                        </label>
                        <input type="text" name="title" maxlength="120" required
                               value="${param.title}" placeholder="例如：高等数学教材、宿舍小电扇、二手耳机"/>
                        <div class="hint">标题尽量简洁清楚，方便别人搜索到。</div>
                    </div>

                    <div class="form-item">
                        <label>
                            售价
                            <span class="required">*</span>
                        </label>
                        <input type="number" name="price" step="0.01" min="0" required
                               value="${param.price}" placeholder="请输入售价"/>
                    </div>

                    <div class="form-item">
                        <label>原价</label>
                        <input type="number" name="originalPrice" step="0.01" min="0"
                               value="${param.originalPrice}" placeholder="选填"/>
                    </div>

                    <div class="form-item">
                        <label>
                            商品成色
                            <span class="required">*</span>
                        </label>
                        <select name="conditionLevel" required>
                            <option value="">请选择</option>
                            <option value="NEW" <c:if test="${param.conditionLevel eq 'NEW'}">selected</c:if>>全新</option>
                            <option value="NINETY_NEW" <c:if test="${param.conditionLevel eq 'NINETY_NEW'}">selected</c:if>>九成新</option>
                            <option value="EIGHTY_NEW" <c:if test="${param.conditionLevel eq 'EIGHTY_NEW'}">selected</c:if>>八成新</option>
                            <option value="SEVENTY_NEW" <c:if test="${param.conditionLevel eq 'SEVENTY_NEW'}">selected</c:if>>七成新及以下</option>
                        </select>
                    </div>

                    <div class="form-item">
                        <label>
                            商品分类
                            <span class="required">*</span>
                        </label>
                        <select name="categoryId" required>
                            <option value="">请选择分类</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}"
                                    <c:if test="${param.categoryId eq cat.categoryId.toString()}">selected</c:if>>
                                    ${cat.categoryName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-item full">
                        <label>商品描述</label>
                        <textarea name="description" rows="6" placeholder="请填写商品使用情况、是否有瑕疵、交易方式等信息">${param.description}</textarea>
                        <div class="hint">建议写清楚：新旧程度、是否可小刀、交易地点、是否支持当面验货。</div>
                    </div>

                    <div class="form-item full">
                        <label>
                            封面图片
                            <span class="required">*</span>
                        </label>
                        <input type="file" name="coverImage" accept="image/*" required />
                        <div class="hint">用于商品列表展示，支持 jpg/png/jpeg，单张不超过 10MB。</div>
                    </div>

                    <div class="form-item full">
                        <label>详情图片</label>
                        <input type="file" name="detailImages" accept="image/*" multiple />
                        <div class="hint">可一次选择多张，用于详情页展示；单张不超过 10MB，总上传大小不超过 50MB。</div>
                    </div>
                </div>

                <div class="action-bar">
                    <button type="submit" class="btn-primary">立即发布</button>
                    <a href="${pageContext.request.contextPath}/product-list" class="btn-secondary">返回列表</a>
                </div>

                <div class="tips">
                    温馨提示：发布前请确认商品描述真实、价格合理，避免填写联系方式等敏感信息。
                </div>
            </form>
        </div>
    </div>
</div>

</body>
</html>