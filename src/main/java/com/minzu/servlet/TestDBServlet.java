package com.minzu.servlet;

// 此文件已废弃，保留空类防止编译错误。
// 生产环境请勿暴露任何测试端点。
// TODO: 下个版本彻底删除此文件及对应路由。

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * @deprecated 测试用 Servlet，已禁用，请勿访问 /test-db 端点。
 */
@Deprecated
@WebServlet("/test-db-disabled-do-not-use")
public class TestDBServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendError(404);
    }
}
