package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class book extends HttpServlet {
    private String db;
    @Override public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }
    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int flightId = Integer.parseInt(request.getParameter("hiddenid"));
            int userId = Integer.parseInt(String.valueOf(request.getSession().getAttribute("userid")));
            LocalDate flightDate = LocalDate.parse(request.getParameter("fdate"));
            if (flightId < 1 || flightDate.isBefore(LocalDate.now())) throw new IllegalArgumentException();
            String timeValue = request.getParameter("ftime");
            if (timeValue == null || !timeValue.matches("\\d{2}:\\d{2}")) throw new IllegalArgumentException();
            try (Connection connection = DatabaseConfig.connect(db);
                 PreparedStatement statement = connection.prepareStatement(
                         "INSERT INTO bookingmaster(flightid,userid,flightdate,flighttime) VALUES(?,?,?,?)",
                         Statement.RETURN_GENERATED_KEYS)) {
                statement.setInt(1, flightId);
                statement.setInt(2, userId);
                statement.setDate(3, Date.valueOf(flightDate));
                statement.setTime(4, Time.valueOf(timeValue + ":00"));
                statement.executeUpdate();
                try (java.sql.ResultSet keys = statement.getGeneratedKeys()) {
                    if (!keys.next()) throw new IllegalStateException("Reservation was not created.");
                    request.getSession().setAttribute("bid", String.valueOf(keys.getInt(1)));
                }
            }
            response.sendRedirect("summary.jsp");
        } catch (IllegalArgumentException | java.time.DateTimeException e) {
            request.getSession().setAttribute("error", "Choose a valid flight date and time (today or later).");
            response.sendRedirect("viewflights.jsp");
        } catch (Exception e) {
            getServletContext().log("Could not create reservation", e);
            request.getSession().setAttribute("error", "Could not create the reservation. Please choose another flight and try again.");
            response.sendRedirect("viewflights.jsp");
        }
    }
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("viewflights.jsp");
    }
}
