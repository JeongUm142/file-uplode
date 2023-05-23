<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>add board + file</title>
<style>
	table, th, td{
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<h1>PDF 자료 업로드</h1>
	<form action="<%=request.getContextPath()%>/addBoardAction.jsp" method = "post" encType="multipart/form-data">
	<table>
		<!-- 자료 업로드 제목글 -->
		<tr>
			<th>boardTitle</th>
			<td>
				<textarea rows="3" cols="50" name="boardTitle" required="required"></textarea>
			</td>
		</tr>
		
		<!-- memberId-->
		<%
			// 원래방법
			// String memberId = (String)session.getAttribute("loginMemberId");
			String memberId = "test";
		%>
		<tr>
			<th>memberId</th>
			<td>
				<input type="text" name="memberId" value="<%=memberId%>" readonly="readonly">
 			</td>
		</tr>
		<!-- boardFile-->
		<tr>
			<th>boardFile</th>
			<td>
				<input type="file" name="boardFile" required="required">
 			</td>
		</tr>
	</table>
	<button type="submit">자료 업로드</button>
	</form>
</body>
</html>