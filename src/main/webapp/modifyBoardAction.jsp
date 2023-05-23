<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.MultipartRequest" %>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "vo.*" %>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + "<--dir");
	
	int max = 10 * 1024 * 1024; 

 	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());	
	//System.out.println(mRequest.getOriginalFileName("boardFile") + "<-- boardFile");
 	//mRequest.getOriginalFileName("boardFile") 값이 null이면 board테이블에 title만 수정
 
 	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/Fileuploade";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	//변수
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
 	String boardTitle = mRequest.getParameter("boardTitle");
 	
 		System.out.println(boardNo + "<--boardNo");
 		System.out.println(boardFileNo + "<--boardFileNo");
 		System.out.println(boardTitle + "<--boardTitle");
 	
 	// 1.board_title 수정
	PreparedStatement boardStmt = null;
	String boardSql="UPDATE board SET board_title=? WHERE board_no = ?";
	boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boardRow = boardStmt.executeUpdate();
 	
 	// 2.이전 boardFile을 삭제 & 새로운 boardFile 추가 & 테이블 수정
 	if(mRequest.getOriginalFileName("boardFile") != null) {
		//수정할 파일이 있으면 
		//pdf 파일 확인 유효성 검사 -> 아닐경우 새로운 파일 삭제 & 메시지
		if(mRequest.getContentType("boardFile").equals("application/pdf") == false){ //pef파일 확인
			//이미 저장된 새로운 파일 삭제
			String saveFilename = mRequest.getFilesystemName("boardFile");
			System.out.println("PDF파일이 아닙니다");
			File f = new File(dir + "/" + saveFilename);
			if(f.exists()) {//PDF가 아닌 새로 저장된 파일을 삭제한다 
				f.delete();
				System.out.println(dir + "/" + saveFilename + "파일삭제");
			}			
		} else { 
			// PDF파일이면 
			// 1) 이전파일(saveFilename) 삭제  
			// 2) db수정(update)
			String type = mRequest.getContentType("boardFile");
			String originFilename = mRequest.getOriginalFileName("boardFile");
			String saveFilename = mRequest.getFilesystemName("boardFile");

			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			// 1) 이전파일(saveFilename) 삭제
			PreparedStatement saveFilenameStmt = null;
			ResultSet saveFilenameRs = null;
			String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no = ?";
			saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
			saveFilenameRs = saveFilenameStmt.executeQuery();
			
			String preSaveFilename = " ";
			if(saveFilenameRs.next()) {
				preSaveFilename = saveFilenameRs.getString("save_filename");
			}
			File f = new File(dir + "/" + preSaveFilename);
			if(f.exists()) { // 이전파일 삭제
				f.delete();
			}
			
			//2) db수정(update)
			PreparedStatement boardFileStmt = null;
			ResultSet boardFileRs = null;
			String boardFileSql = "UPDATE board_file SET origin_filename = ?, save_filename = ? WHERE board_file_no =?";
			boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			int boardFielRow = boardFileStmt.executeUpdate();
		}
 	}
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
%>