package servlet;

import Objects.getflights;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class search extends HttpServlet {
    private String db;
    @Override public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String provider = value(request, "fprovider");
        String source = value(request, "fsource");
        String destination = value(request, "fdestination");
        List<getflights> flights = new ArrayList<getflights>();
        try (Connection connection = DatabaseConfig.connect(db);
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM flightmaster WHERE provider LIKE ? AND source LIKE ? AND destination LIKE ? ORDER BY price, flightnumber")) {
            statement.setString(1, "%" + provider + "%");
            statement.setString(2, "%" + source + "%");
            statement.setString(3, "%" + destination + "%");
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    getflights flight = new getflights();
                    flight.setflightid(result.getInt("flightid"));
                    flight.setflightnumber(result.getString("flightnumber"));
                    flight.setprovider(result.getString("provider"));
                    flight.setsource(result.getString("source"));
                    flight.setdestination(result.getString("destination"));
                    flight.setduration(result.getString("duration"));
                    flight.setprice(result.getDouble("price"));
                    flights.add(flight);
                }
            }
            request.getSession().setAttribute("flightlist", flights);
            request.getSession().setAttribute("searchMessage", flights.isEmpty() ? "No flights match those filters." : null);
        } catch (Exception e) {
            getServletContext().log("Flight search failed", e);
            request.getSession().setAttribute("error", "Flight search is temporarily unavailable.");
        }
        response.sendRedirect("home.jsp");
    }
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("home.jsp");
    }
    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }
}
