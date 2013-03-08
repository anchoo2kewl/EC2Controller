<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>AWS File Upload</title>
    <link rel="stylesheet" href="styles/styles.css" type="text/css" media="screen">
</head>
<body>
    <div id="content" class="container">
        <div class="section grid grid5 s3">
            <h2>Amazon AWS Credential</h2>
            <form action="upload.jsp" method="post">
	 			 AWS Credential Full Path: 
	 			 <input type="text" name="aws"><br>
	 			 <input type="hidden" name="check" value="check">
	  			<input type="submit" value="Submit">
			</form>

    </div>
</body>
</html>