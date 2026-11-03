package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class deleteflight extends HttpServlet {
    private String db;
    @Override public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            try (Connection connection = DatabaseConfig.connect(db);
                 PreparedStatement statement = connection.prepareStatement("DELETE FROM flightmaster WHERE flightid = ?")) {
                statement.setInt(1, id);
                if (statement.executeUpdate() == 0) request.getSession().setAttribute("error", "Flight not found.");
                else request.getSession().setAttribute("success", "Flight deleted.");
            }
        } catch (Exception e) {
            getServletContext().log("Could not delete flight", e);
            request.getSession().setAttribute("error", "This flight could not be deleted. Existing reservations may refer to it.");
        }
        response.sendRedirect("viewflights.jsp");
    }
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }
}
