package servlet;

import java.sql.Connection;
import java.sql.DriverManager;

/** Database settings shared by the legacy servlets and JSP pages. */
public final class DatabaseConfig {
    private DatabaseConfig() { }

    public static String url(String database) {
        String configured = System.getenv("AIRLINE_DB_URL");
        if (configured != null && !configured.trim().isEmpty()) return configured;
        return "jdbc:mysql://localhost:3306/" + database
                + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    }

    public static String driver() {
        String configured = System.getenv("AIRLINE_DB_DRIVER");
        if (configured != null && !configured.trim().isEmpty()) return configured;
        return url("airline").startsWith("jdbc:h2:") ? "org.h2.Driver" : "com.mysql.cj.jdbc.Driver";
    }

    public static String user() {
        String value = System.getenv("AIRLINE_DB_USER");
        if (value != null && !value.isEmpty()) return value;
        return url("airline").startsWith("jdbc:h2:") ? "sa" : "airline_app";
    }

    public static String password() {
        String value = System.getenv("AIRLINE_DB_PASSWORD");
        if (value != null) return value;
        return url("airline").startsWith("jdbc:h2:") ? "" : "airline_dev";
    }

    public static Connection connect(String database) throws java.sql.SQLException {
        try {
            Class.forName(driver());
        } catch (ClassNotFoundException e) {
            throw new java.sql.SQLException("JDBC driver not found: " + driver(), e);
        }
        return DriverManager.getConnection(url(database), user(), password());
    }
}
