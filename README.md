# Airline Reservation System

This is a Java EE web application (JSP, Servlets, MySQL) based on the original project in this repository.

## Requirements

- Docker Desktop with Docker Compose
- Internet access for the first image build

## Start the application

### Option 1: Direct Local Run (No Docker required)
Java 17 is already configured with an embedded Tomcat 9 and H2 database:

```sh
.\run-local.bat
# or in PowerShell:
.\run-local.ps1
```

Open [http://localhost:8080/](http://localhost:8080/). To promote an account to administrator:
```sh
.\make-admin.ps1 -Email your-email@example.com
```

### Option 2: Docker Compose
From this folder, run:

```sh
docker compose up --build -d
```

Docker builds the WAR, starts Tomcat 9, and creates the MySQL database, tables, and sample flights. Open [http://localhost:8080/](http://localhost:8080/). MySQL is also available at `localhost:3306`; the app uses the development-only `airline_app` / `airline_dev` account.

## Deploy with Vercel

Vercel serves this Java/Tomcat app through an external rewrite; the Java service and MySQL database must be hosted separately. See [VERCEL-DEPLOYMENT.md](VERCEL-DEPLOYMENT.md) for the Render and Vercel setup.

## First account and administrator access

Open the app, register an account, then sign in. New accounts can search flights and place reservations. For application logs, run `docker compose logs -f app`. To enable the admin flight management pages for your own account, run:

```sh
docker compose exec database mysql -uroot -proot airline -e "UPDATE usermaster SET usertype = 1 WHERE email = 'your-email@example.com';"
```

Sign out and sign back in to refresh the role in your session. Do not use the development database credentials outside a local machine.

## Reset sample data

`docker compose down -v` removes the local MySQL volume. The next `docker compose up --build` recreates the schema and sample flights.

## Current scope

The app supports account registration/sign-in, searching sample flights, reservations, and administrator flight maintenance. Reservations are recorded without charging a card; payment processing and confirmation email delivery are not configured.
