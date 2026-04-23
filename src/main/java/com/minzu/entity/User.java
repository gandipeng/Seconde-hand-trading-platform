package com.minzu.entity;

public class User {
    private int userId;
    private String studentOrStaffNo;
    private String realName;
    private String nickname;
    private String roleCode;
    private String accountStatus;

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getStudentOrStaffNo() {
        return studentOrStaffNo;
    }

    public void setStudentOrStaffNo(String studentOrStaffNo) {
        this.studentOrStaffNo = studentOrStaffNo;
    }

    public String getRealName() {
        return realName;
    }

    public void setRealName(String realName) {
        this.realName = realName;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public String getRoleCode() {
        return roleCode;
    }

    public void setRoleCode(String roleCode) {
        this.roleCode = roleCode;
    }

    public String getAccountStatus() {
        return accountStatus;
    }

    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }
}