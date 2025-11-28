# 🚀 Deployment Guide: Supabase + Render

This guide will help you deploy your backend to the cloud so your TestFlight app works for everyone.

## Phase 1: Database Setup (Supabase)

1.  **Create Account:** Go to [Supabase.com](https://supabase.com/) and sign up.
2.  **New Project:** Click "New Project".
    *   **Name:** `diaspora-handbook`
    *   **Region:** Choose one close to your users (e.g., US East).
    *   **Password:** **IMPORTANT:** Save this database password!
3.  **Run Schema:**
    *   In Supabase Dashboard, go to the **SQL Editor** (icon on the left sidebar).
    *   Click "New Query".
    *   Copy the contents of `backend/database/schema_pg.sql` from your project.
    *   Paste it into the SQL Editor and click **RUN**.
    *   *Success!* Your database tables are created.
4.  **Get Connection String:**
    *   Go to **Project Settings** (gear icon) -> **Database**.
    *   Under "Connection string", select **Node.js**.
    *   Copy the URL. It looks like: `postgres://postgres:[YOUR-PASSWORD]@db.ref.supabase.co:5432/postgres`
    *   **Replace `[YOUR-PASSWORD]`** with the password you created in step 2.
    *   Save this URL for Phase 3.

---

## Phase 2: Push Code to GitHub

1.  Make sure all your changes are committed and pushed to GitHub.
    ```bash
    git add .
    git commit -m "Prepare backend for deployment"
    git push origin main
    ```

---

## Phase 3: Server Deployment (Render)

1.  **Create Account:** Go to [Render.com](https://render.com/) and sign up (you can use GitHub login).
2.  **New Web Service:**
    *   Click "New +" button -> **Web Service**.
    *   Connect your GitHub repository.
3.  **Configure Service:**
    *   **Name:** `diaspora-backend` (or similar)
    *   **Root Directory:** `backend` (This is important!)
    *   **Environment:** `Node`
    *   **Build Command:** `npm install`
    *   **Start Command:** `node server.js`
    *   **Free Tier:** Select "Free".
4.  **Environment Variables:**
    *   Scroll down to "Environment Variables".
    *   Add Key: `DATABASE_URL`
    *   Add Value: (The Supabase URL from Phase 1).
    *   Add Key: `NODE_VERSION`
    *   Add Value: `18` (Optional, but good practice).
5.  **Deploy:** Click "Create Web Service".
    *   Wait for the build to finish. It might take a few minutes.
    *   Once live, copy your **Service URL** (e.g., `https://diaspora-backend.onrender.com`).

---

## Phase 4: Update Flutter App

1.  Open `lib/services/api_service.dart`.
2.  Find the `baseUrl` getter.
3.  Update the return value to your new Render URL:
    ```dart
    // ... inside lib/services/api_service.dart
    String get baseUrl {
       // For Production / TestFlight
       return 'https://your-app-name.onrender.com/api'; 
    }
    ```
4.  **Commit and Push** these changes.
5.  **Build for TestFlight** (or run `flutter run --release` to test locally).

✅ **Done!** Your app now connects to a live cloud database.

