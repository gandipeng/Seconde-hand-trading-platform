package com.minzu.filter;

import com.minzu.entity.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@WebFilter("/*")
public class LoginFilter implements Filter {

    // 白名单：这些路径无需登录即可访问
    private static final List<String> PUBLIC_PATHS = Arrays.asList(
            "/",
            "/index.jsp",
            "/login",
            "/register",
            "/product-list",
            "/product-detail"
    );

    // 白名单：这些后缀的静态资源直接放行
    private static final List<String> STATIC_SUFFIXES = Arrays.asList(
            ".css", ".js", ".png", ".jpg", ".jpeg", ".gif", ".ico",
            ".woff", ".woff2", ".ttf", ".svg", ".webp"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req   = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String contextPath = req.getContextPath();
        String uri         = req.getRequestURI();
        // 去掉 contextPath 前缀，便于比对
        String path = uri.startsWith(contextPath)
                ? uri.substring(contextPath.length())
                : uri;

        // 1. 静态资源放行
        for (String suffix : STATIC_SUFFIXES) {
            if (path.endsWith(suffix)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // 2. 公开路径放行
        for (String publicPath : PUBLIC_PATHS) {
            if (path.equals(publicPath)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // 3. 已登录：取出用户对象备用
        HttpSession session = req.getSession(false);
        User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;

        if (loginUser == null) {
            // 未登录：写提示并重定向登录页
            req.getSession().setAttribute("errorMsg", "请先登录后再访问该页面");
            resp.sendRedirect(contextPath + "/login");
            return;
        }

        // 4. 管理员路由拦截：/admin/* 仅允许 ADMIN 角色访问
        if (path.startsWith("/admin/") || path.equals("/admin")) {
            if (!"ADMIN".equals(loginUser.getRoleCode())) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "权限不足，该页面仅管理员可访问");
                return;
            }
        }

        // 5. 通过所有检查，放行
        chain.doFilter(request, response);
    }
}
