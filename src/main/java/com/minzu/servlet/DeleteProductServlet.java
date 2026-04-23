package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/delete-product")
public class DeleteProductServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User loginUser = (User) request.getSession().getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String productIdStr = request.getParameter("productId");
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            request.setAttribute("errorMsg", "商品ID不能为空");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("errorMsg", "商品ID格式错误");
            request.getRequestDispatcher("/error.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement psQuery = null;
        PreparedStatement psDelete = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String querySql = "SELECT seller_id, is_deleted FROM products WHERE product_id = ?";
            psQuery = conn.prepareStatement(querySql);
            psQuery.setInt(1, productId);
            rs = psQuery.executeQuery();

            if (!rs.next()) {
                request.setAttribute("errorMsg", "商品不存在");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }

            int sellerId = rs.getInt("seller_id");
            int isDeleted = rs.getInt("is_deleted");

            if (isDeleted == 1) {
                request.setAttribute("errorMsg", "该商品已被删除");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }

            boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
            boolean isOwner = loginUser.getUserId() == sellerId;

            if (!isAdmin && !isOwner) {
                request.setAttribute("errorMsg", "你无权删除该商品");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
                return;
            }

            String deleteSql = "UPDATE products SET is_deleted = 1 WHERE product_id = ?";
            psDelete = conn.prepareStatement(deleteSql);
            psDelete.setInt(1, productId);

            int rows = psDelete.executeUpdate();
            if (rows > 0) {
                request.getSession().setAttribute("successMsg", "商品删除成功");
                response.sendRedirect(request.getContextPath() + "/product-list");
            } else {
                request.setAttribute("errorMsg", "删除失败");
                request.getRequestDispatcher("/error.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "删除商品失败：" + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (psQuery != null) psQuery.close(); } catch (Exception ignored) {}
            try { if (psDelete != null) psDelete.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}