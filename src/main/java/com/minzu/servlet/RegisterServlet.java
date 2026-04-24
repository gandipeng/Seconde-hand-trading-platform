package com.minzu.servlet;

import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String studentOrStaffNo = request.getParameter("studentOrStaffNo");
        String realName = request.getParameter("realName");
        String nickname = request.getParameter("nickname");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (studentOrStaffNo == null || studentOrStaffNo.trim().isEmpty()
                || realName == null || realName.trim().isEmpty()
                || password == null || password.trim().isEmpty()
                || confirmPassword == null || confirmPassword.trim().isEmpty()) {

            request.setAttribute("errorMsg", "请把必填项填写完整");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMsg", "两次输入的密码不一致");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            String checkSql = "SELECT user_id FROM users WHERE student_or_staff_no = ? AND IFNULL(is_deleted, 0) = 0";
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setString(1, studentOrStaffNo.trim());
            rs = psCheck.executeQuery();

            if (rs.next()) {
                request.setAttribute("errorMsg", "该学号/工号已注册，请直接登录");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
                return;
            }

            String insertSql = "INSERT INTO users " +
                    "(student_or_staff_no, real_name, nickname, password_hash, role_code, created_at, updated_at) " +
                    "VALUES (?, ?, ?, ?, 'STUDENT', NOW(), NOW())";

            psInsert = conn.prepareStatement(insertSql);
            psInsert.setString(1, studentOrStaffNo.trim());
            psInsert.setString(2, realName.trim());
            psInsert.setString(3, nickname == null ? null : nickname.trim());
            psInsert.setString(4, password.trim());

            int rows = psInsert.executeUpdate();
            if (rows > 0) {
                request.getSession().setAttribute("successMsg", "注册成功，请等待审核后登录");
                response.sendRedirect(request.getContextPath() + "/login");
            } else {
                request.setAttribute("errorMsg", "注册失败，请稍后重试");
                request.getRequestDispatcher("/register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "注册失败：" + e.getMessage());
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (psCheck != null) psCheck.close(); } catch (Exception ignored) {}
            try { if (psInsert != null) psInsert.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}