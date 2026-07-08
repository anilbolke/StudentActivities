<%@ page import="java.util.*, java.sql.*, com.school.exam.model.*, com.school.exam.dao.*, com.school.exam.util.DatabaseConnection" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    // Check if user is authenticated
    Object userRole = session.getAttribute("userRole");
    Integer userId = (Integer) session.getAttribute("userId");
    Integer schoolId = (Integer) session.getAttribute("schoolId");

    if (userRole == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if (!userRole.equals("STUDENT") && !userRole.equals("TEACHER") && !userRole.equals("ADMIN")) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get exam ID from request
    int examId = -1;
    try {
        examId = Integer.parseInt(request.getParameter("examId"));
    } catch (NumberFormatException e) {
        e.printStackTrace();
    }

    if (examId <= 0) {
        out.println("<h2>Invalid Exam ID</h2>");
        return;
    }

    // Get exam and questions
    Exam exam = ExamDAO.getExamById(examId);
    if (exam == null) {
        out.println("<h2>Exam not found</h2>");
        return;
    }

    List<Question> examQuestions = ExamDAO.getExamQuestions(examId);
    int totalQuestions = examQuestions.size();

    // ============================================================
    // DEMO MODE: hardware is still in development, so dummy remotes
    // (clickers K01-K30) answer via the polled status endpoint:
    // GET /api/answer?demo=1 trickles in a few answers per poll while
    // a question is on screen - the remotes board fills up live.
    // Set DEMO_MODE = false when the real hardware goes live.
    // ============================================================
    final boolean DEMO_MODE = true;

    // All registered remotes, shown on the board (green = answered, red = pending)
    List<String> clickerIds = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
                 "SELECT clicker_id FROM clicker_map WHERE active = 1 ORDER BY clicker_id");
         ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            clickerIds.add(rs.getString(1));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    // Handle exam finish:
    // Answers arrive from the remote response system (API) into exam_answers.
    // On finish, calculate & store results for every student who answered this exam.
    String finishMessage = "";
    int studentsProcessed = 0;
    List<String[]> responseRows = new ArrayList<>();      // per-student results
    List<int[]> questionStats = new ArrayList<>();        // per-question A/B/C/D counts
    if ("finish".equals(request.getParameter("action"))) {
        List<Integer> answeredStudentIds = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Keep exam total_marks in sync with the actual question marks,
            // otherwise percentages can exceed 100%
            try (PreparedStatement fix = conn.prepareStatement(
                    "UPDATE exams e SET e.total_marks = (SELECT COALESCE(SUM(q.marks),0) FROM exam_questions_map m " +
                    "JOIN questions q ON q.question_id = m.question_id WHERE m.exam_id = e.exam_id) WHERE e.exam_id = ?")) {
                fix.setInt(1, examId);
                fix.executeUpdate();
            }

            try (PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT DISTINCT student_id FROM exam_answers WHERE exam_id = ?")) {
                pstmt.setInt(1, examId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        answeredStudentIds.add(rs.getInt("student_id"));
                    }
                }
            }

            // Tell the clicker bridge the session is over
            try (PreparedStatement done = conn.prepareStatement(
                    "UPDATE exam_live_state SET status = 'FINISHED' WHERE exam_id = ?")) {
                done.setInt(1, examId);
                done.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        for (Integer sid : answeredStudentIds) {
            if (ResultDAO.calculateAndStoreResult(examId, sid)) {
                studentsProcessed++;
            }
        }

        // Collect responses for display on the finish screen
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Per-student results, best first
            try (PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT s.student_name, r.attempted_questions, r.correct_answers, r.wrong_answers, " +
                    "r.marks_obtained, r.total_marks, r.percentage, r.grade " +
                    "FROM exam_results r JOIN students s ON s.student_id = r.student_id " +
                    "WHERE r.exam_id = ? ORDER BY r.percentage DESC, s.student_name")) {
                pstmt.setInt(1, examId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        responseRows.add(new String[] {
                            rs.getString("student_name"),
                            String.valueOf(rs.getInt("attempted_questions")),
                            String.valueOf(rs.getInt("correct_answers")),
                            String.valueOf(rs.getInt("wrong_answers")),
                            rs.getInt("marks_obtained") + " / " + rs.getInt("total_marks"),
                            String.format("%.1f", rs.getDouble("percentage")),
                            rs.getString("grade")
                        });
                    }
                }
            }

            // Per-question option distribution (A/B/C/D counts + correct count)
            try (PreparedStatement pstmt = conn.prepareStatement(
                    "SELECT question_id, " +
                    "SUM(selected_answer='A') AS a_cnt, SUM(selected_answer='B') AS b_cnt, " +
                    "SUM(selected_answer='C') AS c_cnt, SUM(selected_answer='D') AS d_cnt, " +
                    "SUM(is_correct) AS correct_cnt, COUNT(*) AS total_cnt " +
                    "FROM exam_answers WHERE exam_id = ? GROUP BY question_id")) {
                pstmt.setInt(1, examId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    Map<Integer, int[]> statsByQ = new HashMap<>();
                    while (rs.next()) {
                        statsByQ.put(rs.getInt("question_id"), new int[] {
                            rs.getInt("a_cnt"), rs.getInt("b_cnt"), rs.getInt("c_cnt"),
                            rs.getInt("d_cnt"), rs.getInt("correct_cnt"), rs.getInt("total_cnt")
                        });
                    }
                    for (Question q : examQuestions) {
                        int[] st = statsByQ.get(q.getQuestionId());
                        questionStats.add(st != null ? st : new int[6]);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (answeredStudentIds.isEmpty()) {
            finishMessage = "⚠️ Exam finished, but no answers were received from the remote system yet.<br>"
                    + "Results will be available once answers arrive.";
        } else {
            finishMessage = "✅ Exam finished successfully!<br>"
                    + "Answers received from <strong>" + answeredStudentIds.size() + "</strong> student(s).<br>"
                    + "Results calculated for <strong>" + studentsProcessed + "</strong> student(s).";
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam - Student Activities</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Comic Sans MS', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #74ebd5 0%, #ACB6E5 100%);
            min-height: 100vh;
            padding: 20px;
        }

        /* Floating decorations */
        .floaty {
            position: fixed;
            font-size: 40px;
            opacity: 0.35;
            animation: floatUp 12s linear infinite;
            pointer-events: none;
            z-index: 0;
        }

        @keyframes floatUp {
            0%   { transform: translateY(105vh) rotate(0deg); }
            100% { transform: translateY(-10vh) rotate(360deg); }
        }

        .container {
            max-width: 1000px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }

        /* ===== Exam header ===== */
        .exam-header {
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
            border-radius: 25px;
            padding: 18px 25px;
            margin-bottom: 20px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 15px;
        }

        .exam-header h1 {
            font-size: 24px;
            color: #6b2d5c;
            text-shadow: 1px 1px 0 rgba(255,255,255,0.6);
        }

        .remote-badge {
            background: rgba(255,255,255,0.8);
            color: #6b2d5c;
            border-radius: 18px;
            padding: 8px 18px;
            font-size: 14px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .remote-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
            background: #4caf50;
            animation: blink 1.2s ease-in-out infinite;
        }

        @keyframes blink {
            0%, 100% { opacity: 1; }
            50%      { opacity: 0.25; }
        }

        /* ===== Progress bar ===== */
        .progress-wrap {
            background: white;
            border-radius: 25px;
            padding: 15px 25px;
            margin-bottom: 20px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }

        .progress-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
            font-size: 16px;
        }

        .progress-track {
            background: #eee;
            border-radius: 20px;
            height: 22px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            width: 0%;
            background: linear-gradient(90deg, #f6d365, #fda085);
            border-radius: 20px;
            transition: width 0.4s ease;
        }

        /* Question dots: progress indicator only */
        .dots {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 12px;
            justify-content: center;
        }

        .dot {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 3px solid #ddd;
            background: white;
            color: #888;
            font-weight: bold;
            font-size: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .dot.done {
            background: #7ed957;
            border-color: #5cb944;
            color: white;
        }

        .dot.current {
            border-color: #ff8c42;
            background: #ffb347;
            color: white;
            transform: scale(1.2);
            box-shadow: 0 0 0 4px rgba(255, 179, 71, 0.35);
        }

        /* ===== Remotes board ===== */
        .remotes-panel {
            background: white;
            border-radius: 25px;
            padding: 15px 25px;
            margin-bottom: 20px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }

        .remotes-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: bold;
            color: #555;
            font-size: 16px;
            margin-bottom: 12px;
        }

        .remotes-count {
            background: #f0f8ff;
            border: 2px solid #89c4f4;
            color: #3d85c8;
            border-radius: 15px;
            padding: 4px 14px;
            font-size: 14px;
        }

        .remotes-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
        }

        .remote-chip {
            min-width: 52px;
            text-align: center;
            padding: 7px 10px;
            border-radius: 14px;
            font-weight: bold;
            font-size: 13px;
            transition: all 0.3s;
        }

        .remote-chip.pending {
            background: #ffe3e3;
            border: 2px solid #ff8a8a;
            color: #d64545;
            animation: waiting 1.6s ease-in-out infinite;
        }

        @keyframes waiting {
            0%, 100% { opacity: 1; }
            50%      { opacity: 0.55; }
        }

        .remote-chip.answered {
            background: #7ed957;
            border: 2px solid #5cb944;
            color: white;
            animation: none;
        }

        .remote-chip.answered::after {
            content: " ✓";
        }

        @media (prefers-reduced-motion: reduce) {
            .remote-chip.pending { animation: none; }
        }

        /* ===== Finish message ===== */
        .message {
            padding: 30px;
            border-radius: 25px;
            margin-bottom: 20px;
            background: white;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
            color: #1e40af;
            line-height: 2;
            font-weight: 600;
            font-size: 18px;
            text-align: center;
        }

        .result-emoji {
            font-size: 60px;
            margin-bottom: 10px;
        }

        /* ===== Responses (finish screen) ===== */
        .responses-card {
            background: white;
            border-radius: 25px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }

        .responses-card h2 {
            color: #6b2d5c;
            font-size: 20px;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 3px dashed #ffd166;
        }

        .table-scroll {
            overflow-x: auto;
        }

        .responses-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .responses-table th {
            background: linear-gradient(135deg, #a18cd1, #fbc2eb);
            color: white;
            padding: 10px 12px;
            text-align: left;
            white-space: nowrap;
        }

        .responses-table th:first-child { border-radius: 12px 0 0 0; }
        .responses-table th:last-child  { border-radius: 0 12px 0 0; }

        .responses-table td {
            padding: 9px 12px;
            border-bottom: 1px solid #f0f0f0;
            color: #444;
        }

        .responses-table tr:nth-child(even) td {
            background: #fafaff;
        }

        .grade-pill {
            display: inline-block;
            min-width: 32px;
            text-align: center;
            padding: 3px 10px;
            border-radius: 12px;
            font-weight: bold;
            color: white;
        }

        .grade-A { background: #4caf50; }
        .grade-B { background: #66a6ff; }
        .grade-C { background: #f59e0b; }
        .grade-D { background: #f97316; }
        .grade-F { background: #ff6b6b; }

        .opt-count {
            display: inline-block;
            min-width: 40px;
            text-align: center;
            padding: 3px 8px;
            border-radius: 10px;
            font-weight: bold;
            font-size: 13px;
        }

        .cnt-a { background: #ffe0e0; color: #e05656; }
        .cnt-b { background: #e0f0ff; color: #3d85c8; }
        .cnt-c { background: #e6ffe0; color: #4caf50; }
        .cnt-d { background: #fff3d6; color: #e0a114; }

        .opt-count.is-key {
            outline: 3px solid #7ed957;
        }

        /* ===== Question card (one at a time, display only) ===== */
        .question-slide {
            display: none;
            animation: popIn 0.35s ease;
        }

        .question-slide.active {
            display: block;
        }

        @keyframes popIn {
            0%   { opacity: 0; transform: scale(0.92) translateY(15px); }
            100% { opacity: 1; transform: scale(1) translateY(0); }
        }

        .question-card {
            background: white;
            border-radius: 30px;
            padding: 35px;
            box-shadow: 0 10px 35px rgba(0,0,0,0.15);
            border: 5px dashed #ffd166;
        }

        .question-badge {
            display: inline-block;
            background: linear-gradient(135deg, #a18cd1, #fbc2eb);
            color: white;
            font-weight: bold;
            font-size: 17px;
            padding: 8px 22px;
            border-radius: 20px;
            margin-bottom: 20px;
        }

        .question-text {
            color: #333;
            font-size: 30px;
            font-weight: bold;
            margin-bottom: 28px;
            line-height: 1.5;
        }

        .options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }

        @media (max-width: 650px) {
            .options {
                grid-template-columns: 1fr;
            }
        }

        /* Display-only option cards: students answer on their remote devices */
        .option-card {
            display: flex;
            align-items: center;
            padding: 20px;
            border-radius: 20px;
            font-size: 22px;
        }

        .option-a { background: #ffe0e0; }
        .option-b { background: #e0f0ff; }
        .option-c { background: #e6ffe0; }
        .option-d { background: #fff3d6; }

        .option-letter {
            width: 48px;
            height: 48px;
            min-width: 48px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 22px;
            margin-right: 15px;
            box-shadow: 0 3px 8px rgba(0,0,0,0.12);
        }

        .option-a .option-letter { color: #e05656; }
        .option-b .option-letter { color: #3d85c8; }
        .option-c .option-letter { color: #4caf50; }
        .option-d .option-letter { color: #e0a114; }

        .option-text {
            flex: 1;
            color: #444;
            font-weight: 600;
        }

        .answer-hint {
            margin-top: 25px;
            text-align: center;
            background: #f0f8ff;
            border: 2px dashed #89c4f4;
            border-radius: 18px;
            padding: 14px;
            font-size: 17px;
            font-weight: bold;
            color: #3d85c8;
        }

        /* ===== Navigation: Cancel + Next only ===== */
        .nav-buttons {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 25px;
            gap: 15px;
        }

        button {
            font-family: inherit;
            border: none;
            border-radius: 25px;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
            padding: 15px 40px;
            transition: all 0.25s;
            box-shadow: 0 5px 15px rgba(0,0,0,0.15);
        }

        button:hover {
            transform: translateY(-3px);
        }

        button:active {
            transform: translateY(1px);
        }

        .btn-next {
            background: linear-gradient(135deg, #f6d365, #fda085);
            color: white;
            font-size: 22px;
            padding: 16px 50px;
        }

        .btn-finish {
            background: linear-gradient(135deg, #7ed957, #4caf50);
            color: white;
            font-size: 22px;
            padding: 16px 50px;
        }

        .btn-cancel {
            background: linear-gradient(135deg, #ff9a9e, #ff6b6b);
            color: white;
        }

        .btn-primary {
            background: linear-gradient(135deg, #89f7fe, #66a6ff);
            color: white;
        }

        .center-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 25px;
            flex-wrap: wrap;
        }
    </style>
</head>
<body>
    <!-- Floating fun decorations -->
    <span class="floaty" style="left: 5%;  animation-delay: 0s;">🎈</span>
    <span class="floaty" style="left: 20%; animation-delay: 3s;">⭐</span>
    <span class="floaty" style="left: 45%; animation-delay: 6s;">🎈</span>
    <span class="floaty" style="left: 70%; animation-delay: 2s;">🌟</span>
    <span class="floaty" style="left: 88%; animation-delay: 5s;">🎉</span>

    <div class="container">
        <!-- Exam Header -->
        <div class="exam-header">
            <h1>📝 <%= exam.getExamName() %></h1>
            <div class="remote-badge">
                <span class="remote-dot"></span>
                Remote answering active
            </div>
        </div>

        <% if (!finishMessage.isEmpty()) { %>
            <!-- Finish summary -->
            <div class="message">
                <div class="result-emoji">🏁</div>
                <%= finishMessage %>
            </div>

            <!-- Per-question response distribution -->
            <% if (!questionStats.isEmpty()) { %>
            <div class="responses-card">
                <h2>📡 Responses per Question</h2>
                <div class="table-scroll">
                    <table class="responses-table">
                        <tr>
                            <th>#</th>
                            <th>Question</th>
                            <th>A</th>
                            <th>B</th>
                            <th>C</th>
                            <th>D</th>
                            <th>Correct</th>
                            <th>Responses</th>
                        </tr>
                        <% int qi = 0;
                           for (Question q : examQuestions) {
                               int[] st = questionStats.get(qi);
                               String key = q.getCorrectAnswer();
                               String qText = q.getQuestionText();
                               if (qText.length() > 60) qText = qText.substring(0, 60) + "…";
                        %>
                        <tr>
                            <td><strong><%= qi + 1 %></strong></td>
                            <td><%= qText %></td>
                            <td><span class="opt-count cnt-a <%= "A".equals(key) ? "is-key" : "" %>"><%= st[0] %></span></td>
                            <td><span class="opt-count cnt-b <%= "B".equals(key) ? "is-key" : "" %>"><%= st[1] %></span></td>
                            <td><span class="opt-count cnt-c <%= "C".equals(key) ? "is-key" : "" %>"><%= st[2] %></span></td>
                            <td><span class="opt-count cnt-d <%= "D".equals(key) ? "is-key" : "" %>"><%= st[3] %></span></td>
                            <td><strong style="color:#4caf50;"><%= st[4] %> ✓</strong></td>
                            <td><%= st[5] %></td>
                        </tr>
                        <% qi++; } %>
                    </table>
                </div>
                <p style="margin-top:10px; font-size:13px; color:#888;">The green-outlined count marks the correct option for each question.</p>
            </div>
            <% } %>

            <!-- Per-student responses -->
            <% if (!responseRows.isEmpty()) { %>
            <div class="responses-card">
                <h2>🧒 Student Responses (<%= responseRows.size() %>)</h2>
                <div class="table-scroll">
                    <table class="responses-table">
                        <tr>
                            <th>Rank</th>
                            <th>Student</th>
                            <th>Attempted</th>
                            <th>Correct</th>
                            <th>Wrong</th>
                            <th>Marks</th>
                            <th>%</th>
                            <th>Grade</th>
                        </tr>
                        <% int rank = 1;
                           for (String[] row : responseRows) {
                               String medal = rank == 1 ? "🥇" : (rank == 2 ? "🥈" : (rank == 3 ? "🥉" : String.valueOf(rank)));
                        %>
                        <tr>
                            <td><%= medal %></td>
                            <td><strong><%= row[0] %></strong></td>
                            <td><%= row[1] %></td>
                            <td style="color:#4caf50; font-weight:bold;"><%= row[2] %></td>
                            <td style="color:#ff6b6b; font-weight:bold;"><%= row[3] %></td>
                            <td><%= row[4] %></td>
                            <td><%= row[5] %>%</td>
                            <td><span class="grade-pill grade-<%= row[6] %>"><%= row[6] %></span></td>
                        </tr>
                        <% rank++; } %>
                    </table>
                </div>
            </div>
            <% } %>

            <div class="center-buttons">
                <button class="btn-primary" onclick="window.location.href='resultAnalysis.jsp?examId=<%= examId %>'">📊 View Result Analysis</button>
                <button class="btn-cancel" onclick="window.location.href='dashboard.jsp'">⬅ Back to Dashboard</button>
            </div>
        <% } else { %>

        <!-- Progress -->
        <div class="progress-wrap">
            <div class="progress-info">
                <span>🚀 Question <span id="currentNum">1</span> of <%= totalQuestions %></span>
                <span>📡 Answers via remote devices</span>
            </div>
            <div class="progress-track">
                <div class="progress-fill" id="progressFill"></div>
            </div>
            <div class="dots" id="dots">
                <% for (int d = 0; d < totalQuestions; d++) { %>
                    <span class="dot"><%= d + 1 %></span>
                <% } %>
            </div>
        </div>

        <!-- Remotes board: green = answered current question, red = pending -->
        <% if (!clickerIds.isEmpty()) { %>
        <div class="remotes-panel">
            <div class="remotes-head">
                <span>🎮 Remotes</span>
                <span class="remotes-count"><span id="remoteCount">0</span> / <%= clickerIds.size() %> answered</span>
            </div>
            <div class="remotes-grid">
                <% for (String cid : clickerIds) { %>
                    <span class="remote-chip pending" data-clicker="<%= cid %>"><%= cid %></span>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- Questions: one visible at a time, display only -->
        <% int questionNum = 1; %>
        <% for (Question question : examQuestions) { %>

        <div class="question-slide" data-index="<%= questionNum - 1 %>">
            <div class="question-card">
                <div class="question-badge">Question <%= questionNum %> of <%= totalQuestions %></div>

                <div class="question-text">
                    <%= question.getQuestionText() %>
                </div>

                <div class="options">
                    <div class="option-card option-a">
                        <span class="option-letter">A</span>
                        <span class="option-text"><%= question.getOptionA() %></span>
                    </div>

                    <div class="option-card option-b">
                        <span class="option-letter">B</span>
                        <span class="option-text"><%= question.getOptionB() %></span>
                    </div>

                    <div class="option-card option-c">
                        <span class="option-letter">C</span>
                        <span class="option-text"><%= question.getOptionC() %></span>
                    </div>

                    <div class="option-card option-d">
                        <span class="option-letter">D</span>
                        <span class="option-text"><%= question.getOptionD() %></span>
                    </div>
                </div>

                <div class="answer-hint">
                    📡 Press A, B, C or D on your remote device to answer!
                </div>
            </div>
        </div>

        <% questionNum++; %>
        <% } %>

        <!-- Navigation: Cancel + Next only -->
        <form method="post" action="takeExam.jsp?examId=<%= examId %>" id="finishForm">
            <input type="hidden" name="action" value="finish">
            <div class="nav-buttons">
                <button type="button" class="btn-cancel" onclick="if(confirm('Cancel this exam session?')) { history.back(); }">✖ Cancel</button>
                <button type="button" class="btn-next" id="btnNext" onclick="nextQuestion()">Next ➡</button>
                <button type="submit" class="btn-finish" id="btnFinish" style="display:none;">🏁 Finish Exam</button>
            </div>
        </form>

        <% } %>
    </div>

    <script>
        var totalQuestions = <%= totalQuestions %>;
        var currentIndex = 0;

        // Question IDs in presentation order - used to tell the clicker
        // bridge (via /api/liveState) which question is on screen
        var questionIds = [<%
            for (int qi2 = 0; qi2 < examQuestions.size(); qi2++) {
                out.print((qi2 > 0 ? "," : "") + examQuestions.get(qi2).getQuestionId());
            }
        %>];
        var examId = <%= examId %>;

        function postLiveState() {
            if (questionIds.length === 0) return;
            var body = new URLSearchParams({
                examId: examId,
                questionId: questionIds[currentIndex],
                questionNumber: currentIndex + 1,
                totalQuestions: totalQuestions,
                status: 'RUNNING'
            });
            fetch('api/liveState', { method: 'POST', body: body }).catch(function() {});
        }

        var slides = document.querySelectorAll('.question-slide');
        var dots = document.querySelectorAll('.dot');

        function refreshUI() {
            for (var i = 0; i < slides.length; i++) {
                slides[i].classList.toggle('active', i === currentIndex);
            }

            for (var j = 0; j < dots.length; j++) {
                dots[j].classList.toggle('current', j === currentIndex);
                dots[j].classList.toggle('done', j < currentIndex);
            }

            var el = document.getElementById('currentNum');
            if (el) el.textContent = currentIndex + 1;

            var fill = document.getElementById('progressFill');
            if (fill) fill.style.width = ((currentIndex + 1) * 100 / totalQuestions) + '%';

            var isLast = (currentIndex === totalQuestions - 1);
            var btnNext = document.getElementById('btnNext');
            var btnFinish = document.getElementById('btnFinish');
            if (btnNext) btnNext.style.display = isLast ? 'none' : 'inline-block';
            if (btnFinish) btnFinish.style.display = isLast ? 'inline-block' : 'none';
        }

        // ----- Remotes board: green = answered current question, red = pending -----
        var DEMO_MODE = <%= DEMO_MODE %>;
        var chips = document.querySelectorAll('.remote-chip');

        function resetRemotesBoard() {
            for (var i = 0; i < chips.length; i++) {
                chips[i].classList.remove('answered');
                chips[i].classList.add('pending');
            }
            var el = document.getElementById('remoteCount');
            if (el) el.textContent = '0';
        }

        function pollRemotes() {
            if (questionIds.length === 0 || chips.length === 0) return;
            var url = 'api/answer?examId=' + examId
                    + '&questionId=' + questionIds[currentIndex]
                    + (DEMO_MODE ? '&demo=1' : '');
            fetch(url)
                .then(function(r) { return r.json(); })
                .then(function(j) {
                    var answered = {};
                    for (var i = 0; i < j.answered.length; i++) answered[j.answered[i]] = true;
                    var count = 0;
                    for (var k = 0; k < chips.length; k++) {
                        var on = !!answered[chips[k].getAttribute('data-clicker')];
                        chips[k].classList.toggle('answered', on);
                        chips[k].classList.toggle('pending', !on);
                        if (on) count++;
                    }
                    var el = document.getElementById('remoteCount');
                    if (el) el.textContent = count;
                })
                .catch(function() {});
        }

        setInterval(pollRemotes, 2500);

        function nextQuestion() {
            if (currentIndex < totalQuestions - 1) {
                currentIndex++;
                refreshUI();
                postLiveState();
                resetRemotesBoard();
                pollRemotes();
            }
        }

        // Confirm before finishing the exam session
        var finishForm = document.getElementById('finishForm');
        if (finishForm) {
            finishForm.addEventListener('submit', function(e) {
                if (!confirm('Finish exam?\n\nResults will be calculated from the answers received so far.')) {
                    e.preventDefault();
                }
            });
        }

        // Forward-only keys for presenter clickers (Right arrow / Page Down / Space)
        document.addEventListener('keydown', function(e) {
            if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {
                e.preventDefault();
                nextQuestion();
            }
        });

        if (slides.length > 0) {
            refreshUI();
            postLiveState(); // announce question 1 to the clicker bridge
            pollRemotes();   // paint the remotes board immediately
        }
    </script>
</body>
</html>
