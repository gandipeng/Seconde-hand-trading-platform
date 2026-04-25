<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> orderList = (List<Map<String, Object>>) request.getAttribute("orderList");
    String type = (String) request.getAttribute("type");
    if (type == null) type = "buy";

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");

    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");

    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
%>
<%!
    public String statusText(String s) {
        if ("CREATED".equals(s))     return "待交易";
        if ("PAID_OFFLINE".equals(s)) return "线下已成交";
        if ("CANCELLED".equals(s))   return "已取消";
        if ("COMPLETED".equals(s))   return "已完成";
        if ("DISPUTED".equals(s))    return "纠纷中";
        return s != null ? s : "未知";
    }
    public String statusColor(String s) {
        if ("CREATED".equals(s))     return "#1677ff";
        if ("PAID_OFFLINE".equals(s)) return "#fa8c16";
        if ("CANCELLED".equals(s))   return "#8c8c8c";
        if ("COMPLETED".equals(s))   return "#52c41a";
        if ("DISPUTED".equals(s))    return "#f5222d";
        return "#999";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 民大二手交易平台</title>
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
        .container { max-width: 1100px; margin: 28px auto; padding: 0 16px 40px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 18px; }
        .tabs { display: flex; gap: 10px; margin-bottom: 20px; }
        .tab {
            padding: 9px 22px; border-radius: 8px; text-decoration: none;
            background: #fff; color: #555; border: 1px solid #ddd; font-size: 14px; transition: all 0.18s;
        }
        .tab:hover { border-color: #1677ff; color: #1677ff; }
        .tab.active { background: #1677ff; color: #fff; border-color: #1677ff; }
        .msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .msg-success { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .msg-error   { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
        .card {
            background: #fff; border-radius: 14px; padding: 20px;
            margin-bottom: 16px; box-shadow: 0 4px 18px rgba(0,0,0,0.06);
        }
        .card-row { display: flex; gap: 18px; align-items: flex-start; }
        .cover {
            width: 110px; height: 110px; object-fit: cover;
            border-radius: 10px; background: #f0f2f5; flex-shrink: 0;
        }
        .cover-placeholder {
            width: 110px; height: 110px; border-radius: 10px;
            background: #f0f2f5; display: flex; align-items: center; justify-content: center;
            color: #bbb; font-size: 12px; flex-shrink: 0;
        }
        .main { flex: 1; min-width: 0; }
        .card-title { font-size: 18px; font-weight: bold; margin-bottom: 8px; }
        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 999px;
            font-size: 12px; margin-bottom: 10px; color: #fff;
        }
        .meta { font-size: 13px; color: #666; line-height: 2; }
        .actions { margin-top: 12px; display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
        .btn {
            padding: 8px 16px; border-radius: 8px; font-size: 13px;
            border: none; cursor: pointer; text-decoration: none; display: inline-block;
        }
        .btn-primary { background: #1677ff; color: #fff; }
        .btn-primary:hover { background: #0e5fd8; }
        .btn-danger { background: #fff1f0; color: #cf1322; border: 1px solid #ffccc7; }
        .btn-danger:hover { background: #ffe7e6; }
        .btn-gray { background: #f5f5f5; color: #555; border: 1px solid #ddd; }
        .btn-gray:hover { border-color: #1677ff; color: #1677ff; }
        .empty {
            background: #fff; border-radius: 14px; padding: 60px 20px;
            text-align: center; color: #999; box-shadow: 0 4px 18px rgba(0,0,0,0.05);
        }
        .empty-icon { font-size: 48px; margin-bottom: 12px; }
        @media (max-width: 600px) {
            .card-row { flex-direction: column; }
            .cover, .cover-placeholder { width: 100%; height: 180px; }
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
    <div class="page-title">我的订单</div>

    <div class="tabs">
        <a class="tab <%= \"buy\".equals(type) ? \"active\" : \"\" %>" href="${pageContext.request.contextPath}/orders?type=buy">🛒 我买到的</a>
        <a class="tab <%= \"sell\".equals(type) ? \"active\" : \"\" %>" href="${pageContext.request.contextPath}/orders?type=sell">📦 我卖出的</a>
    </div>

    <% if (successMsg != null) { %>
        <div class="msg msg-success">✅ <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="msg msg-error">❌ <%= errorMsg %></div>
    <% } %>

    <% if (orderList == null || orderList.isEmpty()) { %>
        <div class="empty">
            <div class="empty-icon">📭</div>
            <div>暂无订单记录</div>
        </div>
    <% } else {
        for (Map<String, Object> o : orderList) {
            String status = (String) o.get("orderStatus");
    %>
        <div class="card">
            <div class="card-row">
                <% String coverUrl = (String) o.get("coverImageUrl"); %>
                <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
                    <img class="cover" src="<%= coverUrl %>" alt="商品图">
                <% } else { %>
                    <div class="cover-placeholder">暂无图</div>
                <% } %>

                <div class="main">
                    <div class="badge" style="background:<%= statusColor(status) %>">
                        <%= statusText(status) %>
                    </div>
                    <div class="card-title"><%= o.get("title") != null ? o.get("title") : "商品已删除" %></div>
                    <div class="meta">
                        订单号：<%= o.get("orderNo") %>&nbsp;&nbsp;
                        成交价：<strong>¥ <%= o.get("dealPrice") %></strong>&nbsp;&nbsp;
                        数量：<%= o.get("quantity") %><br>
                        买家：<%= o.get("buyerName") %>&nbsp;&nbsp;|
                        卖家：<%= o.get("sellerName") %><br>
                        创建时间：<%= o.get("createdAt") %>
                        <% if (o.get("paidAt") != null) { %>&nbsp;&nbsp;线下成交：<%= o.get("paidAt") %><% } %>
                        <% if (o.get("completedAt") != null) { %>&nbsp;&nbsp;完成时间：<%= o.get("completedAt") %><% } %>
                        <% if (o.get("cancelledAt") != null) { %>&nbsp;&nbsp;取消时间：<%= o.get("cancelledAt") %><% } %>
                        <br>
                        <% if (o.get("buyerNote") != null) { %>买家备注：<%= o.get("buyerNote") %><br><% } %>
                        <% if (o.get("sellerNote") != null) { %>卖家备注：<%= o.get("sellerNote") %><br><% } %>
                        <% if (o.get("pickupCode") != null) { %>取货码：<strong><%= o.get("pickupCode") %></strong><br><% } %>
                    </div>

                    <div class="actions">
                        <% Object pid = o.get("productId"); %>
                        <% if (pid != null) { %>
                            <a class="btn btn-gray" href="${pageContext.request.contextPath}/product-detail?id=<%= pid %>">查看商品</a>
                        <% } %>

                        <%-- 买家：CREATED 可取消 --%>
                        <% if ("buy".equals(type) && "CREATED".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;"
                                  onsubmit="return confirm('确定要取消该订单吗？');">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="buy">
                                <button class="btn btn-danger" type="submit">取消订单</button>
                            </form>
                        <% } %>

                        <%-- 卖家：CREATED 可确认线下成交 --%>
                        <% if ("sell".equals(type) && "CREATED".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;"
                                  onsubmit="return confirm('确认已与买家完成线下交易吗？');">
                                <input type="hidden" name="action" value="paid">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="sell">
                                <button class="btn btn-primary" type="submit">确认线下成交</button>
                            </form>
                        <% } %>

                        <%-- 买家：PAID_OFFLINE 可确认完成 --%>
                        <% if ("buy".equals(type) && "PAID_OFFLINE".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;"
                                  onsubmit="return confirm('确认交易已完成吗？');">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="buy">
                                <button class="btn btn-primary" type="submit">确认完成</button>
                            </form>
                        <% } %>

                        <%-- 双方：CREATED 或 PAID_OFFLINE 可发起纠纷 --%>
                        <% if ("CREATED".equals(status) || "PAID_OFFLINE".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;"
                                  onsubmit="return confirm('确定要对此订单发起纠纷吗？');">
                                <input type="hidden" name="action" value="dispute">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="<%= type %>">
                                <button class="btn btn-danger" type="submit">发起纠纷</button>
                            </form>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    <% }} %>
</div>

</body>
</html>
