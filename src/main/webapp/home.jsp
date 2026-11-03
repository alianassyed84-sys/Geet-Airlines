<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#0d1618">
    <title>Flight search | Geet Airlines</title>
    <meta name="description" content="Search flights and reserve your next journey with Geet Airlines.">
    <link rel="stylesheet" href="css/geet.css">
</head>
<body class="departure-page">
<%
    String userId = (String) session.getAttribute("userid");
    if (userId == null || userId.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    boolean isAdmin = "1".equals(String.valueOf(session.getAttribute("usertype")));
%>
<sql:setDataSource var="geetDb" driver="${applicationScope.dbDriver}"
                   url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}"
                   password="${applicationScope.dbPassword}" />
<sql:query dataSource="${geetDb}" var="providers">SELECT provider FROM provider ORDER BY provider</sql:query>
<sql:query dataSource="${geetDb}" var="locations">SELECT location FROM locations ORDER BY location</sql:query>
<sql:query dataSource="${geetDb}" var="allFlights">
    SELECT flightid, flightnumber, provider, source, destination, price, duration
    FROM flightmaster ORDER BY price, flightnumber
</sql:query>
<c:set var="visibleFlights" value="${empty flightlist ? allFlights.rows : flightlist}" />

<div class="departure-shell">
    <header class="topbar">
        <a class="brand" href="home.jsp" aria-label="Geet Airlines home">
            <svg class="brand-mark" viewBox="0 0 64 48" aria-hidden="true"><path d="M4 31 55 2 35 42 27 29 4 31Z"/><path d="m27 29 14 5 14-32"/></svg>
            <span>GEET AIRLINES</span>
        </a>
        <nav class="main-nav" aria-label="Main navigation">
            <a class="active" href="home.jsp">Flights</a>
            <a href="viewflights.jsp">All flights</a>
            <a href="contact.jsp">Contact</a>
            <% if (isAdmin) { %><a href="addflights.jsp">Add flights</a><a href="viewbookings.jsp">Bookings</a><% } %>
            <a class="logout-link" href="logout"><span aria-hidden="true">↗</span> Logout</a>
        </nav>
    </header>

    <main>
        <section class="panorama" aria-label="Geet Airlines photo slideshow">
            <div class="photo-track" id="photoTrack">
                <figure class="photo-panel is-active"><img src="images/home_1.jpg" alt="Air Canada aircraft climbing into a blue sky"><figcaption>Across the skies</figcaption></figure>
                <figure class="photo-panel"><img src="images/home_2.jpg" alt="Passenger aircraft lifting off at sunset"><figcaption>Every journey begins</figcaption></figure>
                <figure class="photo-panel"><img src="images/image-3.jpg" alt="Passenger aircraft cruising above the clouds"><figcaption>Find your horizon</figcaption></figure>
            </div>
            <button class="slide-arrow slide-prev" type="button" aria-label="Highlight previous photo">‹</button>
            <button class="slide-arrow slide-next" type="button" aria-label="Highlight next photo">›</button>
            <div class="slide-dots" role="group" aria-label="Choose highlighted photo">
                <button class="is-active" type="button" aria-label="Highlight photo 1" aria-pressed="true"></button>
                <button type="button" aria-label="Highlight photo 2" aria-pressed="false"></button>
                <button type="button" aria-label="Highlight photo 3" aria-pressed="false"></button>
            </div>
        </section>

        <section class="search-board" aria-label="Search flights">
            <form action="search" method="post" class="search-form">
                <label class="field"><span>Provider</span>
                    <select name="fprovider"><option value="">Any Provider</option>
                        <c:forEach var="row" items="${providers.rows}"><option value="${row.provider}">${row.provider}</option></c:forEach>
                    </select>
                </label>
                <label class="field"><span>Source</span>
                    <select name="fsource"><option value="">Any Source</option>
                        <c:forEach var="row" items="${locations.rows}"><option value="${row.location}">${row.location}</option></c:forEach>
                    </select>
                </label>
                <label class="field"><span>Destination</span>
                    <select name="fdestination"><option value="">Any Destination</option>
                        <c:forEach var="row" items="${locations.rows}"><option value="${row.location}">${row.location}</option></c:forEach>
                    </select>
                </label>
                <button class="search-button" type="submit"><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="10.8" cy="10.8" r="6.8"/><path d="m16 16 5 5"/></svg>Search</button>
            </form>
        </section>

        <section class="results-section" aria-labelledby="resultsHeading">
            <div class="results-heading">
                <h1 id="resultsHeading">Flights Results</h1>
                <span class="sample-label">Sample data</span>
                <span class="results-count">Showing <strong>${fn:length(visibleFlights)}</strong> results</span>
            </div>
            <c:if test="${not empty error}"><p class="notice notice-error"><c:out value="${error}"/></p><% session.removeAttribute("error"); %></c:if>
            <c:if test="${not empty searchMessage}"><p class="notice"><c:out value="${searchMessage}"/></p><% session.removeAttribute("searchMessage"); %></c:if>
            <div class="table-scroll">
                <table class="flight-board">
                    <thead><tr><th scope="col">S.No</th><th scope="col">Flight No.</th><th scope="col">Provider</th><th scope="col">Source</th><th scope="col">Destination</th><th scope="col">Price</th><th scope="col">Duration</th><th scope="col">Book</th></tr></thead>
                    <tbody>
                    <c:forEach var="row" items="${visibleFlights}" varStatus="status">
                        <tr><td class="serial"><fmt:formatNumber value="${status.count}" minIntegerDigits="2"/></td>
                            <td class="flight-number"><c:out value="${row.flightnumber != null ? row.flightnumber : row.getflightnumber()}"/></td>
                            <td class="provider-cell"><c:out value="${row.provider != null ? row.provider : row.getprovider()}"/></td>
                            <td><c:out value="${row.source != null ? row.source : row.getsource()}"/></td>
                            <td><c:out value="${row.destination != null ? row.destination : row.getdestination()}"/></td>
                            <td class="price"><span class="rupee">₹</span> <fmt:formatNumber value="${row.price != null ? row.price : row.getprice()}" type="number" maxFractionDigits="0"/></td>
                            <td class="duration"><c:out value="${row.duration != null ? row.duration : row.getduration()}"/></td>
                            <td><a class="book-button" href="book.jsp?id=${row.flightid != null ? row.flightid : row.getflightid()}"><span aria-hidden="true">✈</span> Book</a></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty visibleFlights}"><tr><td class="empty-state" colspan="8">No flights match your search. Try another route.</td></tr></c:if>
                    </tbody>
                </table>
            </div>
        </section>
    </main>
    <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
<script>
(function () {
    var panels = Array.prototype.slice.call(document.querySelectorAll('.photo-panel'));
    var dots = Array.prototype.slice.call(document.querySelectorAll('.slide-dots button'));
    var active = 0;
    function selectPhoto(index) {
        active = (index + panels.length) % panels.length;
        panels.forEach(function (panel, i) { panel.classList.toggle('is-active', i === active); });
        dots.forEach(function (dot, i) { dot.classList.toggle('is-active', i === active); dot.setAttribute('aria-pressed', i === active ? 'true' : 'false'); });
    }
    document.querySelector('.slide-prev').addEventListener('click', function () { selectPhoto(active - 1); });
    document.querySelector('.slide-next').addEventListener('click', function () { selectPhoto(active + 1); });
    dots.forEach(function (dot, i) { dot.addEventListener('click', function () { selectPhoto(i); }); });
    window.setInterval(function () { selectPhoto(active + 1); }, 6500);
}());
</script>
</body>
</html>
