package com.minzu.filter;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter("/*")
public class LoginFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String uri = req.getRequestURI();

        boolean isPublicResource =
                uri.equals(contextPath + "/") ||
                        uri.equals(contextPath + "/index.jsp") ||
                        uri.equals(contextPath + "/login") ||
                        uri.equals(contextPath + "/register") ||
                        uri.equals(contextPath + "/product-list") ||
                        uri.equals(contextPath + "/product-detail") ||
                        uri.endsWith(".css") ||
                        uri.endsWith(".js") ||
                        uri.endsWith(".png") ||
                        uri.endsWith(".jpg") ||
                        uri.endsWith(".jpeg") ||
                        uri.endsWith(".gif") ||
                        uri.endsWith(".ico");

        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("loginUser") != null);

        if (isPublicResource || isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            HttpSession newSession = req.getSession();
            newSession.setAttribute("errorMsg", "请先登录后再访问该页面");
            resp.sendRedirect(contextPath + "/login");
        }
    }
}