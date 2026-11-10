<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Official E-Ticket & Boarding Pass | Geet Airlines</title>
    <link rel="stylesheet" href="css/geet.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        body { background: #080d0f; color: #222; font-family: 'Manrope', Arial, sans-serif; margin: 0; padding: 20px; }
        .ticket-wrapper { max-width: 920px; margin: 0 auto; }
        .action-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; flex-wrap: wrap; gap: 12px; }
        .action-btn { background: #f7b342; color: #111; font-weight: 800; font-size: 13px; text-transform: uppercase; letter-spacing: 0.1em; border: none; padding: 12px 24px; border-radius: 6px; cursor: pointer; display: inline-flex; align-items: center; gap: 8px; text-decoration: none; transition: filter 0.2s; }
        .action-btn:hover { filter: brightness(1.1); }
        .action-btn.secondary { background: #1a2528; color: #eee; border: 1px solid #343b3d; }
        .action-btn.secondary:hover { border-color: #f7b342; color: #f7b342; }

        /* Boarding Pass Sheet */
        .boarding-pass-sheet { background: #fff; border-radius: 12px; box-shadow: 0 10px 40px rgba(0,0,0,0.6); overflow: hidden; position: relative; color: #1a1a1a; margin-bottom: 30px; }
        .sheet-header { background: #0c1315; color: #fff; padding: 24px 32px; display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #f7b342; }
        .sheet-brand { display: flex; align-items: center; gap: 12px; }
        .sheet-brand svg { width: 44px; height: 34px; fill: #f7b342; stroke: #f7b342; }
        .sheet-brand-text { font-size: 20px; font-weight: 800; letter-spacing: 0.3em; color: #fff; }
        .sheet-title-badge { text-align: right; }
        .sheet-title-badge h2 { margin: 0; font-size: 15px; font-weight: 800; letter-spacing: 0.15em; color: #f7b342; text-transform: uppercase; }
        .sheet-title-badge p { margin: 4px 0 0; font-size: 11px; color: #9da5a2; font-family: 'DM Mono', monospace; }

        /* Ticket Body Grid */
        .ticket-body { display: grid; grid-template-columns: 2.2fr 1fr; border-bottom: 2px dashed #ccc; }
        .ticket-main { padding: 26px 32px; border-right: 2px dashed #ccc; position: relative; }
        .ticket-stub { padding: 26px 22px; background: #fbfbf9; display: flex; flex-direction: column; justify-content: space-between; }

        /* Passenger & Travel Document Grid */
        .passenger-bar { display: grid; grid-template-columns: 1.8fr 1fr 1fr 1fr; gap: 14px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #eee; }
        .info-cell label { display: block; font-size: 10px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.12em; color: #777; margin-bottom: 4px; }
        .info-cell .val { font-size: 14px; font-weight: 800; color: #111; }
        .info-cell .val.mono { font-family: 'DM Mono', monospace; }

        /* Flight Route Hero */
        .route-hero { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; background: #f5f6f4; border-radius: 8px; padding: 16px 22px; }
        .city-block { text-align: left; }
        .city-block.right { text-align: right; }
        .city-code { font-size: 32px; font-weight: 900; letter-spacing: 0.05em; color: #0c1315; font-family: 'DM Mono', monospace; line-height: 1; }
        .city-name { font-size: 12px; font-weight: 600; color: #555; margin-top: 4px; }
        .route-plane-divider { display: flex; flex-direction: column; align-items: center; flex: 1; padding: 0 16px; }
        .plane-path { width: 100%; height: 2px; background: #d0d4d2; position: relative; margin: 8px 0; }
        .plane-path::after { content: '✈'; position: absolute; top: -10px; left: 50%; transform: translateX(-50%); color: #f7b342; font-size: 16px; }
        .flight-time-badge { font-size: 11px; font-weight: 700; color: #666; font-family: 'DM Mono', monospace; }

        /* Flight Specific Details Grid */
        .flight-specs { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px; margin-bottom: 20px; background: #fff; }
        .spec-box { border-left: 3px solid #0c1315; padding-left: 8px; }
        .spec-box.highlight { border-color: #f7b342; }
        .spec-box label { font-size: 9px; font-weight: 700; color: #888; text-transform: uppercase; letter-spacing: 0.1em; display: block; }
        .spec-box .val { font-size: 15px; font-weight: 800; color: #111; font-family: 'DM Mono', monospace; margin-top: 2px; }

        /* Extra Details: Meal & Class */
        .amenities-bar { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 20px; background: #fafaf8; border: 1px solid #ebebeb; border-radius: 6px; padding: 10px 14px; font-size: 12px; }
        .amenities-bar div strong { color: #111; }

        /* Baggage Allowance Box */
        .baggage-section { background: #f8faf9; border: 1px solid #e1e7e4; border-radius: 8px; padding: 14px 18px; margin-bottom: 16px; }
        .baggage-title { font-size: 11px; font-weight: 800; text-transform: uppercase; letter-spacing: 0.14em; color: #2d553e; margin-bottom: 8px; display: flex; align-items: center; gap: 6px; }
        .baggage-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .bag-item { display: flex; align-items: center; gap: 10px; font-size: 12px; font-weight: 600; color: #333; }
        .bag-icon { font-size: 20px; }
        .bag-desc strong { color: #000; font-size: 13px; }
        .bag-desc p { margin: 2px 0 0; font-size: 11px; color: #666; }

        /* Stub Section (Right side) */
        .stub-header { text-align: center; border-bottom: 1px solid #ddd; padding-bottom: 12px; margin-bottom: 12px; }
        .stub-header h3 { margin: 0; font-size: 13px; font-weight: 800; letter-spacing: 0.12em; color: #333; text-transform: uppercase; }
        .stub-header p { margin: 3px 0 0; font-size: 10px; color: #777; font-family: 'DM Mono', monospace; }
        .stub-qr { display: flex; justify-content: center; margin: 12px 0; }
        .stub-qr img { width: 128px; height: 128px; border-radius: 6px; border: 1px solid #eee; padding: 4px; background: #fff; }
        .stub-data { font-size: 11px; line-height: 1.5; }
        .stub-data-row { display: flex; justify-content: space-between; padding: 3px 0; border-bottom: 1px dotted #ddd; }
        .stub-data-row span:first-child { color: #777; font-weight: 600; }
        .stub-data-row span:last-child { color: #111; font-weight: 800; }

        /* Barcode banner */
        .barcode-strip { height: 26px; background: repeating-linear-gradient(90deg, #111 0px, #111 2px, transparent 2px, transparent 4px, #111 4px, #111 7px, transparent 7px, transparent 9px, #111 9px, #111 11px); margin-top: 14px; opacity: 0.85; }

        /* Ticket Footer */
        .ticket-footer { background: #fafaf8; padding: 14px 32px; display: flex; justify-content: space-between; align-items: center; font-size: 11px; color: #666; border-top: 1px solid #eee; flex-wrap: wrap; gap: 10px; }
        .footer-note { max-width: 600px; line-height: 1.4; }
        .pnr-stamp { font-family: 'DM Mono', monospace; font-size: 14px; font-weight: 800; color: #0c1315; padding: 6px 14px; background: #f7b34233; border: 1px solid #f7b342; border-radius: 4px; }

        @media print {
            body { background: #fff; padding: 0; }
            .action-bar, .site-footer { display: none !important; }
            .ticket-wrapper { max-width: 100%; margin: 0; }
            .boarding-pass-sheet { box-shadow: none; border: 1px solid #aaa; margin: 0; page-break-inside: avoid; }
        }
        @media (max-width: 768px) {
            .ticket-body { grid-template-columns: 1fr; }
            .ticket-main { border-right: none; border-bottom: 2px dashed #ccc; }
            .passenger-bar { grid-template-columns: 1fr 1fr; }
            .route-hero { flex-direction: column; text-align: center; gap: 12px; }
            .city-block.right { text-align: center; }
            .flight-specs { grid-template-columns: 1fr 1fr; }
        }
    </style>
</head>
<body>
<%
    String userId = (String) session.getAttribute("userid");
    if (userId == null || userId.trim().isEmpty()) {
        response.sendRedirect("login.jsp");
        return;
    }
    String bookingIdParam = request.getParameter("bid");
    if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
        bookingIdParam = String.valueOf(session.getAttribute("bid"));
    }
    if (bookingIdParam == null || "null".equals(bookingIdParam)) {
        response.sendRedirect("viewflights.jsp");
        return;
    }
    int targetBid = Integer.parseInt(bookingIdParam);
    request.setAttribute("queryBid", targetBid);
%>

<sql:setDataSource var="geetDb" driver="${applicationScope.dbDriver}"
                   url="${applicationScope.dbUrl}" user="${applicationScope.dbUser}"
                   password="${applicationScope.dbPassword}" />
<sql:query dataSource="${geetDb}" var="res">
    SELECT b.id, f.flightnumber, f.provider, f.source, f.destination, f.price, f.duration,
           b.flightdate, b.flighttime, b.passenger_name, b.passport_no, b.nationality,
           b.seat, b.cabin_class, b.meal, b.contact_phone, b.contact_email,
           u.firstname, u.email, u.phone
    FROM bookingmaster b
    JOIN flightmaster f ON b.flightid = f.flightid
    JOIN usermaster u ON b.userid = u.userid
    WHERE b.id = ?
    <sql:param value="${queryBid}"/>
</sql:query>

<c:choose>
<c:when test="${res.rowCount > 0}">
<c:set var="bk" value="${res.rows[0]}"/>

<!-- Fallbacks for fields if not provided -->
<c:set var="pnr" value="GA-${bk.id + 1048}K"/>
<c:set var="paxName" value="${not empty bk.passenger_name ? bk.passenger_name : bk.firstname}"/>
<c:set var="passport" value="${not empty bk.passport_no ? bk.passport_no : 'Z'.concat(String.valueOf(bk.id * 18491 % 9000000 + 1000000))}"/>
<c:set var="nation" value="${not empty bk.nationality ? bk.nationality : 'Indian'}"/>
<c:set var="seatNum" value="${not empty bk.seat ? bk.seat : '14A'}"/>
<c:set var="cabin" value="${not empty bk.cabin_class ? bk.cabin_class : 'Economy Standard'}"/>
<c:set var="mealChoice" value="${not empty bk.meal ? bk.meal : 'Vegetarian Hindu Meal (AVML)'}"/>
<c:set var="gateNum" value="G${(bk.id % 12) + 2}"/>
<c:set var="ticketNo" value="098-2026${bk.id * 8371}"/>

<div class="ticket-wrapper">
    <div class="action-bar">
        <a class="action-btn secondary" href="home.jsp">← Home</a>
        <div style="display:flex;gap:10px">
            <button class="action-btn secondary" onclick="window.print()">🖨️ Print Ticket</button>
            <button class="action-btn" id="downloadPdfBtn">📄 Download PDF</button>
        </div>
    </div>

    <div class="boarding-pass-sheet" id="boardingPassSheet">
        <!-- Sheet Header -->
        <div class="sheet-header">
            <div class="sheet-brand">
                <svg viewBox="0 0 64 48" aria-hidden="true"><path d="M4 31 55 2 35 42 27 29 4 31Z"/><path d="m27 29 14 5 14-32"/></svg>
                <span class="sheet-brand-text">GEET AIRLINES</span>
            </div>
            <div class="sheet-title-badge">
                <h2>Boarding Pass & E-Ticket</h2>
                <p>ELECTRONIC TICKET RECEIPT • IATA CONFIRMED</p>
            </div>
        </div>

        <!-- Ticket Body -->
        <div class="ticket-body">
            <!-- Left Main Ticket -->
            <div class="ticket-main">
                <div class="passenger-bar">
                    <div class="info-cell">
                        <label>Passenger Name</label>
                        <div class="val" style="text-transform:uppercase">${paxName}</div>
                    </div>
                    <div class="info-cell">
                        <label>Passport Number</label>
                        <div class="val mono" style="color:#0284c7">${passport}</div>
                    </div>
                    <div class="info-cell">
                        <label>Nationality</label>
                        <div class="val">${nation}</div>
                    </div>
                    <div class="info-cell">
                        <label>Booking Ref (PNR)</label>
                        <div class="val mono" style="color:#d97706">${pnr}</div>
                    </div>
                </div>

                <!-- Route -->
                <div class="route-hero">
                    <div class="city-block">
                        <div class="city-code">${bk.source.substring(0,3).toUpperCase()}</div>
                        <div class="city-name">${bk.source} (Terminal 3)</div>
                    </div>
                    <div class="route-plane-divider">
                        <div class="flight-time-badge">${bk.duration} Non-stop</div>
                        <div class="plane-path"></div>
                        <div class="flight-time-badge">${bk.provider} ${bk.flightnumber}</div>
                    </div>
                    <div class="city-block right">
                        <div class="city-code">${bk.destination.substring(0,3).toUpperCase()}</div>
                        <div class="city-name">${bk.destination} (Terminal 2)</div>
                    </div>
                </div>

                <!-- Flight Specs -->
                <div class="flight-specs">
                    <div class="spec-box highlight">
                        <label>Flight Date</label>
                        <div class="val">${bk.flightdate}</div>
                    </div>
                    <div class="spec-box highlight">
                        <label>Boarding Time</label>
                        <div class="val">${bk.flighttime}</div>
                    </div>
                    <div class="spec-box highlight">
                        <label>Gate</label>
                        <div class="val">${gateNum}</div>
                    </div>
                    <div class="spec-box highlight">
                        <label>Seat</label>
                        <div class="val" style="color:#b45309">${seatNum}</div>
                    </div>
                    <div class="spec-box highlight">
                        <label>Cabin Class</label>
                        <div class="val" style="font-size:12px">${cabin}</div>
                    </div>
                </div>

                <!-- Preferences Bar -->
                <div class="amenities-bar">
                    <div>🍽️ Meal Selected: <strong>${mealChoice}</strong></div>
                    <div>🎫 Ticket Number: <strong>${ticketNo}</strong></div>
                </div>

                <!-- Baggage Allowance -->
                <div class="baggage-section">
                    <div class="baggage-title">
                        <span>🧳</span> Official Baggage Allowance Included
                    </div>
                    <div class="baggage-grid">
                        <div class="bag-item">
                            <span class="bag-icon">🎒</span>
                            <div class="bag-desc">
                                <strong>Cabin Baggage: 1 Piece (7 kg)</strong>
                                <p>Max dimension 55 x 35 x 25 cm (Carry-on / Laptop bag)</p>
                            </div>
                        </div>
                        <div class="bag-item">
                            <span class="bag-icon">🧳</span>
                            <div class="bag-desc">
                                <strong>Check-in Baggage: 1 Bag (15 kg)</strong>
                                <p>Complimentary checked baggage allowance</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Boarding Stub -->
            <div class="ticket-stub">
                <div>
                    <div class="stub-header">
                        <h3>Boarding Stub</h3>
                        <p>${bk.provider} • ${bk.flightnumber}</p>
                    </div>

                    <div class="stub-qr">
                        <img src="https://api.qrserver.com/v1/create-qr-code/?size=140x140&margin=4&data=IATA:BCBP%7CPNR:${pnr}%7CPAX:${paxName}%7CPASS:${passport}%7CFLIGHT:${bk.flightnumber}%7C${bk.source}-${bk.destination}%7CSEAT:${seatNum}%7CSTATUS:OK"
                             alt="Scan QR for Boarding Verification">
                    </div>

                    <div class="stub-data">
                        <div class="stub-data-row"><span>Passenger:</span><span>${paxName.split(" ")[0]}</span></div>
                        <div class="stub-data-row"><span>Passport:</span><span class="mono">${passport}</span></div>
                        <div class="stub-data-row"><span>Route:</span><span>${bk.source.substring(0,3).toUpperCase()} → ${bk.destination.substring(0,3).toUpperCase()}</span></div>
                        <div class="stub-data-row"><span>Date:</span><span>${bk.flightdate}</span></div>
                        <div class="stub-data-row"><span>Seat:</span><span style="color:#b45309">${seatNum}</span></div>
                        <div class="stub-data-row"><span>Gate:</span><span>${gateNum}</span></div>
                        <div class="stub-data-row"><span>Fare Paid:</span><span>₹ <fmt:formatNumber value="${bk.price}" type="number" maxFractionDigits="0"/></span></div>
                    </div>

                    <div class="barcode-strip"></div>
                </div>

                <div style="text-align:center;margin-top:10px;font-family:'DM Mono',monospace;font-size:9px;color:#888;letter-spacing:0.1em">
                    KEEP STUB FOR SECURITY
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="ticket-footer">
            <div class="footer-note">
                <strong>Important Notice:</strong> Gate closes 25 minutes prior to departure. Please present this e-ticket along with your original passport (<strong>${passport}</strong>) at check-in counters and security gates.
            </div>
            <div class="pnr-stamp">PNR: ${pnr}</div>
        </div>
    </div>
</div>

<script>
document.getElementById('downloadPdfBtn').addEventListener('click', function () {
    var element = document.getElementById('boardingPassSheet');
    var opt = {
        margin:       [8, 8, 8, 8],
        filename:     'GeetAirlines_ETicket_${pnr}.pdf',
        image:        { type: 'jpeg', quality: 0.98 },
        html2canvas:  { scale: 2, useCORS: true },
        jsPDF:        { unit: 'mm', format: 'a4', orientation: 'portrait' }
    };
    html2pdf().set(opt).from(element).save();
});
</script>
</c:when>
<c:otherwise>
<div class="ticket-wrapper" style="text-align:center;padding:60px 20px;color:#fff">
    <h2>Reservation Not Found</h2>
    <p>Could not locate the requested reservation.</p>
    <a class="action-btn" href="home.jsp">Return to Flights</a>
</div>
</c:otherwise>
</c:choose>
</body>
</html>
