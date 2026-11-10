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
  <title>Passenger Details & Booking | Geet Airlines</title>
  <link rel="stylesheet" href="css/geet.css">
  <style>
    .booking-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; align-items: start; }
    .section-card { border: 1px solid #343b3d; border-radius: 9px; background: #101719; padding: 24px 28px; margin-bottom: 20px; }
    .section-title { font-size: 14px; font-weight: 800; letter-spacing: 0.14em; text-transform: uppercase; color: var(--amber); margin-bottom: 16px; display: flex; align-items: center; gap: 8px; border-bottom: 1px solid #202a2c; padding-bottom: 10px; }
    .form-row-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .form-row-3 { display: grid; grid-template-columns: 1fr 1.5fr 1fr; gap: 14px; }
    .fare-card { border: 1px solid #343b3d; border-radius: 9px; background: #121c1f; padding: 24px; position: sticky; top: 20px; }
    .fare-row { display: flex; justify-content: space-between; padding: 8px 0; font-size: 13px; color: #bbb; border-bottom: 1px solid #1c272a; }
    .fare-total { display: flex; justify-content: space-between; padding: 14px 0 0; font-size: 18px; font-weight: 800; color: var(--amber); }
    .flight-pill { background: #151e20; border-radius: 8px; padding: 16px 20px; display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-left: 4px solid var(--amber); }
    @media(max-width: 900px) { .booking-grid { grid-template-columns: 1fr; } .form-row-2, .form-row-3 { grid-template-columns: 1fr; } }
  </style>
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
  <main class="inner-main" style="max-width:1100px">
    <h1 class="page-title">Passenger Details & Flight Reservation</h1>

    <div class="flight-pill">
      <div>
        <div style="font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:0.1em"><%= provider %> • <%= flightnumber %></div>
        <div style="font-size:20px;font-weight:800;color:#fff;margin-top:4px"><%= source %> ✈ <%= destination %></div>
      </div>
      <div style="text-align:right">
        <div style="font-size:12px;color:var(--muted)">Flight Duration: <strong><%= Duration %></strong></div>
        <div style="font-size:18px;font-weight:800;color:var(--amber)">₹ <%= price %></div>
      </div>
    </div>

    <form id="bookingform" method="POST" action="book">
      <input type="hidden" name="hiddenid" value="<%= id %>">
      <input type="hidden" name="price" value="<%= price %>">

      <div class="booking-grid">
        <div>
          <!-- Section 1: Passenger Information -->
          <div class="section-card">
            <div class="section-title"><span>👤</span> Primary Passenger Information</div>
            <div class="form-row-3" style="margin-bottom:14px">
              <div class="form-field">
                <label for="title">Title</label>
                <select id="title" name="title">
                  <option value="Mr.">Mr.</option>
                  <option value="Ms.">Ms.</option>
                  <option value="Mrs.">Mrs.</option>
                  <option value="Dr.">Dr.</option>
                </select>
              </div>
              <div class="form-field">
                <label for="passenger_name">Full Name (as per Passport/ID)</label>
                <input type="text" id="passenger_name" name="passenger_name" required placeholder="e.g. Aman Sharma">
              </div>
              <div class="form-field">
                <label for="gender">Gender</label>
                <select id="gender" name="gender">
                  <option value="M">Male</option>
                  <option value="F">Female</option>
                  <option value="O">Other</option>
                </select>
              </div>
            </div>

            <div class="form-row-2">
              <div class="form-field">
                <label for="dob">Date of Birth</label>
                <input type="date" id="dob" name="dob" required value="1995-05-15">
              </div>
              <div class="form-field">
                <label for="nationality">Nationality</label>
                <select id="nationality" name="nationality">
                  <option value="Indian">India (Indian)</option>
                  <option value="American">United States (American)</option>
                  <option value="British">United Kingdom (British)</option>
                  <option value="Canadian">Canada (Canadian)</option>
                  <option value="Emirati">United Arab Emirates</option>
                  <option value="Australian">Australia</option>
                  <option value="Singaporean">Singapore</option>
                  <option value="German">Germany</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Section 2: Passport Details -->
          <div class="section-card">
            <div class="section-title"><span>🛂</span> Passport & Travel Document</div>
            <div class="form-row-2">
              <div class="form-field">
                <label for="passport_no">Passport Number</label>
                <input type="text" id="passport_no" name="passport_no" required placeholder="e.g. Z1234567" style="text-transform:uppercase">
              </div>
              <div class="form-field">
                <label for="contact_phone">Contact Phone / WhatsApp</label>
                <input type="text" id="contact_phone" name="contact_phone" required placeholder="+91 98765 43210">
              </div>
            </div>
            <div class="form-field" style="margin-top:14px">
              <label for="contact_email">E-Ticket Delivery Email</label>
              <input type="email" id="contact_email" name="contact_email" required placeholder="traveler@example.com">
            </div>
          </div>

          <!-- Section 3: Seat, Meal & Travel Schedule -->
          <div class="section-card">
            <div class="section-title"><span>✈️</span> Flight Preferences & Baggage</div>
            <div class="form-row-2" style="margin-bottom:14px">
              <div class="form-field">
                <label for="fdate">Flight Date</label>
                <input type="date" id="fdate" name="fdate" required min="<%= java.time.LocalDate.now() %>" value="<%= java.time.LocalDate.now().plusDays(2) %>">
              </div>
              <div class="form-field">
                <label for="ftime">Departure Time</label>
                <select id="ftime" name="ftime">
                  <option value="06:00">06:00 AM (Early Morning)</option>
                  <option value="09:30" selected>09:30 AM (Morning)</option>
                  <option value="14:15">02:15 PM (Afternoon)</option>
                  <option value="18:45">06:45 PM (Evening)</option>
                  <option value="21:30">09:30 PM (Night)</option>
                </select>
              </div>
            </div>

            <div class="form-row-2" style="margin-bottom:14px">
              <div class="form-field">
                <label for="cabin_class">Cabin Class</label>
                <select id="cabin_class" name="cabin_class">
                  <option value="Economy Standard">Economy Standard (Included)</option>
                  <option value="Premium Economy">Premium Economy (+ ₹1,200)</option>
                  <option value="Business Class">Business Class (+ ₹3,500)</option>
                </select>
              </div>
              <div class="form-field">
                <label for="seat">Seat Preference</label>
                <select id="seat" name="seat">
                  <option value="12A">12A (Window)</option>
                  <option value="12B">12B (Middle)</option>
                  <option value="12C">12C (Aisle)</option>
                  <option value="14A">14A (Window - Front)</option>
                  <option value="14C">14C (Aisle - Front)</option>
                  <option value="16F">16F (Window)</option>
                  <option value="21D">21D (Aisle)</option>
                </select>
              </div>
            </div>

            <div class="form-field">
              <label for="meal">Complimentary In-Flight Meal</label>
              <select id="meal" name="meal">
                <option value="Vegetarian Hindu Meal (AVML)">Vegetarian Hindu Meal (AVML)</option>
                <option value="Non-Vegetarian Meal">Non-Vegetarian Meal</option>
                <option value="Jain Vegetarian Meal">Jain Vegetarian Meal</option>
                <option value="Diabetic Meal">Diabetic Meal</option>
                <option value="Fruit Platter">Fruit Platter</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Sidebar: Fare Summary & Baggage -->
        <div>
          <div class="fare-card">
            <h3 style="margin:0 0 16px;font-size:15px;text-transform:uppercase;letter-spacing:0.12em;color:#fff">Fare Breakdown</h3>
            <div class="fare-row"><span>Base Airfare</span><span>₹ <%= price %></span></div>
            <div class="fare-row"><span>Airline Fuel Charge (YQ)</span><span>₹ 450</span></div>
            <div class="fare-row"><span>Airport User Fee (UDF)</span><span>₹ 280</span></div>
            <div class="fare-row"><span>Aviation Security & GST</span><span>₹ 190</span></div>
            <div class="fare-total">
              <span>Total Amount</span>
              <span>₹ <%= price %></span>
            </div>

            <div style="background:#162428;border-radius:6px;padding:12px 14px;margin:20px 0;font-size:12px;color:#cbd5e1">
              <div style="font-weight:700;color:var(--green);margin-bottom:4px">✓ Baggage Allowance Included:</div>
              <div>🎒 Cabin: 1 Piece x 7 kg (Free)</div>
              <div>🧳 Checked: 1 Bag x 15 kg (Free)</div>
            </div>

            <button class="geet-btn" type="submit" style="width:100%">
              <span aria-hidden="true">✈</span> Confirm & Generate Ticket
            </button>
            <div style="text-align:center;margin-top:12px">
              <a href="home.jsp" style="font-size:12px;color:var(--muted)">← Cancel and return</a>
            </div>
          </div>
        </div>
      </div>
    </form>
  </main>
  <footer class="site-footer"><span>Geet Airlines</span><span>Plan well. Fly easy.</span></footer>
</div>
</body>
</html>
