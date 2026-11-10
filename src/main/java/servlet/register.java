package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class register extends HttpServlet {
    private String db;

    @Override
    public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String name = value(request, "firstname");
        String email = value(request, "email").toLowerCase();
        String password = request.getParameter("password");
        String gender = value(request, "gender");
        String phone = value(request, "phone");
        String address = value(request, "address");

        if (name.isEmpty() || email.isEmpty() || password == null || password.length() < 8
                || !gender.matches("[MFO]") || phone.isEmpty()) {
            request.getSession().setAttribute("error", "Please complete all required fields. Password must be at least 8 characters.");
            response.sendRedirect("register.jsp");
            return;
        }

        try (Connection connection = DatabaseConfig.connect(db)) {
            try (PreparedStatement lookup = connection.prepareStatement("SELECT 1 FROM usermaster WHERE email = ?")) {
                lookup.setString(1, email);
                try (ResultSet result = lookup.executeQuery()) {
                    if (result.next()) {
                        request.getSession().setAttribute("error", "That email address is already registered.");
                        response.sendRedirect("register.jsp");
                        return;
                    }
                }
            }
            int userId;
            try (PreparedStatement insert = connection.prepareStatement(
                    "INSERT INTO usermaster(firstname,email,password,gender,phone,address) VALUES(?,?,?,?,?,?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                insert.setString(1, name);
                insert.setString(2, email);
                insert.setString(3, PasswordCodec.encode(password));
                insert.setString(4, gender);
                insert.setString(5, phone);
                insert.setString(6, address);
                insert.executeUpdate();
                try (ResultSet keys = insert.getGeneratedKeys()) {
                    if (!keys.next()) throw new ServletException("Account could not be created.");
                    userId = keys.getInt(1);
                }
            }
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) oldSession.invalidate();
            HttpSession session = request.getSession(true);
            session.setAttribute("userid", String.valueOf(userId));
            session.setAttribute("usertype", "0");
            response.sendRedirect("home.jsp");
        } catch (Exception e) {
            getServletContext().log("Registration failed", e);
            request.getSession().setAttribute("error", "Registration could not be completed (" + e.getMessage() + "). Check database settings and try again.");
            response.sendRedirect("register.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("register.jsp");
    }

    private String value(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

}
