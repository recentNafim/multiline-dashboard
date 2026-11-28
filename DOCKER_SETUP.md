# MLIL Customer Dashboard — Docker deployment

This project builds **Flutter Web** in a Docker build stage, then serves the compiled site using **Nginx**. No Flutter SDK or Nginx installation is needed on the Linux host; only Docker and the Docker Compose plugin are required. Production content includes the complete `lib/`, `web/pptx_generator.js`, custom browser icons and the existing 3D model viewer integration.

## 1. Start the website

Extract this ZIP and change into the project root (the folder containing `Dockerfile`):

```bash
cd multiline-dashboard-master
docker compose up -d --build
```

Open: `http://SERVER_IP:3701` (or `http://localhost:3701` on the same machine).

If the Linux host firewall blocks 3701, allow TCP port 3701 through the firewall or cloud security group.

## 2. Management

```bash
docker compose ps
docker compose logs -f mlil-customer
docker compose restart
docker compose down
```

To deploy new Flutter source edits:

```bash
docker compose up -d --build
```

## 3. Change host port

Copy `.env.example` to `.env`, then change `WEB_PORT`:

```bash
cp .env.example .env
# edit .env (e.g. WEB_PORT=8080)
docker compose up -d --build
```

Default container port is **80**; `WEB_PORT` is the **host** port.

## 4. Domain and HTTPS

The included Nginx serves HTTP. For public production hosting, place it behind a TLS reverse proxy (Caddy, Traefik, Nginx + Certbot, or an existing ingress). Only expose the HTTP port to the proxy or firewall-protect it. Set a DNS record for your domain.

## 5. Important details

- The app is built for `/` (`--base-href /`) on its own domain or IP/port.
- Project's existing GitHub Pages deployment workflow is unchanged.
- Browser-side Oracle ORDS calls still go to the external API configured in Flutter; make sure the API is reachable over HTTPS and its CORS policy permits your server's origin.
- PowerPoint export loads `pptxgenjs` from a CDN. A client browser must be able to reach that CDN to generate PPTX.
- Export and product images may have CORS constraints depending on the Oracle service.
- Updated favicon can appear stale until old browser/PWA caches are refreshed.
- Do **not** point the Docker container at the GitHub Pages subpath build: Docker builds for `/` separately.

## 6. Health check

```bash
curl -f http://localhost:3701/health
curl -I http://localhost:3701/
```

## 7. Troubleshooting

```bash
docker compose config
docker compose logs --tail=100 mlil-customer
docker compose build --no-cache
docker compose up -d
```

The very first build needs internet access to pull the Flutter builder/Nginx images, download pub packages, and compile the web app. Docker builds are not executed by this file package generator.
