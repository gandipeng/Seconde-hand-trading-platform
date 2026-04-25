package com.minzu.entity;

import java.sql.Timestamp;

public class Review {
    private int reviewId;
    private int orderId;
    private int reviewerId;
    private int reviewedId;
    private int productId;
    private int score;          // 1-5
    private String content;
    private String role;        // BUYER or SELLER
    private Timestamp createdAt;

    // --- reviewer / reviewed display fields (filled from JOIN) ---
    private String reviewerName;
    private String reviewedName;
    private String productTitle;

    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getReviewerId() { return reviewerId; }
    public void setReviewerId(int reviewerId) { this.reviewerId = reviewerId; }

    public int getReviewedId() { return reviewedId; }
    public void setReviewedId(int reviewedId) { this.reviewedId = reviewedId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getReviewerName() { return reviewerName; }
    public void setReviewerName(String reviewerName) { this.reviewerName = reviewerName; }

    public String getReviewedName() { return reviewedName; }
    public void setReviewedName(String reviewedName) { this.reviewedName = reviewedName; }

    public String getProductTitle() { return productTitle; }
    public void setProductTitle(String productTitle) { this.productTitle = productTitle; }
}
