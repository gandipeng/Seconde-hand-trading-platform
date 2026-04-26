package com.minzu.servlet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

/**
 * 提供外部目录 C:/uploads/minzu-secondhand/ 下图片的访问
 * 访问路径：/uploads/{filename}
 */
@WebServlet("/uploads/*")
public class ImageServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "C:/uploads/minzu-secondhand/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // 防止路径穿越攻击
        String filename = new File(pathInfo.substring(1)).getName();
        File file = new File(UPLOAD_DIR + filename);

        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String lower = filename.toLowerCase();
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
            resp.setContentType("image/jpeg");
        } else if (lower.endsWith(".png")) {
            resp.setContentType("image/png");
        } else if (lower.endsWith(".gif")) {
            resp.setContentType("image/gif");
        } else if (lower.endsWith(".webp")) {
            resp.setContentType("image/webp");
        } else {
            resp.setContentType("application/octet-stream");
        }

        resp.setContentLengthLong(file.length());

        try (InputStream in = new FileInputStream(file);
             OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) {
                out.write(buf, 0, len);
            }
        }
    }
}
