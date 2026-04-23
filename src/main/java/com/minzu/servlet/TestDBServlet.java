package com.minzu.servlet;

import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/test-db")
public class TestDBServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<html><head><title>数据库连接测试</title></head><body>");
        out.println("<h2>数据库连接测试结果</h2>");

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT category_id, category_name FROM categories");
                ResultSet rs = ps.executeQuery()
        ) {
            out.println("<p style='color:green;'>数据库连接成功！</p>");
            out.println("<table border='1' cellspacing='0' cellpadding='8'>");
            out.println("<tr><th>ID</th><th>分类名称</th></tr>");

            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("category_id") + "</td>");
                out.println("<td>" + rs.getString("category_name") + "</td>");
                out.println("</tr>");
            }

            out.println("</table>");
        } catch (Exception e) {
            out.println("<p style='color:red;'>数据库连接失败：" + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }

        out.println("</body></html>");
    }
}