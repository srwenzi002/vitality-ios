package com.vitality.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * ID生成工具类
 */
public class IdGenerator {
    
    private static final DateTimeFormatter FORMATTER = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    /**
     * 生成用户ID
     */
    public static String generateUserId() {
        return "U" + System.currentTimeMillis() + randomSuffix(4);
    }

    /**
     * 生成交易ID
     */
    public static String generateTransactionId() {
        return "TX" + LocalDateTime.now().format(FORMATTER) + randomSuffix(6);
    }

    /**
     * 生成挂单ID
     */
    public static String generateListingId() {
        return "L" + LocalDateTime.now().format(FORMATTER) + randomSuffix(6);
    }

    /**
     * 生成会话令牌
     */
    public static String generateSessionToken() {
        return UUID.randomUUID().toString().replace("-", "");
    }

    /**
     * 生成随机后缀
     */
    private static String randomSuffix(int length) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append((int) (Math.random() * 10));
        }
        return sb.toString();
    }
}
