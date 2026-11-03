# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

- Inferred from the existing application: travelers who want to find a domestic flight, reserve a seat, and review their booking.
- Inferred from the existing application: administrators who manage flights and review reservations.

## Product Purpose

- The user intends to develop the system into a real customer booking pilot.
- Current functionality supports account registration, flight search, reservation recording, and flight and booking administration.
- The current application records reservations and does not charge a payment card. Pilot readiness, live inventory, airline integrations, and payment behavior have not been confirmed.

## Positioning

No distinct commercial differentiator has been confirmed. The user wants the product to feel like a modern premium Indian airline.

## Operating Context

- Travelers use the web app to register or sign in, search domestic routes, reserve a flight, and review bookings.
- Administrators use the web app to add or edit flights and view reservations.
- The existing implementation is a Java 8-compatible JSP/Servlet application packaged as a WAR, with MySQL support and an H2 local demo database.

## Capabilities and Constraints

- Existing routes include flight search, reservation, contact, flight administration, and booking administration.
- The redesign must preserve the current Java/JSP forms, servlet routes, session-based access, and database-backed content.
- The user describes the intended destination as a real customer booking pilot; the current code and sample data do not establish readiness for live use.
- The application records reservations only; it must not imply that payment is taken or that reservations are issued by a real airline.

## Brand Commitments

- Name: Geet Airlines, retained from the existing application and affirmed by the user.
- User-selected direction: modern premium Indian airline.

## Evidence on Hand

- Flight providers, routes, and sample flights are seeded in `database/init.sql` and `src/main/resources/h2-init.sql`.
- The user asked to retain the existing homepage slideshow photos in `src/main/webapp/images/home_1.jpg`, `home_2.jpg`, and `image-3.jpg`. The first visibly shows Air Canada markings and the third shows a stock watermark; do not present these photos as Geet Airlines aircraft or as photos tied to specific flight listings.
- No confirmed operating airline, live inventory, payment integration, customer testimonials, or travel guarantees are present. Do not invent them.

## Product Principles

- Make flight search and reservation clear and direct.
- Show route, schedule, fare, and reservation information accurately from the database.
- Make traveler and administrator tasks easy to distinguish.
- Be clear that demo reservations do not charge payment or represent a live airline ticket.

## Accessibility & Inclusion

No product-specific accessibility standard has been confirmed. Preserve semantic forms, labels, keyboard access, and readable contrast.
