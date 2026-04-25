-- V5: 新增 reviews 表 + 商品审核状态 + users 表 phone/email 字段

-- 1. reviews 表
CREATE TABLE IF NOT EXISTS reviews (
    review_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT NOT NULL,
    reviewer_id INT NOT NULL,
    reviewed_id INT NOT NULL,
    product_id  INT NOT NULL,
    score       TINYINT NOT NULL COMMENT '1-5',
    content     VARCHAR(300),
    role        ENUM('BUYER','SELLER') NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_review (order_id, reviewer_id, role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. products.publish_status 新增 PENDING_REVIEW / REJECTED 枚举值
-- （MySQL ENUM 扩充用 MODIFY，已有数据不受影响）
ALTER TABLE products
    MODIFY COLUMN publish_status
    ENUM('PENDING_REVIEW','ON_SALE','SOLD','OFF_SHELF','REJECTED')
    NOT NULL DEFAULT 'PENDING_REVIEW';

-- 3. users 表补充 phone / email 字段（若已存在则忽略）
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS phone VARCHAR(20)  DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS email VARCHAR(100) DEFAULT NULL;
