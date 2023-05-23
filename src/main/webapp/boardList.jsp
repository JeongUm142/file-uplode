<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	/*
		SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path, f.type, f.createdate  
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC;
		*/
	
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/Fileuploade";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle,f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, f.type, f.path, f.createdate FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	stmt = conn.prepareStatement(sql);
	rs = stmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
	
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", rs.getString("boardNo"));
		m.put("boardTitle", rs.getString("boardTitle"));
		m.put("boardFileNo", rs.getString("boardFileNo"));
		m.put("originFilename", rs.getString("originFilename"));
		m.put("saveFilename", rs.getString("saveFilename"));
		m.put("path", rs.getString("path"));
		list.add(m);
	}
		
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Insert title here</title>
	<!-- Latest compiled and minified CSS -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">		
</head>
<body>
	<h1>PDF 자료 목록</h1>
	<table class="table table-bordered">
		<tr>
			<td>boardTitle</td>
			<td>originFilename</td>
			<td>수정</td>
			<td>삭제</td>
		</tr>
		<%
			for(HashMap<String, Object> m :list) {	
		%>
			<tr>
				<td><%=(String)m.get("boardTitle") %></td>
				<td><a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
						<%=(String)m.get("originFilename")%>
					</a>
                </td>
                <td><a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>" >수정</a></td>
                <td><a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a></td>
			</tr>
		<%
			}		
		%>
	</table>
</body>
</html>