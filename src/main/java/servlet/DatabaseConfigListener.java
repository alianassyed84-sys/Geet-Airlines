package servlet;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.Statement;

public class DatabaseConfigListener implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent event) {
        ServletContext context = event.getServletContext();
        String database = context.getInitParameter("mysql-db");
        context.setAttribute("dbUrl", DatabaseConfig.url(database == null ? "airline" : database));
        context.setAttribute("dbUser", DatabaseConfig.user());
        context.setAttribute("dbPassword", DatabaseConfig.password());
        context.setAttribute("dbDriver", DatabaseConfig.driver());
        if (DatabaseConfig.url(database == null ? "airline" : database).startsWith("jdbc:h2:")) {
            initializeH2(context);
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) { }

    private void initializeH2(ServletContext context) {
        try (Connection connection = DatabaseConfig.connect("airline");
             InputStream input = getClass().getResourceAsStream("/h2-init.sql")) {
            if (input == null) throw new IllegalStateException("H2 schema file is missing.");
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(input, StandardCharsets.UTF_8));
                 Statement statement = connection.createStatement()) {
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
        } catch (Exception e) {
            context.log("Could not initialize embedded H2 database", e);
            throw new IllegalStateException("Embedded database startup failed.", e);
        }
    }
}
