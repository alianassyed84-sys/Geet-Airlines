package servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class edithandler extends HttpServlet {
    private String db;
    @Override public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("flightno"));
            String provider = value(request, "fprovider");
            String source = value(request, "fsource");
            String destination = value(request, "fdest");
            String duration = value(request, "ftime");
            BigDecimal price = new BigDecimal(value(request, "price"));
            if (id < 1 || source.equals(destination) || price.signum() < 0) throw new IllegalArgumentException();
            try (Connection connection = DatabaseConfig.connect(db);
                 PreparedStatement statement = connection.prepareStatement(
                         "UPDATE flightmaster SET provider=?, source=?, destination=?, duration=?, price=? WHERE flightid=?")) {
                statement.setString(1, provider);
                statement.setString(2, source);
                statement.setString(3, destination);
                statement.setString(4, duration);
                statement.setBigDecimal(5, price);
                statement.setInt(6, id);
                if (statement.executeUpdate() == 0) throw new IllegalArgumentException();
            }
            request.getSession().setAttribute("success", "Flight updated successfully.");
        } catch (IllegalArgumentException e) {
            request.getSession().setAttribute("error", "Please enter valid flight details.");
        } catch (Exception e) {
            getServletContext().log("Could not update flight", e);
            request.getSession().setAttribute("error", "Could not update the flight. Check the database and try again.");
        }
        response.sendRedirect("viewflights.jsp");
    }
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("viewflights.jsp");
    }
    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
