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

        if (account == null || account.trim().isEmpty()
                || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "请输入账号和密码");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        String sql = "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, account_status, password_hash " +
                "FROM users " +
                "WHERE student_or_staff_no = ? AND IFNULL(is_deleted, 0) = 0";

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            ps.setString(1, account.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    request.setAttribute("errorMsg", "账号不存在");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                String dbPassword = rs.getString("password_hash");
                String accountStatus = rs.getString("account_status");

                if (!password.trim().equals(dbPassword)) {
                    request.setAttribute("errorMsg", "账号或密码错误");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                if ("PENDING_VERIFY".equals(accountStatus)) {
                    request.setAttribute("errorMsg", "账号已注册，正在等待审核");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                if ("DISABLED".equals(accountStatus)) {
                    request.setAttribute("errorMsg", "账号已被停用，请联系管理员");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                if (!"ACTIVE".equals(accountStatus)) {
                    request.setAttribute("errorMsg", "账号状态异常，暂时无法登录");
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }

                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setStudentOrStaffNo(rs.getString("student_or_staff_no"));
                user.setRealName(rs.getString("real_name"));
                user.setNickname(rs.getString("nickname"));
                user.setRoleCode(rs.getString("role_code"));
                user.setAccountStatus(accountStatus);

                HttpSession session = request.getSession();
                session.setAttribute("loginUser", user);

                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "登录失败：" + e.getMessage());
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}