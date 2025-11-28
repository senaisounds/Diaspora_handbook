# Backend Connection Guide

This guide explains how to connect your Flutter app to the backend server during development.

---

## 🔍 Understanding the Connection Error

When you see this message:

```
"Showing cached data. Unable to connect to server. Please check your connection."
```

It means:
- ✅ Your app is working correctly (showing cached data)
- ⚠️ The backend server is either not running or unreachable
- 📱 The app continues to work offline using cached data

**This is a feature, not a bug!** Your app has offline support built-in.

---

## 🚀 Quick Fix: Start the Backend Server

### Step 1: Start the Backend

Open a new terminal and run:

```bash
cd /Users/senaimotley/Diaspora_handbook/backend
npm install  # Only needed first time
npm start
```

You should see:
```
🚀 Server running on http://localhost:3000
📊 Health check: http://localhost:3000/health
📅 Events API: http://localhost:3000/api/events
```

### Step 2: Configure the Backend URL

The backend URL is automatically configured based on your platform:

#### For iOS Simulator (Current Setup)
- URL: `http://192.168.77.40:3000/api`
- This is your computer's local IP address

#### For Android Emulator
- URL: `http://10.0.2.2:3000/api`
- This is automatically used when running on Android

#### For Physical Devices
- Both iOS and Android devices need your computer's IP address
- Make sure your device is on the **same WiFi network** as your computer

### Step 3: Restart Your App

After starting the backend:
1. Stop your Flutter app (if running)
2. Restart it
3. Pull down to refresh on the home screen
4. The error message should disappear!

---

## 🔧 Troubleshooting

### Issue: Still showing "Unable to connect to server"

**Solution 1: Check if backend is running**
```bash
curl http://localhost:3000/health
```

Should return: `{"status":"ok","timestamp":"..."}`

**Solution 2: Verify your IP address**

Your current IP is set to: `192.168.77.40`

If your IP changed (e.g., connected to different WiFi), update it:

```bash
# Get your current IP address
ipconfig getifaddr en0  # For WiFi
# or
ipconfig getifaddr en1  # For Ethernet
```

Then update `lib/services/api_service.dart`:
```dart
return 'http://YOUR_NEW_IP:3000/api';
```

**Solution 3: Check firewall settings**
- Make sure your firewall allows connections on port 3000
- On macOS: System Preferences → Security & Privacy → Firewall

**Solution 4: For Physical Devices**
- Ensure device is on the same WiFi network as your computer
- Some corporate/public WiFi networks block device-to-device communication

---

## 📱 Platform-Specific URLs

### iOS Simulator
```dart
// In api_service.dart
return 'http://192.168.77.40:3000/api';  // Your computer's IP
```

### Android Emulator
```dart
// In api_service.dart
return 'http://10.0.2.2:3000/api';  // Special Android emulator address
```

### Physical Devices (Both iOS & Android)
```dart
// In api_service.dart
return 'http://192.168.77.40:3000/api';  // Your computer's IP (same WiFi)
```

### Production (Deployed Backend)
```dart
// In api_service.dart
return 'https://api.yourapp.com';  // Your production API URL
```

---

## 🎯 Current Configuration

Your app is currently configured as follows:

| Platform | URL | Status |
|----------|-----|--------|
| iOS Simulator | `http://192.168.77.40:3000/api` | ✅ Configured |
| Android Emulator | `http://10.0.2.2:3000/api` | ✅ Auto-configured |
| Physical Devices | `http://192.168.77.40:3000/api` | ⚠️ Requires same WiFi |

---

## 🧪 Testing the Connection

### Test 1: Backend Health Check
```bash
curl http://localhost:3000/health
```

Expected: `{"status":"ok","timestamp":"2025-11-25T..."}`

### Test 2: Get Events from Backend
```bash
curl http://localhost:3000/api/events
```

Expected: JSON array of events

### Test 3: Test from iOS Simulator
```bash
curl http://192.168.77.40:3000/health
```

Expected: Same as Test 1

### Test 4: In-App Test
1. Open the app
2. Pull down to refresh on home screen
3. Check if the blue error banner disappears
4. Events should load from the backend

---

## 💡 Development Workflow

### Option 1: With Backend (Recommended)
1. Start backend: `cd backend && npm start`
2. Run Flutter app: `flutter run`
3. App loads live data from backend
4. Changes to backend are immediately available

### Option 2: Without Backend (Offline Mode)
1. Just run Flutter app: `flutter run`
2. App uses cached data
3. Good for UI development when you don't need live data

### Option 3: Use Dummy Data
If you don't want to run the backend at all:
1. The app automatically falls back to cached data
2. Cached data comes from previous successful API calls
3. If no cache exists, the app will show empty state

---

## 🌐 Production Deployment

When deploying to production:

1. **Deploy your backend** to a hosting service:
   - Heroku
   - AWS
   - Google Cloud
   - DigitalOcean
   - etc.

2. **Update the API URL** in `lib/services/api_service.dart`:
   ```dart
   String get baseUrl {
     // Use environment variable or build configuration
     const String productionUrl = 'https://api.yourapp.com';
     const String developmentUrl = 'http://192.168.77.40:3000/api';
     
     // Return production URL in release mode
     return const bool.fromEnvironment('dart.vm.product')
         ? productionUrl
         : developmentUrl;
   }
   ```

3. **Build the app**:
   ```bash
   flutter build ios --release
   flutter build apk --release
   ```

---

## 📊 Backend Server Commands

```bash
# Install dependencies (first time only)
cd backend && npm install

# Start the server
npm start

# Stop the server
# Press Ctrl+C in the terminal

# Check if server is running
curl http://localhost:3000/health

# View server logs
# They appear in the terminal where you ran npm start

# Reset the database (if needed)
npm run init-db

# Seed with sample data
npm run seed-db
```

---

## 🆘 Still Having Issues?

1. **Check the terminal** where you ran `npm start` for error messages
2. **Check Flutter console** for API error messages
3. **Verify your IP hasn't changed** (WiFi networks can reassign IPs)
4. **Try restarting both** backend and Flutter app
5. **Check if port 3000 is already in use** by another application

---

## 📝 Quick Reference

| What | Command |
|------|---------|
| Get your IP | `ipconfig getifaddr en0` |
| Start backend | `cd backend && npm start` |
| Test backend | `curl http://localhost:3000/health` |
| Test from simulator | `curl http://192.168.77.40:3000/health` |
| Restart Flutter app | Stop and run again, or hot restart (R) |

---

**Remember**: The offline mode is a feature! Your app works even without the backend, showing cached data to users.

