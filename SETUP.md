# Flutter App Setup Guide

## Quick Start

1. **Install Flutter dependencies:**
   ```bash
   cd flutter_app
   flutter pub get
   ```

2. **Start the backend server:**
   ```bash
   cd ../Eduable-backend
   npm start
   ```
   Make sure the backend is running on `http://localhost:5000`

3. **Update API endpoint for your platform:**

   **For Android Emulator:**
   - Edit `lib/services/api_service.dart`
   - Change `baseUrl` to: `'http://10.0.2.2:5000/api'`

   **For iOS Simulator:**
   - Keep `baseUrl` as: `'http://localhost:5000/api'`

   **For Physical Device:**
   - Find your computer's IP address
   - Change `baseUrl` to: `'http://YOUR_IP:5000/api'`
   - Example: `'http://192.168.1.100:5000/api'`

4. **Run the app:**
   ```bash
   flutter run
   ```

## Platform-Specific Setup

### Android

1. **Add internet permission** (if not already present):
   - Open `android/app/src/main/AndroidManifest.xml`
   - Add before `<application>` tag:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

2. **Allow HTTP connections** (for development):
   - In `android/app/src/main/AndroidManifest.xml`
   - Add `android:usesCleartextTraffic="true"` to `<application>` tag:
   ```xml
   <application
       android:usesCleartextTraffic="true"
       ...>
   ```

### iOS

1. **Allow HTTP connections** (for development):
   - Open `ios/Runner/Info.plist`
   - Add before `</dict></plist>`:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

### Web

1. **Update CORS in backend** (already done in `Eduable-backend/index.js`)
2. **Run Flutter web:**
   ```bash
   flutter run -d chrome
   ```

## Troubleshooting

### Connection Issues

**Problem:** Cannot connect to backend

**Solutions:**
1. Verify backend is running: `curl http://localhost:5000`
2. Check API base URL in `lib/services/api_service.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For physical device, use your computer's IP address
5. Check firewall settings

### Build Errors

**Problem:** Build fails with dependency errors

**Solutions:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Runtime Errors

**Problem:** App crashes on startup

**Solutions:**
1. Check Flutter version: `flutter --version` (should be 3.0.0+)
2. Check console for error messages
3. Verify all dependencies in `pubspec.yaml` are compatible

## Testing the Connection

1. Start the backend server
2. Run the Flutter app
3. Try to login or signup
4. Check backend console for API requests

## Production Deployment

Before deploying to production:

1. **Update API base URL** to production server
2. **Remove HTTP cleartext traffic** settings
3. **Update CORS** in backend to only allow your app's domain
4. **Enable HTTPS** for all API calls
5. **Add proper error handling** and logging
6. **Test on physical devices**

## Additional Notes

- The app uses SharedPreferences for local storage
- Authentication tokens are stored securely
- All API calls include authentication headers automatically
- State management uses Provider pattern

