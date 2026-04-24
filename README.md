# 二手交易平台 (Minzu Secondhand)

> 基于 Java Servlet + JSP + MySQL 构建的校园二手商品交易平台，支持用户注册审核、商品发布与管理等核心功能。

---

## 📌 项目简介

本平台面向校园用户，提供一个安全、便捷的二手物品流通渠道。用户注册后需经管理员审核方可发布商品，管理员可对用户和商品进行全面管理，保障平台交易环境的健康有序。

---

## ✨ 功能特性

### 用户端
- **用户注册 / 登录 / 退出**：支持账号注册，注册后需等待管理员审核激活
- **商品列表浏览**：查看平台上所有在售二手商品
- **商品详情查看**：查看商品的详细信息、图片及联系方式
- **发布商品**：审核通过的用户可发布二手商品（含图片上传）
- **删除商品**：用户可删除自己发布的商品

### 管理员端
- **用户审核**：查看待审核用户列表，执行通过或拒绝操作
- **商品管理**：管理平台上的所有商品信息

---

## 🛠️ 技术栈

| 层次 | 技术 |
|------|------|
| 后端 | Java 21 + Servlet 4.0 |
| 前端 | JSP 2.3 + JSTL 1.2 |
| 数据库 | MySQL 8.x |
| 构建工具 | Maven 3.x |
| 部署容器 | Apache Tomcat（WAR 包部署） |

---

## 📁 项目结构

```
minzu-secondhand/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/minzu/
│       │       ├── entity/        # 实体类 (User, Product)
│       │       ├── servlet/       # 业务逻辑 Servlet
│       │       ├── filter/        # 过滤器（登录校验等）
│       │       └── util/          # 工具类
│       └── webapp/                # JSP 页面 & 静态资源
├── pom.xml
└── README.md
```

---

## 🚀 快速开始

### 环境要求

- JDK 21+
- Apache Tomcat 10.x
- MySQL 8.x
- Maven 3.6+

### 部署步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/gandipeng/Seconde-hand-trading-platform.git
   cd Seconde-hand-trading-platform
   ```

2. **初始化数据库**

   在 MySQL 中创建数据库并导入初始化 SQL（请参考 `src/main/resources` 或项目文档）：
   ```sql
   CREATE DATABASE minzu_secondhand DEFAULT CHARACTER SET utf8mb4;
   ```

3. **配置数据库连接**

   修改 `src/main/java/com/minzu/util/` 下的数据库工具类，填写您的数据库连接信息：
   ```
   URL:      jdbc:mysql://localhost:3306/minzu_secondhand
   Username: your_username
   Password: your_password
   ```

4. **Maven 打包**
   ```bash
   mvn clean package
   ```

5. **部署到 Tomcat**

   将生成的 `target/minzu-secondhand.war` 复制到 Tomcat 的 `webapps/` 目录，启动 Tomcat 后访问：
   ```
   http://localhost:8080/minzu-secondhand/
   ```

---

## 🔑 默认账户

| 角色 | 说明 |
|------|------|
| 管理员 | 请在数据库中手动插入管理员账户 |
| 普通用户 | 注册后由管理员审核激活 |

---

## 📄 许可证

本项目为学习用途开发，暂未设置开源许可证。如需使用，请联系项目作者。
