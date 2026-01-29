# 🚀 Buzzr Deployment Guide

Complete step-by-step guide to deploy Buzzr (Database, Backend, Frontend, and Socket Server).

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Database Setup (PostgreSQL)](#1-database-setup-postgresql)
3. [Socket Server Deployment](#2-socket-server-deployment)
4. [Backend/Frontend Deployment (Vercel)](#3-backendfrontend-deployment-vercel)
5. [Backend/Frontend Deployment (Render)](#3b-backendfrontend-deployment-render)
5. [Environment Variables Setup](#4-environment-variables-setup)
6. [Post-Deployment Steps](#5-post-deployment-steps)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- GitHub account
- Vercel account (free tier works)
- Database provider account (Vercel Postgres, Neon, or Supabase)
- Socket server hosting (Railway, Render, or Fly.io)
- Google Cloud Console account (for OAuth)
- Upstash account (for Redis)
- Cloudinary account (for media uploads)
- Google AI Studio account (for Gemini API)

---

## 1. Database Setup (PostgreSQL)

### Option A: Vercel Postgres (Recommended - Easiest Integration)

1. **Create Vercel Postgres Database:**
   - Go to [Vercel Dashboard](https://vercel.com/dashboard)
   - Click **Storage** → **Create Database** → **Postgres**
   - Choose a name (e.g., `buzzr-db`)
   - Select region closest to your users
   - Click **Create**

2. **Get Connection Strings:**
   - After creation, go to **Storage** → Your database
   - Copy:
     - `POSTGRES_PRISMA_URL` → This is your `DATABASE_URL`
     - `POSTGRES_URL_NON_POOLING` → This is your `DIRECT_URL`

### Option B: Neon (Free Tier Available)

1. **Sign up at [Neon](https://neon.tech)**
2. **Create a new project:**
   - Click **New Project**
   - Choose region
   - Click **Create Project**

3. **Get Connection Strings:**
   - Go to **Connection Details**
   - Copy:
     - **Connection string** → `DATABASE_URL`
     - **Direct connection string** → `DIRECT_URL`

### Option C: Supabase

1. **Sign up at [Supabase](https://supabase.com)**
2. **Create a new project**
3. **Get Connection Strings:**
   - Go to **Settings** → **Database**
   - Copy:
     - **Connection string** (URI) → `DATABASE_URL`
     - **Connection string** (Direct) → `DIRECT_URL`

### Run Prisma Migrations

```bash
# Install dependencies (if not already done)
npm install

# Generate Prisma Client
npx prisma generate

# Push schema to database (for development)
npx prisma db push

# OR create migration (for production)
npx prisma migrate dev --name init
```

---

## 2. Socket Server Deployment

The socket server is a **separate Node.js application**. Deploy it to one of these platforms:

### Option A: Railway (Recommended)

1. **Sign up at [Railway](https://railway.app)**
2. **Connect your GitHub repository:**
   - If socket server is in separate repo: Connect that repo
   - If in same repo: Use monorepo setup or deploy separately
3. **Deploy:**
   - Click **New Project** → **Deploy from GitHub repo**
   - Select your socket server repository
   - Railway auto-detects Node.js and deploys
4. **Get Socket URL:**
   - After deployment, Railway provides a public URL
   - Example: `https://buzzr-socket.up.railway.app`
   - Copy this URL (you'll need it for `NEXT_PUBLIC_SOCKET_URL`)

### Option B: Render

1. **Sign up at [Render](https://render.com)**
2. **Create Web Service:**
   - Click **New** → **Web Service**
   - Connect GitHub repo (socket server)
   - Set:
     - **Build Command:** `npm install`
     - **Start Command:** `npm start` (or your socket server start command)
   - Click **Create Web Service**
3. **Get Socket URL:**
   - Render provides URL like: `https://buzzr-socket.onrender.com`

> ⚠️ Note: The settings above are for the **socket server**. If you are deploying **this repository (Next.js app)** on Render, you must run `next build` during the build step (see the Render section below), otherwise `next start` will fail with “Could not find a production build in the '.next' directory”.

### Option C: Fly.io

1. **Install Fly CLI:** `curl -L https://fly.io/install.sh | sh`
2. **Login:** `fly auth login`
3. **Deploy:** `fly launch` (in socket server directory)
4. **Get Socket URL:** `https://your-app.fly.dev`

### Socket Server Environment Variables

Your socket server will need:
- `DATABASE_URL` (same as main app)
- `PORT` (usually auto-set by platform)
- Any other socket-specific env vars

---

## 3. Backend/Frontend Deployment (Vercel)

### Step 1: Prepare Repository

1. **Ensure `.env` is in `.gitignore`** (should already be there)
2. **Commit and push your code:**
   ```bash
   git add .
   git commit -m "Prepare for deployment"
   git push origin main
   ```

### Step 2: Deploy to Vercel

1. **Go to [Vercel Dashboard](https://vercel.com/dashboard)**
2. **Click "Add New..." → "Project"**
3. **Import your GitHub repository:**
   - Select the `buzzr` repository
   - Click **Import**

4. **Configure Project:**
   - **Framework Preset:** Next.js (auto-detected)
   - **Root Directory:** `./` (default)
   - **Build Command:** `npm run build` (default)
   - **Output Directory:** `.next` (default)
   - **Install Command:** `npm install` (default)

5. **Environment Variables:**
   - **Don't add them yet** - We'll do this in the next section
   - Click **Deploy** (it will fail, but that's okay - we'll add env vars next)

---

## 3b. Backend/Frontend Deployment (Render)

If you prefer Render over Vercel for hosting the **Next.js app**, create a **Web Service** and ensure Render runs a production build before starting the server.

1. **Create Web Service** (Render Dashboard → **New** → **Web Service**)
2. **Settings**
   - **Build Command:** `npm install && npm run build`
   - **Start Command:** `npm run start`
3. **Environment Variables**
   - Add the same variables from [Environment Variables Setup](#4-environment-variables-setup)
4. **Deploy**
   - Trigger a deploy (or redeploy) after env vars are added

## 4. Environment Variables Setup

### Step 1: Generate Secrets

**Generate AUTH_SECRET:**
```bash
# On macOS/Linux:
openssl rand -base64 32

# On Windows (PowerShell):
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))

# Or use online generator:
# https://generate-secret.vercel.app/32
```

### Step 2: Set Up Google OAuth

1. **Go to [Google Cloud Console](https://console.cloud.google.com)**
2. **Create a new project** (or use existing)
3. **Enable Google+ API:**
   - Go to **APIs & Services** → **Library**
   - Search "Google+ API" → Enable
4. **Create OAuth Credentials:**
   - Go to **APIs & Services** → **Credentials**
   - Click **Create Credentials** → **OAuth client ID**
   - Application type: **Web application**
   - **Authorized JavaScript origins:**
     - `http://localhost:3000` (for local dev)
     - `https://your-vercel-app.vercel.app` (your Vercel URL)
   - **Authorized redirect URIs:**
     - `http://localhost:3000/api/auth/callback/google`
     - `https://your-vercel-app.vercel.app/api/auth/callback/google`
   - Click **Create**
   - Copy **Client ID** and **Client Secret**

### Step 3: Set Up Upstash Redis

1. **Go to [Upstash](https://upstash.com)**
2. **Create Redis Database:**
   - Click **Create Database**
   - Choose region
   - Click **Create**
3. **Get Credentials:**
   - Copy `UPSTASH_REDIS_REST_URL` → This is `UPSTASH_REDIS_URL`
   - Copy `UPSTASH_REDIS_REST_TOKEN` → This is `UPSTASH_REDIS_TOKEN`

### Step 4: Set Up Cloudinary

1. **Go to [Cloudinary](https://cloudinary.com)**
2. **Sign up** (free tier available)
3. **Get Credentials:**
   - Go to **Dashboard**
   - Copy:
     - **Cloud name** → `CLOUDINARY_CLOUD_NAME`
     - **API Key** → `CLOUDINARY_API_KEY`
     - **API Secret** → `CLOUDINARY_API_SECRET`

### Step 5: Set Up Google Gemini API

1. **Go to [Google AI Studio](https://makersuite.google.com/app/apikey)**
2. **Create API Key**
3. **Copy the API key** → `GEMINI_API_KEY`

### Step 6: Add Environment Variables to Vercel

1. **Go to Vercel Dashboard** → Your project → **Settings** → **Environment Variables**

2. **Add each variable:**

   ```
   # Auth
   AUTH_URL=https://your-app.vercel.app
   AUTH_SECRET=<generated-secret-from-step-1>
   NEXTAUTH_URL=https://your-app.vercel.app
   NEXTAUTH_SECRET=<same-as-AUTH_SECRET>

   # Database
   DATABASE_URL=<from-database-setup>
   DIRECT_URL=<from-database-setup>

   # Google OAuth
   GOOGLE_CLIENT_ID=<from-google-cloud-console>
   GOOGLE_CLIENT_SECRET=<from-google-cloud-console>

   # Socket Server
   NEXT_PUBLIC_SOCKET_URL=https://your-socket-server.railway.app
   # (or Render/Fly.io URL)

   # Upstash Redis
   UPSTASH_REDIS_URL=<from-upstash-dashboard>
   UPSTASH_REDIS_TOKEN=<from-upstash-dashboard>
   RATELIMIT=ON

   # Google Gemini
   GEMINI_API_KEY=<from-google-ai-studio>

   # Cloudinary
   CLOUDINARY_CLOUD_NAME=<from-cloudinary>
   CLOUDINARY_API_KEY=<from-cloudinary>
   CLOUDINARY_API_SECRET=<from-cloudinary>
   ```

3. **Set Environment:**
   - For each variable, select: **Production**, **Preview**, and **Development**
   - Click **Save**

4. **Redeploy:**
   - Go to **Deployments** tab
   - Click **⋯** → **Redeploy**
   - Or push a new commit to trigger auto-deploy

---

## 5. Post-Deployment Steps

### Step 1: Run Prisma Migrations on Production

**Option A: Using Vercel CLI (Recommended)**

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Link project
vercel link

# Run migrations
npx prisma migrate deploy
```

**Option B: Using Prisma Studio (For manual setup)**

```bash
# Set DATABASE_URL in your local .env to production URL
DATABASE_URL=<production-database-url>

# Run migrations
npx prisma migrate deploy
```

### Step 2: Verify Deployment

1. **Check Vercel Deployment:**
   - Go to **Deployments** tab
   - Ensure latest deployment shows **Ready** ✅

2. **Test Application:**
   - Visit your Vercel URL: `https://your-app.vercel.app`
   - Test:
     - ✅ Homepage loads
     - ✅ Google OAuth login works
     - ✅ Socket connections work
     - ✅ Database queries work

3. **Check Logs:**
   - Go to **Deployments** → Click on deployment → **Functions** tab
   - Check for any errors

### Step 3: Update Google OAuth Redirect URIs

After deployment, update Google OAuth settings:
- Add production URL to **Authorized JavaScript origins**
- Add production callback URL to **Authorized redirect URIs**

---

## Troubleshooting

### Build Fails: "Failed to collect page data"

**Solution:** Already fixed! We added `export const dynamic = "force-dynamic"` to dynamic routes.

### Database Connection Errors

**Check:**
- `DATABASE_URL` and `DIRECT_URL` are correct
- Database is accessible from Vercel's IP ranges
- Prisma migrations have been run

**Fix:**
```bash
npx prisma migrate deploy
```

### Socket Connection Fails

**Check:**
- `NEXT_PUBLIC_SOCKET_URL` is correct
- Socket server is running and accessible
- CORS is configured on socket server

### OAuth Not Working

**Check:**
- `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are correct
- Redirect URIs match exactly (including `https://`)
- `AUTH_URL` matches your Vercel domain

### Environment Variables Not Loading

**Check:**
- Variables are set for **Production** environment
- Variable names match exactly (case-sensitive)
- Redeploy after adding variables

---

## 📝 Quick Reference Checklist

- [ ] Database created and migrations run
- [ ] Socket server deployed and URL obtained
- [ ] Vercel project created and deployed
- [ ] All environment variables added to Vercel
- [ ] Google OAuth configured with production URLs
- [ ] Upstash Redis configured
- [ ] Cloudinary configured
- [ ] Gemini API key added
- [ ] Production deployment verified
- [ ] Socket connections tested
- [ ] OAuth login tested

---

## 🔗 Useful Links

- [Vercel Documentation](https://vercel.com/docs)
- [Prisma Deployment Guide](https://www.prisma.io/docs/guides/deployment)
- [NextAuth.js Deployment](https://next-auth.js.org/deployment)
- [Railway Documentation](https://docs.railway.app)
- [Render Documentation](https://render.com/docs)

---

## 💡 Tips

1. **Use Vercel Postgres** for easiest database integration
2. **Test locally first** with production-like environment variables
3. **Monitor Vercel logs** during first deployment
4. **Keep `.env` file local** - never commit secrets
5. **Use Vercel's environment variable preview** to test before production

---

**Need Help?** Check the [Troubleshooting](#troubleshooting) section or review Vercel deployment logs.