package com.minzu.filter;

import com.minzu.entity.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * 登录拦截器：拦截所有请求，未登录用户访问非白名单路径时跳转到登录页。
 */
@WebFilter("/*")
public class LoginFilter implements Filter {

    /**
     * 白名单（精确匹配）：这些路径不需要登录就能访问。
     */
    private static final Set<String> WHITE_LIST_PATHS = new HashSet<>(Arrays.asList(
            "/login",
            "/register",
            "/index.jsp",   // 首页游客可见
            "/product-list" // 商品列表游客可见
    ));

    /** 白名单前缀：这些前缀开头的路径无论是否登录都放行。 */
    private static final String[] WHITE_LIST_PREFIXES = {
            "/static/",
            "/css/",
            "/js/",
            "/images/",
            "/uploads/",    // 上传图片目录
            "/fonts/",
            "/favicon.ico"
    };

    /** 白名单后缀：这些后缀的资源无论是否登录都放行。 */
    private static final String[] WHITE_LIST_SUFFIXES = {
            ".css", ".js", ".png", ".jpg", ".jpeg", ".gif",
            ".svg", ".ico", ".woff", ".woff2", ".ttf", ".map"
    };

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest) servletRequest;
        HttpServletResponse resp = (HttpServletResponse) servletResponse;

        String contextPath = req.getContextPath();
        String requestURI  = req.getRequestURI();
        String path = requestURI.substring(contextPath.length());
        // 去掉 query string 后再匹配（如 /product-list?page=2 → /product-list）
        int qIdx = path.indexOf('?');
        String pathNoQuery = (qIdx >= 0) ? path.substring(0, qIdx) : path;

        // 1. 静态资源后缀白名单——直接放行
        for (String suffix : WHITE_LIST_SUFFIXES) {
            if (pathNoQuery.toLowerCase().endsWith(suffix)) {
                chain.doFilter(servletRequest, servletResponse);
                return;
            }
        }

        // 2. 前缀白名单——直接放行
        for (String prefix : WHITE_LIST_PREFIXES) {
            if (pathNoQuery.startsWith(prefix)) {
                chain.doFilter(servletRequest, servletResponse);
                return;
            }
        }

        // 3. 精确白名单——直接放行
        if (WHITE_LIST_PATHS.contains(pathNoQuery)) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }

        // 4. 检查 Session 中是否有登录用户
        HttpSession session   = req.getSession(false);
        User        loginUser = (session == null) ? null : (User) session.getAttribute("loginUser");

        if (loginUser != null) {
            chain.doFilter(servletRequest, servletResponse);
        } else {
            // 未登录：保存完整原始 URL（含 query string），登录后回跳
            session = req.getSession(true);
            String queryString = req.getQueryString();
            String fullUrl = requestURI + (queryString != null ? "?" + queryString : "");
            session.setAttribute("redirectAfterLogin", fullUrl);
            resp.sendRedirect(contextPath + "/login");
        }
    }

    @Override
    public void destroy() {}
}
