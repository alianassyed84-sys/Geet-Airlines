<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>Contact Us | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body class="departure-page">
<%
  String userId = (String) session.getAttribute("userid");
  if (userId == null || userId.trim().isEmpty()) {
    response.sendRedirect("login.jsp"); return;
  }
  boolean isAdmin = "1".equals(String.valueOf(session.getAttribute("usertype")));
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
      <a class="active" href="contact.jsp">Contact</a>
      <% if (isAdmin) { %><a href="addflights.jsp">Add flights</a><a href="viewbookings.jsp">Bookings</a><% } %>
      <a class="logout-link" href="logout"><span aria-hidden="true">↗</span> Logout</a>
    </nav>
  </header>
  <main class="inner-main">
    <h1 class="page-title">Contact Us</h1>
    <%
      String suc = (String) session.getAttribute("success");
      String err = (String) session.getAttribute("error");
      if (suc != null && !suc.isEmpty()) { session.removeAttribute("success"); %>
    <p class="page-notice success"><%= suc %></p>
    <% } if (err != null && !err.isEmpty()) { session.removeAttribute("error"); %>
    <p class="page-notice error"><%= err %></p>
    <% } %>
    <div class="contact-wrap">
      <p style="color:var(--muted);margin:0 0 20px;font-size:13px;letter-spacing:.04em">Leave a message — we will be happy to help you.</p>
      <form class="form-card" method="post" action="contactus">
        <div class="form-row">
          <div class="form-field">
            <label for="cname">Name</label>
            <input type="text" id="cname" name="name" required placeholder="Your name">
          </div>
          <div class="form-field">
            <label for="cemail">Email address</label>
            <input type="email" id="cemail" name="email" required placeholder="you@example.com">
          </div>
          <div class="form-field">
            <label for="cmsg">Message</label>
            <textarea id="cmsg" name="message" rows="5" placeholder="How can we help?"></textarea>
          </div>
        </div>
        <div class="form-submit-row">
          <button class="geet-btn" type="submit">Send Message</button>
        </div>
      </form>
    </div>
  </main>
  <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
</body>
</html>
