<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	if(request.getParameter("boardNo") == null
		||request.getParameter("boardFileNo") == null){
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
		return;
		} 

	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
		System.out.println(boardNo + "<--boardNo");
		System.out.println(boardFileNo + "<--boardFileNo");
	
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/Fileuploade";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename, f.type, f.createdate FROM board b INNER JOIN board_file f ON b.board_no = f.board_no WHERE b.board_no = ? AND f.board_file_no = ? ";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1, boardNo);
	stmt.setInt(2, boardFileNo);
	rs = stmt.executeQuery();
	HashMap<String, Object> list = null;
	//한번에 하나의 값만 가져오기에 if
	if(rs.next()) {
		list = new HashMap<>();
		list.put("boardNo", rs.getString("boardNo"));
		list.put("boardTitle", rs.getString("boardTitle"));
		list.put("boardFileNo", rs.getString("boardFileNo"));
		list.put("originFilename", rs.getString("originFilename"));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Board 삭제 폼</title>
</head>
<body>
	<h1>Board & boardFile 삭제</h1>
	<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method="post" enctype="multipart/form-data">
		<input type="hidden" name = "boardNo" value="<%=list.get("boardNo")%>">
		<input type="hidden" name = "boardFileNo" value="<%=list.get("boardFileNo")%>">
		<input type="hidden" name = "originFilename" value="<%=list.get("originFilename")%>">
		<table>
			<tr>
				<td>게시글명</td>
				<td>
					<input type="text" name = "boardTitle" value="<%=list.get("boardTitle")%>" readonly="readonly">
				</td>
			</tr>
			<tr>
				<td>파일</td>
				<td>
					<%=list.get("originFilename")%>
				</td>
			</tr>
			<tr>
				<td>파일명 입력</td>
				<td>
					<input type="text" name = "fileNameRe" placeholder="파일명.pdf">
				</td>
			</tr>
		</table>
		<button type="submit">삭제</button>
	</form>
</body>
</html>