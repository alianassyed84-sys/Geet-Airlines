<%@page import="java.sql.ResultSet,java.sql.DriverManager,java.sql.Connection"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>Book Flight | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body class="departure-page">
<%
  String userid = (String) session.getAttribute("userid");
  if (userid == null || userid.trim().isEmpty()) { response.sendRedirect("login.jsp"); return; }
  boolean isAdmin = "1".equals(String.valueOf(session.getAttribute("usertype")));
  String fid = request.getParameter("id");
  if (fid == null) { response.sendRedirect("home.jsp"); return; }
  int id = Integer.parseInt(fid);
  String provider = null, source = null, destination = null, flightnumber = null, price = null, Duration = null;
  try {
    Class.forName((String) application.getAttribute("dbDriver"));
    try (Connection connection = DriverManager.getConnection((String) application.getAttribute("dbUrl"),
         (String) application.getAttribute("dbUser"), (String) application.getAttribute("dbPassword"));
         java.sql.PreparedStatement statement = connection.prepareStatement("SELECT * FROM flightmaster WHERE flightid = ?")) {
      statement.setInt(1, id);
      try (ResultSet rs = statement.executeQuery()) {
        if (rs.next()) {
          provider = rs.getString("provider"); source = rs.getString("source");
          destination = rs.getString("destination"); flightnumber = rs.getString("flightnumber");
          price = rs.getString("price"); Duration = rs.getString("duration");
        } else { response.sendRedirect("home.jsp"); return; }
      }
    }
  } catch (Exception e) { application.log("Could not load flight", e); response.sendRedirect("home.jsp"); return; }
%>
<div class="departure-shell">
  <header class="topbar">
    <a class="brand" href="home.jsp" aria-label="Geet Airlines home">
      <svg class="brand-mark" viewBox="0 0 64 48" aria-hidden="true"><path d="M4 31 55 2 35 42 27 29 4 31Z"/><path d="m27 29 14 5 14-32"/></svg>
      <span>GEET AIRLINES</span>
    </a>
    <nav class="main-nav" aria-label="Main navigation">
      <a href="home.jsp">Flights</a>
      <a href="viewflights.jsp">All flights</a>
      <a href="contact.jsp">Contact</a>
      <% if (isAdmin) { %><a href="addflights.jsp">Add flights</a><a href="viewbookings.jsp">Bookings</a><% } %>
      <a class="logout-link" href="logout"><span aria-hidden="true">↗</span> Logout</a>
    </nav>
  </header>
  <main class="inner-main">
    <h1 class="page-title">Book Flight</h1>
    <%
      String suc = (String) session.getAttribute("success");
      String err = (String) session.getAttribute("error");
      if (suc != null && !suc.isEmpty()) { session.removeAttribute("success"); %>
    <p class="page-notice success"><%= suc %></p>
    <% } if (err != null && !err.isEmpty()) { session.removeAttribute("error"); %>
    <p class="page-notice error"><%= err %></p>
    <% } %>
    <form class="form-card" id="bookingform" method="POST" action="book">
      <input type="hidden" name="flightno" value="<%= id %>">
      <input type="hidden" name="hiddenid" value="<%= id %>">
      <div class="form-row">
        <div class="form-field">
          <label>Flight number</label>
          <input type="text" readonly value="<%= flightnumber %>">
        </div>
        <div class="form-field">
          <label>Provider</label>
          <input type="text" readonly value="<%= provider %>">
        </div>
        <div class="form-field">
          <label>Source</label>
          <input type="text" readonly value="<%= source %>">
        </div>
        <div class="form-field">
          <label>Destination</label>
          <input type="text" readonly value="<%= destination %>">
        </div>
        <div class="form-field">
          <label>Total flight time</label>
          <input type="text" readonly value="<%= Duration %>">
        </div>
        <div class="form-field">
          <label>Price (₹)</label>
          <input type="number" name="price" readonly value="<%= price %>">
        </div>
        <div class="form-field">
          <label for="fdate">Flight date</label>
          <input type="date" id="fdate" name="fdate" required min="<%= java.time.LocalDate.now() %>">
        </div>
        <div class="form-field">
          <label for="ftime">Flight time</label>
          <input type="time" id="ftime" name="ftime" required value="09:00">
        </div>
      </div>
      <p style="font-size:12px;color:var(--muted);margin:0 0 16px;letter-spacing:.03em">This demo records a reservation only. No payment is charged.</p>
      <div class="form-submit-row">
        <button class="geet-btn" type="submit"><span aria-hidden="true">✈</span> Reserve Flight</button>
        <a class="geet-btn secondary" href="home.jsp">← Back</a>
      </div>
    </form>
  </main>
  <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
</body>
</html>
