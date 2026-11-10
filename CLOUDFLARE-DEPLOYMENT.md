# Deploying Geet Airlines with Cloudflare

Geet Airlines is a **Java EE (JSP + Servlets + Tomcat + MySQL)** application. Because Cloudflare Pages / Workers is a JavaScript/V8 edge runtime (and does not run JVM or Docker containers directly), there are two standard ways to run it through Cloudflare:

---

## Method 1: Cloudflare Pages Edge Proxy (Recommended for Cloud)

In this setup, your Java backend runs on a container platform (like Render, Railway, or Fly.io) while Cloudflare Pages handles your public domain, SSL, DDoS protection, and edge routing.

### Step 1: Deploy the Java Backend (Render / Docker)
1. Push this repository to GitHub.
2. Go to [Render.com](https://render.com) and create a **Web Service** from this repository (or use the included `render.yaml` Blueprint).
3. Set the environment variables:
   - `AIRLINE_DB_URL`: JDBC URL to your MySQL database (e.g. Aiven, PlanetScale, Railway, or TiDB Cloud).
   - `AIRLINE_DB_USER`: Database username.
   - `AIRLINE_DB_PASSWORD`: Database password.
4. Render builds the Docker image and gives you a URL like: `https://geet-airlines-java.onrender.com`.

### Step 2: Connect to Cloudflare Pages
1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/) and go to **Workers & Pages** > **Create application** > **Pages** > **Connect to Git**.
2. Select your repository.
3. In **Build settings**:
   - Framework preset: **None**
   - Build output directory: `public`
4. In **Environment variables**, optionally add:
   - `BACKEND_ORIGIN`: Your backend URL (e.g., `https://geet-airlines-java.onrender.com`)
5. Click **Save and Deploy**.

Cloudflare Pages uses `functions/[[path]].js` to proxy all traffic, cookies, and forms to your Java backend securely.

---

## Method 2: Cloudflare Tunnel (`cloudflared`) (Zero Cost / Instant)

If you are running the app locally or on any server/VPS, you can expose it securely to the world via Cloudflare Tunnel without port forwarding or public IP.

### Step 1: Install `cloudflared`
Download `cloudflared` for Windows/macOS/Linux:
- Windows (PowerShell):
  ```powershell
  winget install Cloudflare.cloudflared
  ```

### Step 2: Instant Quick Tunnel (No domain needed)
While your local server is running on port 8085:
```powershell
cloudflared tunnel --url http://localhost:8085
```
Cloudflare will generate a public HTTPS URL (e.g. `https://xxxx-xxxx.trycloudflare.com`) that anyone can access from the internet!

### Step 3: Named Tunnel with Custom Domain
If you have a domain on Cloudflare:
```powershell
cloudflared tunnel login
cloudflared tunnel create geet-airlines
cloudflared tunnel route dns geet-airlines airline.yourdomain.com
cloudflared tunnel run --url http://localhost:8085 geet-airlines
```
