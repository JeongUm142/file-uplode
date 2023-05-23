<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*"%>
<%@ page import = "com.oreilly.servlet.MultipartRequest" %>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*" %>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir);

	int max = 10 * 1024 * 1024; 
	// request객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑
 	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());	
	
	// MultipartRequest API를 사용하여 스트림내에서 문자값을 반환받을 수 있다
	
	//업로드 된 컨텐츠파일이 PDF파일이 아니면 돌아가
	if(mRequest.getContentType("boardFile").equals("application/pdf") == false){
		//이미 저장된 파일 삭제
		String saveFilename = mRequest.getOriginalFileName("boardFile");
		System.out.println("PDF파일이 아닙니다");
		//윈도우는 \로 이를 표현할때는 \\
		File f = new File(dir + "/" + saveFilename); // new File("d:/abc/uploysign.gif")
		if(f.exists()) {
			f.delete();
			System.out.println(dir + "/" + saveFilename + "파일삭제");
		}
		response.sendRedirect(request.getContextPath()+"/"); //주소입력해야함
		return;
	}
	
	//1) input type = "text" 값변환 API --> board테이블에 저장
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	
	//2) input type="file" 값(파일 메타 정보) 반환 API(원본파일이름, 저장된파일이름, 컨텐츠타입)
		//->board_file테이블 저장
	//파일(바이너리)은 이미 MultipartRequest객체 생성시(requset랩핑시, 10라인)에서 저장
	String type = mRequest.getContentType("boardFile");
	String originFilename = mRequest.getOriginalFileName("boardFile");
	String saveFilename = mRequest.getOriginalFileName("boardFile");
	
	BoardFile boardFile = new BoardFile();
	//boardFile.setBoardNo(boardNo);
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
		System.out.println(type + "<--type");
		System.out.println(originFilename + "<--originFilename");
		System.out.println(saveFilename + "<--saveFilename");
	
	/*
		INSERT INTO board(board_title, member_id, createdate, updatedate)
		VALUES(?,?,now(),now());
	
		INSERT INTO board_file(board_no, arigin_filename, save_filename, path, type, createdate, updatedate)
		VALUES(?,?,?,?,?,now(),now());
	*/
	
	/*
		INSERT쿼리 실행 후 기본키값 받아오기 JDBC API
		String sql = "INSERT 쿼리문";
		pstmt - conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
		int row
	*/
	
	String driver = "org.mariadb.jdbc.Driver";
	String dburl = "jdbc:mariadb://127.0.0.1:3306/Fileuploade";
	String dbuser = "root";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	PreparedStatement boardStmt = null;
	ResultSet keyRs = null;
	String boardSql = "INSERT INTO board(board_title, member_id, createdate, updatedate) VALUES(?,?,now(),now())";
	boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS);
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	boardStmt.executeUpdate(); // board 입력 후 키값저장

	keyRs = boardStmt.getGeneratedKeys(); //저장된 키값을 반환	
	
	int boardNo = 0;
	if(keyRs.next()){
		boardNo = keyRs.getInt(1);
		response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	}
	
	PreparedStatement keyStmt = null;
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?,?,?,?,'upload',now())";
	keyStmt = conn.prepareStatement(fileSql);
	keyStmt.setInt(1, boardNo);
	keyStmt.setString(2, originFilename);
	keyStmt.setString(3, saveFilename);
	keyStmt.setString(4, type);
	
	keyStmt.executeUpdate();// board_file입력
%>