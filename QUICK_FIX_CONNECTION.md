# 🚀 Quick Fix: "Unable to Connect to Server" Error

## What You're Seeing

```
┌─────────────────────────────────────────────────────────┐
│ 🌐 Showing cached data. Unable to connect to server.   │
│    Please check your connection.              [Retry]  │
└─────────────────────────────────────────────────────────┘
```

## What It Means

✅ **Good News**: Your app is working! It's showing cached (saved) data.  
⚠️ **Issue**: The backend server isn't running or isn't reachable.

---

## ⚡ 2-Minute Fix

### Step 1: Start the Backend (One Command)

Open a **new terminal** and run:

```bash
cd /Users/senaimotley/Diaspora_handbook/backend && npm start
```

You should see:
```
🚀 Server running on http://localhost:3000
```

**Keep this terminal open!** Don't close it.

### Step 2: Restart Your App

In Xcode:
1. Stop the app (⏹️ button)
2. Run it again (▶️ button)

Or press `R` in the terminal where Flutter is running (hot restart)

### Step 3: Pull to Refresh

In your app:
1. Go to the home screen
2. Pull down to refresh
3. The blue error banner should disappear! ✨

---

## 🎯 That's It!

The error should be gone. Your app is now connected to the backend and loading live data.

---

## 🔄 Every Time You Develop

**Before running your Flutter app:**

```bash
# Terminal 1: Start backend
cd backend && npm start

# Terminal 2: Run Flutter app  
flutter run
```

Keep both terminals open while developing.

---

## ❓ Still Not Working?

### Quick Checks:

1. **Is the backend running?**
   ```bash
   curl http://localhost:3000/health
   ```
   Should return: `{"status":"ok",...}`

2. **Did your WiFi change?**
   - If you connected to a different WiFi network, your IP changed
   - See `BACKEND_CONNECTION_GUIDE.md` for how to update it

3. **Is your firewall blocking it?**
   - macOS: System Preferences → Security & Privacy → Firewall
   - Allow connections on port 3000

---

## 💡 Pro Tip: You Don't Always Need the Backend!

Your app works offline! The error message means:
- ✅ App is functional
- ✅ Showing cached data
- ℹ️ Backend not available (but that's okay for development)

You can develop UI features without running the backend. The app will use cached data.

---

## 📚 More Help

- Detailed guide: `BACKEND_CONNECTION_GUIDE.md`
- Backend setup: `BACKEND_SETUP.md`
- Troubleshooting: `TROUBLESHOOTING.md`

---

**TL;DR**: Run `cd backend && npm start` in a terminal, then restart your app. Done! 🎉

