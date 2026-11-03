package servlet;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/** Keeps direct JSP and servlet URLs behind the same session/role checks. */
public class AccessControlFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) { }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        if (path.equals("/") || path.equals("/login.jsp") || path.equals("/register.jsp")
                || path.equals("/login") || path.equals("/register") || path.equals("/logout")
                || path.startsWith("/css/") || path.startsWith("/js/")
                || path.startsWith("/images/") || path.startsWith("/fonts/")
                || path.startsWith("/bootstrap-") || path.startsWith("/bootstrap-timepicker/")
                || path.startsWith("/font-awesome/")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("userid") == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
            return;
        }

        boolean adminOnly = path.equals("/addflights") || path.equals("/addflights.jsp")
                || path.equals("/edithandler") || path.equals("/editflight.jsp")
                || path.equals("/deleteflight") || path.equals("/viewbookings.jsp");
        if (adminOnly && !"1".equals(String.valueOf(session.getAttribute("usertype")))) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrator access required.");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() { }
}
