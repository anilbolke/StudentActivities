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
 * Live exam state: which question is on the presenter screen right now.
 * The presenter (takeExam.jsp) POSTs on start / Next / Finish;
 * the clicker bridge GETs it to know which question incoming answers belong to.
 *
 * GET  /api/liveState?examId=N
 *   -> {"examId":19,"questionId":113,"questionNumber":3,"totalQuestions":5,"status":"RUNNING"}
 *
 * POST /api/liveState
 *   examId, questionId, questionNumber, totalQuestions, status(RUNNING|FINISHED)
 */
@WebServlet("/api/liveState")
public class LiveStateServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            int examId = Integer.parseInt(req.getParameter("examId"));
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "SELECT current_question_id, question_number, total_questions, status " +
                         "FROM exam_live_state WHERE exam_id = ?")) {
                ps.setInt(1, examId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        out.print("{\"examId\":" + examId
                                + ",\"questionId\":" + rs.getInt("current_question_id")
                                + ",\"questionNumber\":" + rs.getInt("question_number")
                                + ",\"totalQuestions\":" + rs.getInt("total_questions")
                                + ",\"status\":\"" + rs.getString("status") + "\"}");
                    } else {
                        resp.setStatus(404);
                        out.print("{\"status\":\"error\",\"message\":\"No live session for exam " + examId + "\"}");
                    }
                }
            }
        } catch (NumberFormatException e) {
            resp.setStatus(400);
            out.print("{\"status\":\"error\",\"message\":\"examId must be a number\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            out.print("{\"status\":\"error\",\"message\":\"server error\"}");
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
            int questionNumber = Integer.parseInt(req.getParameter("questionNumber"));
            int totalQuestions = Integer.parseInt(req.getParameter("totalQuestions"));
            String status = "FINISHED".equals(req.getParameter("status")) ? "FINISHED" : "RUNNING";

            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "INSERT INTO exam_live_state (exam_id, current_question_id, question_number, total_questions, status) " +
                         "VALUES (?, ?, ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE current_question_id = VALUES(current_question_id), " +
                         "question_number = VALUES(question_number), total_questions = VALUES(total_questions), " +
                         "status = VALUES(status)")) {
                ps.setInt(1, examId);
                ps.setInt(2, questionId);
                ps.setInt(3, questionNumber);
                ps.setInt(4, totalQuestions);
                ps.setString(5, status);
                ps.executeUpdate();
            }

            out.print("{\"status\":\"ok\"}");

        } catch (NumberFormatException e) {
            resp.setStatus(400);
            out.print("{\"status\":\"error\",\"message\":\"All ids must be numbers\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            out.print("{\"status\":\"error\",\"message\":\"server error\"}");
        }
    }
}
