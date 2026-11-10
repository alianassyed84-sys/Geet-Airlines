package servlet;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

/** Database settings shared by the servlets and JSP pages. */
public final class DatabaseConfig {
    private static volatile boolean fallbackToH2 = false;

    private DatabaseConfig() { }

    private static String h2Url() {
        String tmp = System.getProperty("java.io.tmpdir", "/tmp").replace('\\', '/');
        return "jdbc:h2:file:" + tmp + "/airline;AUTO_SERVER=TRUE;MODE=MySQL;DB_CLOSE_DELAY=-1";
    }

    public static String url(String database) {
        if (fallbackToH2) return h2Url();
        String configured = System.getenv("AIRLINE_DB_URL");
        if (configured != null && !configured.trim().isEmpty()) return configured;
        return h2Url();
    }

    public static String driver() {
        if (fallbackToH2) return "org.h2.Driver";
        String configured = System.getenv("AIRLINE_DB_DRIVER");
        if (configured != null && !configured.trim().isEmpty()) return configured;
        return url("airline").startsWith("jdbc:h2:") ? "org.h2.Driver" : "com.mysql.cj.jdbc.Driver";
    }

    public static String user() {
        if (fallbackToH2) return "sa";
        String value = System.getenv("AIRLINE_DB_USER");
        if (value != null && !value.isEmpty()) return value;
        return url("airline").startsWith("jdbc:h2:") ? "sa" : "airline_app";
    }

    public static String password() {
        if (fallbackToH2) return "";
        String value = System.getenv("AIRLINE_DB_PASSWORD");
        if (value != null) return value;
        return url("airline").startsWith("jdbc:h2:") ? "" : "airline_dev";
    }

    public static Connection connect(String database) throws SQLException {
        try {
            Class.forName(driver());
            Connection conn = DriverManager.getConnection(url(database), user(), password());
            // Quick check if usermaster exists; if not, initialize tables
            ensureTables(conn);
            return conn;
        } catch (Exception ex) {
            // If external database failed and not using H2 yet, fallback to H2
            if (!fallbackToH2) {
                System.err.println("Notice: Database connection to " + url(database) + " failed: " + ex.getMessage() + ". Falling back to embedded H2.");
                fallbackToH2 = true;
                try {
                    Class.forName("org.h2.Driver");
                    Connection fallbackConn = DriverManager.getConnection(h2Url(), "sa", "");
                    ensureTables(fallbackConn);
                    return fallbackConn;
                } catch (Exception h2Err) {
                    throw new SQLException("Database error: " + ex.getMessage(), ex);
                }
            }
            throw new SQLException("Database error: " + ex.getMessage(), ex);
        }
    }

    public static synchronized void ensureTables(Connection conn) {
        try (Statement check = conn.createStatement()) {
            check.execute("SELECT 1 FROM usermaster LIMIT 1");
        } catch (Exception tableMissing) {
            // Tables do not exist yet, load and execute init schema
            try (InputStream in = DatabaseConfig.class.getResourceAsStream("/h2-init.sql")) {
                if (in != null) {
                    try (BufferedReader reader = new BufferedReader(new InputStreamReader(in, StandardCharsets.UTF_8));
                         Statement statement = conn.createStatement()) {
                        StringBuilder sql = new StringBuilder();
                        String line;
                        while ((line = reader.readLine()) != null) {
                            String trimmed = line.trim();
                            if (trimmed.isEmpty() || trimmed.startsWith("--")) continue;
                            sql.append(trimmed).append(' ');
                            if (trimmed.endsWith(";")) {
                                statement.execute(sql.substring(0, sql.length() - 1));
                                sql.setLength(0);
                            }
                        }
                        if (sql.length() > 0) statement.execute(sql.toString());
                    }
                }
            } catch (Exception initErr) {
                System.err.println("Could not auto-create tables: " + initErr.getMessage());
            }
        }
    }
}
