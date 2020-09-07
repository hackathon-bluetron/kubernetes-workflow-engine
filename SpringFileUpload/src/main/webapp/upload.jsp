<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page session="false" %>
<html>
<head>
<title>BlueTron Financial Processor </title>
<script src="<%=request.getContextPath()%>/js/jquery-1.11.3.min.js"></script>
<script type='text/javascript' src='${pageContext.request.contextPath}/js/process.js'></script>
</head>
<body>
<h2>BlueTron Financial Processor</h2>
<table style="border-collapse: collapse; text-align:center;" border="1px">
<tbody>
<tr>
<td>
    <br>
	<form method="POST" action="processForm" enctype="multipart/form-data">
		Upload file: <input type="file" name="file"><br/> 
		 <br/>
	<input  style="background-color: #ADD8E6;" type="submit" name="upload" value="Upload"> 
	</form>
</td>
</tr>
</tbody>
</table> 
</body>
</html>