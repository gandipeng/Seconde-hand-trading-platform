<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>错误提示</title>
    <style>
        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #f5f7fa;
        }
        .box {
            width: 90%;
            max-width: 700px;
            margin: 80px auto;
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            padding: 32px;
        }
        h2 {
            margin-top: 0;
            color: #cf1322;
        }
        .msg {
            background: #fff2f0;
            border: 1px solid #ffccc7;
            color: #a8071a;
            padding: 14px 16px;
            border-radius: 8px;
            margin-top: 16px;
            line-height: 1.7;
        }
        a {
            display: inline-block;
            margin-top: 20px;
            text-decoration: none;
            color: white;
            background: #1677ff;
            padding: 10px 18px;
            border-radius: 8px;
        }
    </style>
</head>
<body>
<div class="box">
    <h2>操作失败</h2>
    <div class="msg">
        ${errorMsg}
    </div>
    <a href="javascript:history.back()">返回上一页</a>
</div>
</body>
</html>