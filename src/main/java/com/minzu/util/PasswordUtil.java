package com.minzu.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * 密码工具类：封装 BCrypt 哈希和校验逻辑。
 *
 * 使用方式：
 *   注册时： String hash = PasswordUtil.hash(rawPassword);
 *   登录时： boolean ok = PasswordUtil.verify(inputPassword, storedHash);
 *
 * 兼容明文过渡期：
 *   如果数据库中存的不是以 "$2a$" 开头的 BCrypt 哈希，
 *   verify() 会先尝试明文比对（兼容存量老数据）。
 */
public class PasswordUtil {

    // BCrypt 工作因子，10 是安全与性能的平衡点
    private static final int BCRYPT_ROUNDS = 10;

    /**
     * 将明文密码哈希为 BCrypt 字符串。
     */
    public static String hash(String rawPassword) {
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /**
     * 校验输入密码与数据库存储字符串是否匹配。
     * 自动判断存储值是 BCrypt 哈希还是明文，实现平滑过渡。
     */
    public static boolean verify(String rawPassword, String stored) {
        if (stored == null || rawPassword == null) return false;
        // 已是 BCrypt 哈希（$2a$ 或 $2b$ 开头）
        if (stored.startsWith("$2a$") || stored.startsWith("$2b$") || stored.startsWith("$2y$")) {
            return BCrypt.checkpw(rawPassword, stored);
        }
        // 尚是明文（过渡期兼容）
        return rawPassword.equals(stored);
    }
}
