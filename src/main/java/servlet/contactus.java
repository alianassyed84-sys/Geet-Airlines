package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class contactus extends HttpServlet {
    private String db;
    @Override public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = value(request, "name");
        String email = value(request, "email");
        String message = value(request, "message");
        try {
            int userId = Integer.parseInt(String.valueOf(request.getSession().getAttribute("userid")));
            if (name.isEmpty() || email.isEmpty() || message.isEmpty()) throw new IllegalArgumentException();
            try (Connection connection = DatabaseConfig.connect(db);
                 PreparedStatement statement = connection.prepareStatement(
                         "INSERT INTO contactus(name,email,message,userid) VALUES(?,?,?,?)")) {
                statement.setString(1, name);
                statement.setString(2, email);
                statement.setString(3, message);
                statement.setInt(4, userId);
                statement.executeUpdate();
            }
            request.getSession().setAttribute("success", "Your message has been saved. Thank you.");
        } catch (IllegalArgumentException e) {
            request.getSession().setAttribute("error", "Please fill in your name, email, and message.");
        } catch (Exception e) {
            getServletContext().log("Could not save contact message", e);
            request.getSession().setAttribute("error", "Your message could not be saved. Please try again.");
        }
        response.sendRedirect("contact.jsp");
    }
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("contact.jsp");
    }
    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
