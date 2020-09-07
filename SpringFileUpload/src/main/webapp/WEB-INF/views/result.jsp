<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Result</title>
<script src="<%=request.getContextPath()%>/js/jquery-1.11.3.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-csv/0.71/jquery.csv-0.71.min.js"></script>
<script type='text/javascript' src='${pageContext.request.contextPath}/js/process.js'></script>
</head>
<body>
<h2>BlueTron Financial Processor</h2>
    <br>
	<% 
	String fileName = (String)request.getAttribute("fileName");
	String msg = (String)request.getAttribute("message");
	out.println(msg);
	%>
	<br>
	<script>
	var fileName = '<%= fileName %>';
	</script>
		<div>
		<tr>
		<td>
		<input type="button"  align="top" value = "Back" onclick="window.location='/spring/upload.jsp';">
		<form method="POST" action="processFile" >
		Process File Name: <input type="text" name="fileName" value ='<%= fileName %>'><br/> 
		<input type="submit" value="Process"/>
		 <br/>
		 </form></td></tr>
		 </div>
		 </body>
		 </html>
