<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.MultipartRequest" %>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import	="java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.net.*"%>
<%@ page import = "vo.*" %>
<%
	/* if(request.getParameter("boardNo")==null
		||request.getParameter("boardFileNo")==null) {
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
		return;
	} */

	String dir = request.getServletContext().getRealPath("/upload");
		System.out.println(dir + "<--dir");
	
	int max = 10 * 1024 * 1024; 
	
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());

	//변수
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String fileNameRe = mRequest.getParameter("fileNameRe");
	String type = mRequest.getParameter("type");
	String originFilename = mRequest.getParameter("originFilename");
	String saveFilename = mRequest.getParameter("saveFilename");

		System.out.println(boardNo+ "<--boardNoA");
		System.out.println(boardFileNo + "<--boardFileNoA");
		System.out.println(fileNameRe + "<--fileNameRe");
		System.out.println(type + "<--type");
		System.out.println(originFilename + "<--originFilename");
		System.out.println(saveFilename + "<--saveFilename");
		
			
	String msg = "";

	if(!originFilename.equals(fileNameRe)) {
		msg = URLEncoder.encode("파일명을 다시 입력해주세요.", "utf-8");
		response.sendRedirect(request.getContextPath() + "/deleteBoard.jsp?boardNo=" + boardNo + "&boardFileNo=" + boardFileNo + "&msg=" + msg);
		return;
	}
	
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/Fileuploade";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	BoardFile boardFile = new BoardFile();
	boardFile.setBoardFileNo(boardFileNo);
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	PreparedStatement boardDelStmt = null;
	ResultSet boardDelRs = null;
	String boardDelSql = "SELECT save_filename FROM board_file WHERE board_file_no = ?";
	boardDelStmt = conn.prepareStatement(boardDelSql);
	boardDelStmt.setInt(1, boardFile.getBoardFileNo());
	boardDelRs = boardDelStmt.executeQuery();
	
	String preSaveFilename = " ";
	if(boardDelRs.next()) {
		preSaveFilename = boardDelRs.getString("save_filename");
	}
	File f = new File(dir + "/" + preSaveFilename);
	if(f.exists()) { // 이전파일 삭제
		f.delete();
	}

%>