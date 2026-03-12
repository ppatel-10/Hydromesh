# Hydromesh: Project Handover & State Document

This document provides a comprehensive overview of the Hydromesh project, what has been implemented so far, the current architecture, deployment status, and next steps. It is designed to get any new LLM (like Claude Sonnet or Codex) instantly up to speed.

## 1. Project Overview
**Hydromesh** is a community-driven flood prediction and emergency response platform. It consists of a mobile app (Flutter) and a backend API (Node.js/Express) connected to a PostgreSQL database (Supabase) with PostGIS extensions for spatial queries.

### Core Features (Milestone 4 Rubric)
- **F-07:** Real-Time Flood Map (PostGIS spatial queries + flutter_map)
- **F-11:** Predictive Safe Routes (Simulated polylines routing out of hazard zones)
- **F-15:** Emergency/Help Requests (SOS broadcasting to nearby responders)
- **F-17:** Submit Flood Reports (Custom UI with water-level selection)
- **F-25:** Weather API Integration (Open-Meteo fetching based on GPS)
- **Global Simulation (God Mode):** A hidden dashboard to trigger massive, real-time simulated events (Flash Floods, Mass Evacuations) across 10 global cities using WebSockets (Socket.io).

---

## 2. Tech Stack & Design Language
- **Frontend:** Flutter (Dart) using a highly stylized, Rive-inspired "Glassmorphism" UI.
  - Deep dark theme (`#0A0A0A` background) with Neon accents (Electric Blue, Violet, Danger Red).
  - Extensive use of `flutter_animate` for micro-interactions (staggered fades, pulsing buttons, shimmers).
  - WebSockets (`socket_io_client`) for real-time map marker updates without refreshing.
- **Backend:** Node.js + Express.js.
  - RESTful architecture with JWT Authentication.
  - Socket.io server for real-time event broadcasting (`new_report`, `new_emergency`).
- **Database:** Supabase (PostgreSQL 16).
  - Uses PostGIS (`ST_MakePoint`, `ST_DWithin`) to calculate radiuses and find nearby reports/responders.

---

## 3. What Has Been Completed
1. **Database Schema:** Defined `users`, `flood_reports`, `emergency_requests`, and `user_locations` with geospatial indexing.
2. **Backend API:** All endpoints built (`/api/auth`, `/api/reports`, `/api/emergency`, `/api/weather`, `/api/simulation`).
3. **Frontend UI Rebuild:** Converted the entire mobile app to the Rive-inspired glassmorphism theme.
4. **GPS Integration:** Real GPS in ReportScreen, EmergencyScreen, RouteScreen, WeatherCard.
5. **Dynamic Risk Zones (F-07):** Clustering algorithm on map groups reports into coloured danger polygons.
6. **Emergency SOS Markers (F-15):** Pulsing red markers on map for pending emergencies; tap → bottom sheet.
7. **Socket.io Status Badge:** Live connection indicator on MapScreen title bar.
8. **JWT Persistence:** Token saved to SharedPreferences; survives app restart; restored to API client.
9. **Smart Splash Routing:** Splash goes to `/home` if session restored, `/login` otherwise.
10. **CI/CD:** GitHub Actions builds release APK on every push to main (Flutter 3.41.4).

---

## 4. Current Deployment State

### Backend — MIGRATING TO AZURE 🔄
- **Previous host:** Render (`https://hydromesh-api.onrender.com`) — still live as fallback
- **Target host:** Azure App Service (`https://hydromesh-api.azurewebsites.net`)
- **GitHub Actions workflow:** `.github/workflows/azure-deploy.yml` — triggers on push to `main` (backend/*) once secrets are configured
- **DB connection:** Retries with exponential backoff; server stays alive even if DB is down.
- **Key fix applied:** `database.js` uses a custom URL parser (splits on LAST `@`) so passwords containing `@` work whether encoded or raw.

### Azure Setup Checklist (manual steps required)
- [ ] Create Azure App Service: portal.azure.com → Web App, name `hydromesh-api`, Node 18 LTS, Linux, Free F1, region Central India
- [ ] Configure Application Settings in Azure: `DATABASE_URL`, `JWT_SECRET`, `SUPABASE_URL`, `SUPABASE_SERVICE_KEY`, `PORT=8080`, `NODE_ENV=production`, `CORS_ORIGIN=*`
- [ ] Add GitHub Secret `AZURE_WEBAPP_PUBLISH_PROFILE` (from Azure portal → App Service → Get Publish Profile)
- [ ] Add GitHub Variable `AZURE_WEBAPP_NAME=hydromesh-api`
- [ ] Push to `main` — GitHub Actions auto-deploys
- [ ] Verify: `curl https://hydromesh-api.azurewebsites.net/api/health`

See full guide: `docs/AZURE_DEPLOY.md`

### Database — ⚠️ ACTION REQUIRED
- **Supabase project is PAUSED** (free tier auto-pauses after 7 days inactivity).
- Go to [supabase.com/dashboard](https://supabase.com/dashboard) → click "Restore project".
- Once unpaused, the backend auto-reconnects within 60 seconds.
- Direct connection URL (with encoded password): `postgresql://postgres:Hydromesh%402025@db.zllbvvgufhhhktaxlpqp.supabase.co:5432/postgres`

### Mobile App — APK AVAILABLE ✅
- Download from: GitHub → Actions → "Build Android APK" → latest run → `hydromesh-release-apk` artifact
- `applicationId`: `com.hydromesh.app`
- **API calls now point to:** `https://hydromesh-api.azurewebsites.net` (switched from Render)
- Render fallback URLs also corrected to `https://hydromesh-api.onrender.com`

---

## 5. Next Steps for the AI Assistant
1. **Complete Azure provisioning** — Follow the checklist in Section 4 above. Once `AZURE_WEBAPP_PUBLISH_PROFILE` secret is added to GitHub, any push to `main` touching `backend/` will auto-deploy.
2. **Unpause Supabase** — User must restore the paused project. After that, all DB-backed API calls work.
3. **Offline Caching (Shaazia's Feature):** Implement local SQLite / SharedPreferences caching for the map and reports so the app degrades gracefully without internet.
4. **Route Destination Input:** RouteScreen currently sets destination to 2km north of user. Could add a text field / tap-on-map to set custom destination.
5. **Emergency Accept/Resolve flow:** The bottom sheet on SOS markers has an "Accept" button but doesn't call `POST /emergency/:id/accept` yet — needs the auth token and request ID wired in.
