# Deploy Geet Airlines with Vercel

The app is a Java EE application built from JSP and Servlets and runs on Tomcat. Vercel does not provide an official Java/Tomcat runtime, so this setup keeps the Java application on Render and uses Vercel's external rewrite as the public URL and reverse proxy.

## 1. Deploy the Java app

Create a Render Blueprint from this project using `render.yaml`. The Blueprint creates the Docker web service `geet-airlines-java` and prompts for these secrets:

- `AIRLINE_DB_URL`: JDBC URL for a reachable MySQL 8 database, for example `jdbc:mysql://HOST:3306/airline?useSSL=true&serverTimezone=UTC`
- `AIRLINE_DB_USER`: database username
- `AIRLINE_DB_PASSWORD`: database password

Render does not provide a managed MySQL service in this Blueprint. Provision MySQL with a MySQL hosting provider, then import `database/init.sql` before the first app request. Never put production credentials in `render.yaml` or source control.

Wait until the Render service is healthy at `https://geet-airlines-java.onrender.com`. If you use a different Render service name, update the destination host in `vercel.json` to match.

## 2. Deploy through Vercel

Import the repository into Vercel. For the GitHub monorepo, set **Root Directory** to `Projects/Airline-Reservation-System`. Keep the Vercel project framework preset as **Other**, leave the build command empty, and use the `public` output directory set in `vercel.json`. Vercel forwards requests to the Java service through the external rewrite.

After deployment, the Vercel domain serves the full Tomcat application, including JSP pages, static assets, servlet routes, and session cookies, while the browser remains on the Vercel domain.

## Local development

Continue to use Docker Compose for local development:

```sh
docker compose up --build
```

Vercel itself does not run the Java application locally; the local app remains at `http://localhost:8080/`.
