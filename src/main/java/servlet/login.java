package servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class login extends HttpServlet {
    private String db;

    @Override
    public void init() {
        db = getServletContext().getInitParameter("mysql-db");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        if (email == null || password == null || email.trim().isEmpty()) {
            fail(request, response);
            return;
        }

        try (Connection connection = DatabaseConfig.connect(db);
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT userid, usertype, password FROM usermaster WHERE email = ?")) {
            statement.setString(1, email.trim().toLowerCase());
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next() || !PasswordCodec.matches(password, result.getString("password"))) {
                    fail(request, response);
                    return;
                }
                HttpSession previous = request.getSession(false);
                if (previous != null) previous.invalidate();
                HttpSession session = request.getSession(true);
                session.setAttribute("userid", result.getString("userid"));
                session.setAttribute("usertype", result.getString("usertype"));
                response.sendRedirect("home.jsp");
            }
        } catch (Exception e) {
            getServletContext().log("Sign-in failed", e);
            request.getSession().setAttribute("error", "Sign-in is temporarily unavailable. Check the database and try again.");
            response.sendRedirect("login.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect("login.jsp");
    }

    private void fail(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.getSession().setAttribute("error", "Email or password is incorrect.");
        response.sendRedirect("login.jsp");
    }

}
