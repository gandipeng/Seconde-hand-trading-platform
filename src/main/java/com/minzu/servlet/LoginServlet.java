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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String account = request.getParameter("account");
        String password = request.getParameter("password");

        String sql = "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, account_status " +
                "FROM users WHERE student_or_staff_no = ? AND password_hash = ?";

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, account);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("user_id"));
                    user.setStudentOrStaffNo(rs.getString("student_or_staff_no"));
                    user.setRealName(rs.getString("real_name"));
                    user.setNickname(rs.getString("nickname"));
                    user.setRoleCode(rs.getString("role_code"));
                    user.setAccountStatus(rs.getString("account_status"));

                    HttpSession session = request.getSession();
                    session.setAttribute("loginUser", user);

                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                } else {
                    request.setAttribute("errorMsg", "账号或密码错误");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                }
            }

        } catch (Exception e) {
            request.setAttribute("errorMsg", "登录失败：" + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}