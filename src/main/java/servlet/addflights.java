package servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class addflights extends HttpServlet {
    private String db;

    @Override public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }

    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String number = value(request, "fnumber");
        String provider = value(request, "fprovider");
        String source = value(request, "fsource");
        String destination = value(request, "fdest");
        String duration = value(request, "fduration");
        try {
            BigDecimal price = new BigDecimal(value(request, "price"));
            if (number.isEmpty() || provider.isEmpty() || source.isEmpty() || destination.isEmpty()
                    || source.equals(destination) || duration.isEmpty() || price.signum() < 0) {
                throw new IllegalArgumentException("Please enter valid flight details and different origin/destination cities.");
            }
            try (Connection connection = DatabaseConfig.connect(db);
                 PreparedStatement statement = connection.prepareStatement(
                         "INSERT INTO flightmaster(flightnumber,provider,source,destination,duration,price) VALUES(?,?,?,?,?,?)")) {
                statement.setString(1, number);
                statement.setString(2, provider);
                statement.setString(3, source);
                statement.setString(4, destination);
                statement.setString(5, duration);
                statement.setBigDecimal(6, price);
                statement.executeUpdate();
            }
            request.getSession().setAttribute("success", "Flight added successfully.");
        } catch (IllegalArgumentException e) {
            request.getSession().setAttribute("error", e.getMessage());
        } catch (Exception e) {
            getServletContext().log("Could not add flight", e);
            request.getSession().setAttribute("error", "Could not save the flight. Check the database and try again.");
        }
        response.sendRedirect("addflights.jsp");
    }

    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("addflights.jsp");
    }

    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
