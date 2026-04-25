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
     * 白名单：这些路径不需要登录就能访问。
     * 包含：/login、/register、静态资源、CSS/JS/图片等。
     */
    private static final Set<String> WHITE_LIST_PATHS = new HashSet<>(Arrays.asList(
            "/login",
            "/register"
    ));

    /** 白名单前缀：这些前缀开头的路径无论是否登录都放行。 */
    private static final String[] WHITE_LIST_PREFIXES = {
            "/static/",
            "/css/",
            "/js/",
            "/images/",
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

        String contextPath = req.getContextPath();          // 例： ""
        String requestURI  = req.getRequestURI();           // 例： "/orders"
        // 去掉 contextPath 前缀，得到相对路径
        String path = requestURI.substring(contextPath.length());

        // 1. 静态资源、后缀白名单——直接放行
        for (String suffix : WHITE_LIST_SUFFIXES) {
            if (path.toLowerCase().endsWith(suffix)) {
                chain.doFilter(servletRequest, servletResponse);
                return;
            }
        }

        // 2. 前缀白名单——直接放行
        for (String prefix : WHITE_LIST_PREFIXES) {
            if (path.startsWith(prefix)) {
                chain.doFilter(servletRequest, servletResponse);
                return;
            }
        }

        // 3. 精确白名单（/login、/register）——直接放行
        if (WHITE_LIST_PATHS.contains(path)) {
            chain.doFilter(servletRequest, servletResponse);
            return;
        }

        // 4. 检查 Session 中是否有登录用户
        HttpSession session   = req.getSession(false);
        User        loginUser = (session == null) ? null : (User) session.getAttribute("loginUser");

        if (loginUser != null) {
            // 已登录，放行
            chain.doFilter(servletRequest, servletResponse);
        } else {
            // 未登录，将原始 URL 存入 session，登录后可回跳
            session = req.getSession(true);
            session.setAttribute("redirectAfterLogin", requestURI);
            resp.sendRedirect(contextPath + "/login");
        }
    }

    @Override
    public void destroy() {}
}
