<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>Add Flight | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body class="departure-page">
<%
  String userid = (String) session.getAttribute("userid");
  if (userid == null || userid.trim().isEmpty()) { response.sendRedirect("login.jsp"); return; }
  boolean isAdmin = "1".equals(String.valueOf(session.getAttribute("usertype")));
  if (!isAdmin) { response.sendRedirect("home.jsp"); return; }
%>
<sql:setDataSource var="geetDb" driver="${applicationScope.dbDriver}"
                   url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}"
                   password="${applicationScope.dbPassword}" />
<sql:query dataSource="${geetDb}" var="locations">SELECT location FROM locations ORDER BY location</sql:query>
<sql:query dataSource="${geetDb}" var="providers">SELECT provider FROM provider ORDER BY provider</sql:query>
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
      <a class="active" href="addflights.jsp">Add flights</a>
      <a href="viewbookings.jsp">Bookings</a>
      <a class="logout-link" href="logout"><span aria-hidden="true">↗</span> Logout</a>
    </nav>
  </header>
  <main class="inner-main">
    <div class="page-actions">
      <h1 class="page-title" style="margin:0">Add Flight</h1>
      <a class="geet-btn secondary" href="viewflights.jsp" style="width:auto;padding:0 20px">View All Flights</a>
    </div>
    <% String suc = (String) session.getAttribute("success"); String err = (String) session.getAttribute("error");
       if (suc != null && !suc.isEmpty()) { session.removeAttribute("success"); %><p class="page-notice success"><%= suc %></p><% }
       if (err != null && !err.isEmpty()) { session.removeAttribute("error"); %><p class="page-notice error"><%= err %></p><% } %>
    <form class="form-card" id="transferform" method="POST" action="addflights">
      <div class="form-row">
        <div class="form-field">
          <label for="fnumber">Flight number</label>
          <input type="text" id="fnumber" name="fnumber" required placeholder="e.g. AI-202">
        </div>
        <div class="form-field">
          <label for="fprovider">Provider</label>
          <select id="fprovider" name="fprovider">
            <c:forEach var="row" items="${providers.rows}">
              <option value="${row.provider}">${row.provider}</option>
            </c:forEach>
          </select>
        </div>
        <div class="form-field">
          <label for="fsource">Source</label>
          <select id="fsource" name="fsource">
            <c:forEach var="row" items="${locations.rows}">
              <option value="${row.location}">${row.location}</option>
            </c:forEach>
          </select>
        </div>
        <div class="form-field">
          <label for="fdest">Destination</label>
          <select id="fdest" name="fdest">
            <c:forEach var="row" items="${locations.rows}">
              <option value="${row.location}">${row.location}</option>
            </c:forEach>
          </select>
        </div>
        <div class="form-field">
          <label for="fduration">Total flight time</label>
          <input type="text" id="fduration" name="fduration" required placeholder="e.g. 2h 30m">
        </div>
        <div class="form-field">
          <label for="price">Price (₹)</label>
          <input type="number" id="price" name="price" required min="0" step="0.01" placeholder="e.g. 4500">
        </div>
      </div>
      <div class="form-submit-row">
        <button class="geet-btn" type="submit">Save Flight</button>
        <a class="geet-btn secondary" href="viewflights.jsp">Cancel</a>
      </div>
    </form>
  </main>
  <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
</body>
</html>
