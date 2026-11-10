<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>Reservation Summary | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body class="departure-page">
<%
  String ss = (String) session.getAttribute("userid");
  if (ss == null || ss.trim().isEmpty()) { response.sendRedirect("login.jsp"); return; }
  boolean isAdmin = "1".equals(String.valueOf(session.getAttribute("usertype")));
%>
<sql:setDataSource var="geetDb" driver="${applicationScope.dbDriver}"
                   url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}"
                   password="${applicationScope.dbPassword}" />
<sql:query dataSource="${geetDb}" var="result">
  SELECT f.flightnumber, b.flightdate, b.flighttime, f.source, f.destination, f.price, f.provider
  FROM bookingmaster b JOIN flightmaster f ON b.flightid = f.flightid
  WHERE b.id = ${bid}
</sql:query>
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
    <c:forEach var="row" items="${result.rows}">
      <p class="confirmed-badge">✓ Reservation confirmed</p>
      <h1 class="page-title">Booking Summary</h1>
      <div class="detail-card">
        <div class="detail-row"><span class="detail-label">Flight Number</span><span class="detail-value col-mono">${row.flightnumber}</span></div>
        <div class="detail-row"><span class="detail-label">Provider</span><span class="detail-value">${row.provider}</span></div>
        <div class="detail-row"><span class="detail-label">From</span><span class="detail-value">${row.source}</span></div>
        <div class="detail-row"><span class="detail-label">To</span><span class="detail-value">${row.destination}</span></div>
        <div class="detail-row"><span class="detail-label">Flight Date</span><span class="detail-value">${row.flightdate}</span></div>
        <div class="detail-row"><span class="detail-label">Departure Time</span><span class="detail-value">${row.flighttime}</span></div>
        <div class="detail-row"><span class="detail-label">Total Price</span><span class="detail-value price-big">₹ ${row.price}</span></div>
      </div>
      <div style="margin-top:24px;display:flex;gap:12px;flex-wrap:wrap">
        <a class="geet-btn" href="ticket.jsp?bid=${bid}" style="display:inline-flex;width:auto;padding:0 24px">🎟️ View & Download E-Ticket (PDF)</a>
        <a class="geet-btn secondary" href="home.jsp" style="display:inline-flex;width:auto;padding:0 24px">Search More Flights</a>
      </div>
    </c:forEach>
    <c:if test="${result.rowCount == 0}">
      <p class="page-notice error">Could not find reservation details.</p>
      <a class="geet-btn" href="home.jsp" style="display:inline-flex;width:auto;padding:0 28px;margin-top:12px">Go Home</a>
    </c:if>
  </main>
  <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
</body>
</html>
