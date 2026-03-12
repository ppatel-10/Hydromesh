# Azure App Service Deployment Guide

## 1. Create Azure App Service

1. Go to [portal.azure.com](https://portal.azure.com)
2. Click **Create a resource** → **Web App**
3. Fill in:
   - **Subscription**: Azure for Students
   - **Resource Group**: Create new → `hydromesh-rg`
   - **Name**: `hydromesh-api` (this becomes `hydromesh-api.azurewebsites.net`)
   - **Runtime stack**: Node 18 LTS
   - **OS**: Linux
   - **Region**: Central India (or closest)
   - **Pricing**: Free F1
4. Click **Review + Create** → **Create**

## 2. Configure Environment Variables

Go to your App Service → **Configuration** → **Application settings**, add:

| Name | Value |
|------|-------|
| `DATABASE_URL` | `postgresql://postgres:Hydromesh%402025@db.zllbvvgufhhhktaxlpqp.supabase.co:5432/postgres` |
| `JWT_SECRET` | (generate a random 64-char string) |
| `SUPABASE_URL` | `https://zllbvvgufhhhktaxlpqp.supabase.co` |
| `SUPABASE_SERVICE_KEY` | (from Supabase Dashboard → Settings → API → service_role key) |
| `PORT` | `8080` |
| `NODE_ENV` | `production` |
| `CORS_ORIGINS` | `*` |

> **Note**: Azure App Service uses port 8080 by default on Linux. The env var is `CORS_ORIGINS` (with an S) — this matches the code in `backend/src/index.js`.

Click **Save** after adding all variables.

## 3. Enable WebSockets (Required for Socket.io)

> ⚠️ **This step is critical.** Without it, real-time features (live map markers, SOS alerts) will silently fail.

In Azure Portal → App Service → **Configuration** → **General settings**:
- **Web sockets**: **On**

Click **Save**, then **Restart** the App Service.

## 4. Configure Startup Command

In Azure Portal → App Service → **Configuration** → **General settings**:
- **Startup Command**: `cd backend && npm start`

## 5. Set Up GitHub Actions Auto-Deploy

### Option A: Publish Profile (Recommended)

1. In Azure Portal → your App Service → **Deployment Center** → **Get Publish Profile**
2. Download the `.PublishSettings` file
3. In GitHub → repo **Settings** → **Secrets and variables** → **Actions**:
   - Add **secret**: `AZURE_WEBAPP_PUBLISH_PROFILE` = paste entire file content
   - Add **variable**: `AZURE_WEBAPP_NAME` = `hydromesh-api`
4. Push to `main` branch — GitHub Actions will auto-deploy!

### Option B: Azure Deployment Center (Simpler)

1. In Azure Portal → your App Service → **Deployment Center**
2. Source: **GitHub**
3. Authorize and select `theSaksham02/Hydromesh`
4. Branch: `main`
5. Build provider: **GitHub Actions**
6. Azure will auto-create the workflow

## 6. Verify Deployment

```bash
curl https://hydromesh-api.azurewebsites.net/api/health
```

Should return:
```json
{"status":"ok","version":"1.4.0","dbMode":"supabase-rest"}
```

Test all endpoints:
```bash
# Auth
curl -X POST https://hydromesh-api.azurewebsites.net/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"citizen@test.com","password":"password123"}'

# Reports (public)
curl https://hydromesh-api.azurewebsites.net/api/reports

# Weather
curl "https://hydromesh-api.azurewebsites.net/api/weather/current?latitude=51.5074&longitude=-0.1278"
```

## 7. Update Flutter App

Once health check passes, in `mobile/lib/config/app_config.dart`:
- Set `_env = 'azure'`
- Update `_azureAppName` if you chose a different App Service name

Then push to `main` — GitHub Actions will rebuild the APK automatically.

## Troubleshooting

- **502 Bad Gateway**: Check startup command is `cd backend && npm start`
- **App not starting**: Check **Log stream** in Azure Portal for errors
- **DB connection fails**: Ensure DATABASE_URL uses `%40` for `@` in password
- **Socket.io not connecting**: Ensure WebSockets is **On** in Configuration → General settings
- **CORS errors**: Add your frontend domain to `CORS_ORIGINS` env var (note: plural, with S)
