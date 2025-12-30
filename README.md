# EduAble Flutter App

A Flutter application for personalized learning support for children with learning disabilities.

## Features

- User authentication (Login/Signup)
- Role-based dashboards (Student, Teacher, Parent, Admin)
- Learning disability assessment
- Personalized learning paths for:
  - Dyslexia
  - Dysgraphia
  - Dyscalculia
  - ADHD
  - Autism (ASD)
- Progress tracking
- Achievement system

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Node.js backend running (see Eduable-backend)

## Setup Instructions

1. **Install Flutter dependencies:**
   ```bash
   cd flutter_app
   flutter pub get
   ```

2. **Configure API endpoint:**
   - Open `lib/services/api_service.dart`
   - Update `baseUrl` if your backend is running on a different port or host
   - Default: `http://localhost:5000/api`

3. **For Android:**
   - Add internet permission in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   ```

4. **For iOS:**
   - Add network security exception in `ios/Runner/Info.plist` if using HTTP:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
   </dict>
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── user_model.dart
├── providers/                # State management
│   └── app_provider.dart
├── services/                 # API services
│   └── api_service.dart
├── router/                   # Navigation
│   └── app_router.dart
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── dashboards/           # Dashboard screens
│   ├── disorder/             # Disorder selection
│   ├── assessment/           # Assessment screen
│   └── disorders/            # Disorder-specific screens
└── widgets/                  # Reusable widgets
    └── navbar.dart
```

## Backend Connection

The Flutter app connects to the Node.js backend at `http://localhost:5000/api`.

**Important:** 
- For Android emulator, use `http://10.0.2.2:5000/api`
- For iOS simulator, use `http://localhost:5000/api`
- For physical devices, use your computer's IP address: `http://YOUR_IP:5000/api`

## API Endpoints Used

- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `PUT /api/assessment/update` - Save assessment results
- `GET /api/learning/personalized-lesson/:childId` - Get personalized lessons
- `GET /api/progress/:userId` - Get user progress
- `GET /api/parent-insights/:parentId` - Get parent insights
- `GET /api/lessons` - Get all lessons
- `POST /api/sync` - Sync data

## State Management

The app uses Provider for state management. The `AppProvider` manages:
- User authentication state
- User profile data
- UI preferences (dark mode, font size, contrast)
- Assessment results

## Navigation

The app uses `go_router` for navigation with protected routes based on user roles.

## Troubleshooting

1. **Connection errors:**
   - Ensure backend is running
   - Check API base URL in `api_service.dart`
   - Verify CORS settings in backend

2. **Build errors:**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check Flutter version compatibility

3. **Runtime errors:**
   - Check console logs
   - Verify all dependencies are installed
   - Ensure backend is accessible from your device/emulator

## Development Notes

- The app uses Material Design 3
- All colors follow the design system from the original React app
- State is persisted using SharedPreferences
- API calls use Dio for HTTP requests

## License

ISC

