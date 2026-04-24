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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/user-review")
public class AdminUserReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");

        if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<User> userList = new ArrayList<>();

        String sql = "SELECT user_id, student_or_staff_no, real_name, nickname, role_code, account_status, created_at " +
                "FROM users " +
                "WHERE account_status = 'PENDING_VERIFY' AND IFNULL(is_deleted, 0) = 0 " +
                "ORDER BY created_at DESC";

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setStudentOrStaffNo(rs.getString("student_or_staff_no"));
                user.setRealName(rs.getString("real_name"));
                user.setNickname(rs.getString("nickname"));
                user.setRoleCode(rs.getString("role_code"));
                user.setAccountStatus(rs.getString("account_status"));

                userList.add(user);
            }

            request.setAttribute("userList", userList);
            request.getRequestDispatcher("/admin-user-review.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载待审核用户失败：" + e.getMessage());
            request.getRequestDispatcher("/admin-user-review.jsp").forward(request, response);
        }
    }
}