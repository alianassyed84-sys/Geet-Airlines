<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#0d1618">
  <title>All Flights | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
</head>
<body class="departure-page">
<%
  String userid = (String) session.getAttribute("userid");
  if (userid == null || userid.trim().isEmpty()) { response.sendRedirect("login.jsp"); return; }
  boolean isAdmin = "1".equals(String.valueOf(session.getAttribute("usertype")));
%>
<sql:setDataSource var="geetDb" driver="${applicationScope.dbDriver}"
                   url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}"
                   password="${applicationScope.dbPassword}" />
<sql:query dataSource="${geetDb}" var="result">SELECT * FROM flightmaster ORDER BY flightnumber</sql:query>
<div class="departure-shell">
  <header class="topbar">
    <a class="brand" href="home.jsp" aria-label="Geet Airlines home">
      <svg class="brand-mark" viewBox="0 0 64 48" aria-hidden="true"><path d="M4 31 55 2 35 42 27 29 4 31Z"/><path d="m27 29 14 5 14-32"/></svg>
      <span>GEET AIRLINES</span>
    </a>
    <nav class="main-nav" aria-label="Main navigation">
      <a href="home.jsp">Flights</a>
      <a class="active" href="viewflights.jsp">All flights</a>
      <a href="contact.jsp">Contact</a>
      <% if (isAdmin) { %><a href="addflights.jsp">Add flights</a><a href="viewbookings.jsp">Bookings</a><% } %>
      <a class="logout-link" href="logout"><span aria-hidden="true">↗</span> Logout</a>
    </nav>
  </header>
  <main class="inner-main" style="max-width:100%">
    <div class="results-heading">
      <h1 class="page-title" style="margin:0">All Flights</h1>
      <span class="results-count" style="margin-left:auto">Showing <strong>${result.rowCount}</strong> flights</span>
    </div>
    <% String suc = (String) session.getAttribute("success"); String err = (String) session.getAttribute("error");
       if (suc != null && !suc.isEmpty()) { session.removeAttribute("success"); %><p class="page-notice success"><%= suc %></p><% }
       if (err != null && !err.isEmpty()) { session.removeAttribute("error"); %><p class="page-notice error"><%= err %></p><% } %>
    <div class="data-table-wrap" style="margin-top:16px">
      <table class="data-table">
        <thead>
          <tr>
            <th scope="col">S.No</th>
            <th scope="col">Flight No.</th>
            <th scope="col">Provider</th>
            <th scope="col">Source</th>
            <th scope="col">Destination</th>
            <th scope="col" style="text-align:right">Price</th>
            <% if (isAdmin) { %><th scope="col">Created</th><% } %>
            <th scope="col" style="text-align:center">Duration</th>
            <th scope="col" style="text-align:center"><%= isAdmin ? "Actions" : "Book" %></th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="row" items="${result.rows}" varStatus="status">
            <tr>
              <td class="col-serial"><fmt:formatNumber value="${status.count}" minIntegerDigits="2"/></td>
              <td class="col-mono">${row.flightnumber}</td>
              <td>${row.provider}</td>
              <td>${row.source}</td>
              <td>${row.destination}</td>
              <td class="col-price">₹ <fmt:formatNumber value="${row.price}" type="number" maxFractionDigits="0"/></td>
              <% if (isAdmin) { %><td class="col-mono" style="font-size:12px">${row.createddate}</td><% } %>
              <td class="col-mono" style="text-align:center;font-size:13px">${row.duration}</td>
              <td class="col-actions">
                <% if (isAdmin) { %>
                <a class="tbl-link amber" href="editflight.jsp?id=${row.flightid}">Edit</a>
                <form class="tbl-delete-form" method="post" action="deleteflight" onsubmit="return confirm('Delete this flight?')">
                  <input type="hidden" name="id" value="${row.flightid}">
                  <button class="tbl-link red" type="submit">Delete</button>
                </form>
                <% } else { %>
                <a class="tbl-link amber" href="book.jsp?id=${row.flightid}"><span aria-hidden="true">✈</span> Book</a>
                <% } %>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${result.rowCount == 0}">
            <tr><td class="empty-state" colspan="9">No flights available.</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </main>
  <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
</body>
</html>
