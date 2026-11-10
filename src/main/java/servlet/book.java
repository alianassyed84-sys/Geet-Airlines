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
            if (timeValue == null || !timeValue.matches("\\d{2}:\\d{2}")) timeValue = "09:00";

            String title = request.getParameter("title");
            if (title == null) title = "Mr.";
            String rawPassengerName = request.getParameter("passenger_name");
            if (rawPassengerName == null || rawPassengerName.trim().isEmpty()) {
                rawPassengerName = "Traveler";
            }
            String passengerName = title + " " + rawPassengerName.trim();
            String passportNo = request.getParameter("passport_no");
            if (passportNo == null || passportNo.trim().isEmpty()) passportNo = "Z" + (1000000 + (int)(Math.random() * 9000000));
            String nationality = request.getParameter("nationality");
            if (nationality == null || nationality.trim().isEmpty()) nationality = "Indian";
            String dob = request.getParameter("dob");
            if (dob == null) dob = "1995-01-01";
            String gender = request.getParameter("gender");
            if (gender == null) gender = "M";
            String seat = request.getParameter("seat");
            if (seat == null || seat.trim().isEmpty()) seat = "14A";
            String cabinClass = request.getParameter("cabin_class");
            if (cabinClass == null || cabinClass.trim().isEmpty()) cabinClass = "Economy Standard";
            String meal = request.getParameter("meal");
            if (meal == null || meal.trim().isEmpty()) meal = "Vegetarian Hindu Meal (AVML)";
            String contactPhone = request.getParameter("contact_phone");
            String contactEmail = request.getParameter("contact_email");

            try (Connection connection = DatabaseConfig.connect(db);
                 PreparedStatement statement = connection.prepareStatement(
                         "INSERT INTO bookingmaster(flightid,userid,flightdate,flighttime,passenger_name,passport_no,nationality,dob,gender,seat,cabin_class,meal,contact_phone,contact_email) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                         Statement.RETURN_GENERATED_KEYS)) {
                statement.setInt(1, flightId);
                statement.setInt(2, userId);
                statement.setDate(3, Date.valueOf(flightDate));
                statement.setTime(4, Time.valueOf(timeValue + ":00"));
                statement.setString(5, passengerName);
                statement.setString(6, passportNo.toUpperCase());
                statement.setString(7, nationality);
                statement.setString(8, dob);
                statement.setString(9, gender);
                statement.setString(10, seat);
                statement.setString(11, cabinClass);
                statement.setString(12, meal);
                statement.setString(13, contactPhone);
                statement.setString(14, contactEmail);
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
            request.getSession().setAttribute("error", "Could not create the reservation: " + e.getMessage());
            response.sendRedirect("viewflights.jsp");
        }
    }
    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("viewflights.jsp");
    }
}
