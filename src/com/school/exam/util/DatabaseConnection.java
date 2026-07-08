package com.school.exam.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DatabaseConnection Utility Class
 * Provides a static method to get MySQL database connections
 * Loads MySQL JDBC driver and manages connection lifecycle
 */
public class DatabaseConnection {

    // Database Configuration
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String DB_URL = "jdbc:mysql://localhost:3306/school_exam_system?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "root";
    
    // Alternative configuration (if needed)
    // private static final String DB_URL = "jdbc:mysql://localhost:3306/student_activities?useSSL=false&serverTimezone=UTC";

    static {
        try {
            // Load MySQL JDBC Driver
            Class.forName(DB_DRIVER);
            System.out.println("[DB] MySQL JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("[DB ERROR] Failed to load MySQL JDBC Driver");
            System.err.println("[DB ERROR] Make sure mysql-connector-java JAR is in classpath");
            e.printStackTrace();
        }
    }

    /**
     * Get a database connection
     * @return Connection object to MySQL database
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            return conn;
        } catch (SQLException e) {
            System.err.println("[DB ERROR] Failed to connect to database");
            System.err.println("[DB ERROR] URL: " + DB_URL);
            System.err.println("[DB ERROR] User: " + DB_USER);
            System.err.println("[DB ERROR] Exception: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Test database connection (for debugging)
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("[DB] ✓ Database connection successful!");
                return true;
            }
        } catch (SQLException e) {
            System.err.println("[DB] ✗ Database connection failed!");
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Print connection info (for debugging)
     */
    public static void printConnectionInfo() {
        System.out.println("=".repeat(50));
        System.out.println("Database Configuration");
        System.out.println("=".repeat(50));
        System.out.println("Driver: " + DB_DRIVER);
        System.out.println("URL: " + DB_URL);
        System.out.println("User: " + DB_USER);
        System.out.println("=".repeat(50));
    }
}
