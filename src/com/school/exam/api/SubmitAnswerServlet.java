package com.school.exam.api;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.school.exam.util.DatabaseConnection;

/**
 * Answer API for remote response devices (clicker bridge, answer pads).
 *
 * POST /api/answer
 *   examId     - the running exam
 *   questionId - question being answered (must belong to the exam)
 *   answer     - A | B | C | D
 *   studentId  - the student's ID (must exist in users AND students)
 *   clickerId  - alternative to studentId: physical keypad ID resolved via clicker_map
 *
 * The server computes is_correct / marks_obtained itself and never reveals
 * correctness in the response. Re-answers update the previous row
 * (unique key on exam_id + student_id + question_id).
 */
@WebServlet("/api/answer")
public class SubmitAnswerServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * GET /api/answer?examId=N&questionId=M[&demo=1]
     * Returns which clickers have answered the given question:
     *   {"total":30,"answered":["K01","K05",...]}
     * With demo=1 (hardware still in development) each poll also simulates
     * a few dummy remotes sending their answer, so the board fills up live.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            int examId = Integer.parseInt(req.getParameter("examId"));
            int questionId = Integer.parseInt(req.getParameter("questionId"));
            boolean demo = "1".equals(req.getParameter("demo"));

            try (Connection conn = DatabaseConnection.getConnection()) {

                if (demo) {
                    simulateIncomingAnswers(conn, examId, questionId);
                }

                StringBuilder json = new StringBuilder();
                int total = 0;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT cm.clicker_id, " +
                        "EXISTS(SELECT 1 FROM exam_answers ea WHERE ea.exam_id = ? " +
                        "AND ea.question_id = ? AND ea.student_id = cm.student_id) AS has_answer " +
                        "FROM clicker_map cm WHERE cm.active = 1 ORDER BY cm.clicker_id")) {
                    ps.setInt(1, examId);
                    ps.setInt(2, questionId);
                    try (ResultSet rs = ps.executeQuery()) {
                        boolean first = true;
                        while (rs.next()) {
                            total++;
                            if (rs.getBoolean("has_answer")) {
                                if (!first) json.append(",");
                                json.append("\"").append(rs.getString("clicker_id")).append("\"");
                                first = false;
                            }
                        }
                    }
                }

                out.print("{\"total\":" + total + ",\"answered\":[" + json + "]}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(400);
            out.print("{\"status\":\"error\",\"message\":\"examId and questionId must be numbers\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            out.print("{\"status\":\"error\",\"message\":\"server error\"}");
        }
    }

    /**
     * Demo trickle: pick a few dummy remotes that have not answered this
     * question yet and record an answer for them (weighted ~70% correct).
     */
    private void simulateIncomingAnswers(Connection conn, int examId, int questionId) throws Exception {
        java.util.Random rnd = new java.util.Random();

        // Some polls nobody presses a key - keeps the board realistic
        if (rnd.nextInt(100) < 15) return;

        // Answer key for this question (also confirms it belongs to the exam)
        String key = null;
        int marks = 0;
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT q.correct_answer, q.marks FROM exam_questions_map m " +
                "JOIN questions q ON q.question_id = m.question_id " +
                "WHERE m.exam_id = ? AND m.question_id = ?")) {
            ps.setInt(1, examId);
            ps.setInt(2, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    key = rs.getString(1);
                    marks = rs.getInt(2);
                }
            }
        }
        if (key == null) return;

        // Dummy remotes that have not answered this question yet
        java.util.List<Integer> pending = new java.util.ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(
                "SELECT cm.student_id FROM clicker_map cm WHERE cm.active = 1 " +
                "AND NOT EXISTS (SELECT 1 FROM exam_answers ea WHERE ea.exam_id = ? " +
                "AND ea.question_id = ? AND ea.student_id = cm.student_id)")) {
            ps.setInt(1, examId);
            ps.setInt(2, questionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) pending.add(rs.getInt(1));
            }
        }
        if (pending.isEmpty()) return;

        java.util.Collections.shuffle(pending, rnd);
        int burst = Math.min(1 + rnd.nextInt(3), pending.size());

        String[] optionLetters = {"A", "B", "C", "D"};
        try (PreparedStatement ins = conn.prepareStatement(
                "INSERT INTO exam_answers (exam_id, student_id, question_id, selected_answer, " +
                "correct_answer, is_correct, marks_obtained, time_taken_seconds, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ATTEMPTED') " +
                "ON DUPLICATE KEY UPDATE selected_answer = VALUES(selected_answer), " +
                "is_correct = VALUES(is_correct), marks_obtained = VALUES(marks_obtained)")) {
            for (int i = 0; i < burst; i++) {
                int sid = pending.get(i);
                boolean correct = rnd.nextInt(100) < 70;
                String ans;
                if (correct) {
                    ans = key;
                } else {
                    do { ans = optionLetters[rnd.nextInt(4)]; } while (ans.equals(key));
                }
                ins.setInt(1, examId);
                ins.setInt(2, sid);
                ins.setInt(3, questionId);
                ins.setString(4, ans);
                ins.setString(5, key);
                ins.setBoolean(6, correct);
                ins.setInt(7, correct ? marks : 0);
                ins.setInt(8, 5 + rnd.nextInt(40));
                ins.addBatch();
            }
            ins.executeBatch();
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            int examId = Integer.parseInt(req.getParameter("examId"));
            int questionId = Integer.parseInt(req.getParameter("questionId"));
            String answer = req.getParameter("answer");
            String clickerId = req.getParameter("clickerId");

            if (answer == null || !answer.matches("[ABCD]")) {
                fail(resp, out, "answer must be A, B, C or D");
                return;
            }

            try (Connection conn = DatabaseConnection.getConnection()) {

                // Resolve student: direct studentId, or clickerId via clicker_map
                int studentId = -1;
                if (clickerId != null && !clickerId.isEmpty()) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "SELECT student_id FROM clicker_map WHERE clicker_id = ? AND active = 1")) {
                        ps.setString(1, clickerId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) studentId = rs.getInt(1);
                        }
                    }
                    if (studentId < 0) {
                        fail(resp, out, "Clicker " + clickerId + " is not mapped to any student");
                        return;
                    }
                } else {
                    String sidParam = req.getParameter("studentId");
                    if (sidParam == null || sidParam.isEmpty()) {
                        fail(resp, out, "Provide studentId or clickerId");
                        return;
                    }
                    studentId = Integer.parseInt(sidParam);
                }

                // Exam must be PUBLISHED and the question must belong to it;
                // fetch the answer key server-side
                String key = null;
                int marks = 0;
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT q.correct_answer, q.marks FROM exam_questions_map m " +
                        "JOIN questions q ON q.question_id = m.question_id " +
                        "JOIN exams e ON e.exam_id = m.exam_id " +
                        "WHERE m.exam_id = ? AND m.question_id = ? AND e.status = 'PUBLISHED'")) {
                    ps.setInt(1, examId);
                    ps.setInt(2, questionId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            key = rs.getString(1);
                            marks = rs.getInt(2);
                        }
                    }
                }
                if (key == null) {
                    fail(resp, out, "Question " + questionId + " is not part of exam " + examId);
                    return;
                }

                // Student must exist in BOTH users and students (same ID)
                try (PreparedStatement ps = conn.prepareStatement(
                        "SELECT (SELECT COUNT(*) FROM users WHERE user_id = ?) + " +
                        "(SELECT COUNT(*) FROM students WHERE student_id = ?)")) {
                    ps.setInt(1, studentId);
                    ps.setInt(2, studentId);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) < 2) {
                            fail(resp, out, "Student " + studentId + " is not registered for remote answering");
                            return;
                        }
                    }
                }

                // Score on the server and upsert (re-answer replaces, never duplicates)
                boolean correct = answer.equals(key);
                try (PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO exam_answers (exam_id, student_id, question_id, " +
                        "selected_answer, correct_answer, is_correct, marks_obtained, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, 'ATTEMPTED') " +
                        "ON DUPLICATE KEY UPDATE selected_answer = VALUES(selected_answer), " +
                        "is_correct = VALUES(is_correct), marks_obtained = VALUES(marks_obtained)")) {
                    ps.setInt(1, examId);
                    ps.setInt(2, studentId);
                    ps.setInt(3, questionId);
                    ps.setString(4, answer);
                    ps.setString(5, key);
                    ps.setBoolean(6, correct);
                    ps.setInt(7, correct ? marks : 0);
                    ps.executeUpdate();
                }
            }

            out.print("{\"status\":\"ok\",\"received\":\"" + answer + "\"}");

        } catch (NumberFormatException e) {
            fail(resp, out, "examId, studentId and questionId must be numbers");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            out.print("{\"status\":\"error\",\"message\":\"server error\"}");
        }
    }

    private void fail(HttpServletResponse resp, PrintWriter out, String msg) {
        resp.setStatus(400);
        out.print("{\"status\":\"error\",\"message\":\"" + msg + "\"}");
    }
}
