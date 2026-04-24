package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/admin/reject-user")
public class RejectUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");

        if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String userId = request.getParameter("userId");
        String sql = "UPDATE users SET account_status = 'DISABLED', updated_at = NOW() " +
                "WHERE user_id = ? AND IFNULL(is_deleted, 0) = 0";

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setInt(1, Integer.parseInt(userId));
            int rows = ps.executeUpdate();

            if (rows > 0) {
                request.getSession().setAttribute("successMsg", "已将该用户设为禁用");
            } else {
                request.getSession().setAttribute("errorMsg", "操作失败，未找到对应用户");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/user-review");
    }
}