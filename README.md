# Basketball Stat Tracker

A comprehensive Flutter app for tracking basketball statistics with live game tracking, historical stats, and optional cloud sync.

## Features

### Core Features
- ✅ **Independent Player Management**: Manage all players in a global pool with optional team assignment.
- ✅ **Multi-Team Support**: Create and manage multiple teams with individual rosters.
- ✅ **Live Game Tracking**: Track stats in real-time during games
- ✅ **Comprehensive Stats**: 
  - Basic: Points, Rebounds, Assists
  - Advanced: FG%, 3P%, FT%, Steals, Blocks, Turnovers, Fouls
- ✅ **Historical Data**: View trends and performance over time
- ✅ **Charts & Graphs**: Visualize player performance
- ✅ **Export**: Export stats to CSV
- ✅ **Share**: Share player summaries
- ✅ **Cloud Sync**: Optional Firebase sync across devices
- ✅ **Offline Support**: Works completely offline with SQLite (Native & Web)

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (2.17.0 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account (optional, for cloud sync)

## Installation

### 1. Clone or Download

If you have this as a ZIP, extract it. Otherwise:
```bash
git clone <repository-url>
cd basketball_stat_tracker
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup (Optional - for Cloud Sync)

If you want cloud sync functionality:

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

This will:
- Create a Firebase project (or select existing one)
- Register your app with Firebase
- Generate `lib/firebase_options.dart` with your credentials

If you skip this step, the app will work fine with local storage only.

### 4. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run

# For Web
# Run this once to generate assets:
dart run sqflite_common_ffi_web:setup
flutter run -d chrome

# For Desktop (Windows/macOS/Linux)
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── firebase_options.dart              # Firebase config (auto-generated)
├── models/                            # Data models
│   ├── team.dart
│   ├── player.dart
│   ├── game.dart
│   └── player_stats.dart
├── services/                          # Business logic
│   ├── database_helper.dart          # SQLite database
│   ├── firebase_sync_service.dart    # Cloud sync
│   └── export_service.dart           # CSV export & sharing
├── providers/                         # State management
│   └── data_provider.dart
└── screens/                           # UI screens
    ├── home_screen.dart
    ├── teams_screen.dart
    ├── players_screen.dart
    ├── team_detail_screen.dart
    ├── games_screen.dart
    ├── live_game_screen.dart
    ├── stats_screen.dart
    └── settings_screen.dart
```

## Usage Guide

### 1. Create a Team
1. Go to the **Teams** tab
2. Tap the **+** button
3. Enter team name
4. Add players with jersey numbers and positions

### 2. Create a Game
1. Go to the **Games** tab
2. Tap **New Game**
3. Select home and away teams
4. Set date and location (optional)

### 3. Track Live Stats
1. Open a game from the **Games** tab
2. Select a player from the chips at the top
3. Use quick action buttons:
   - **Made 2PT / Missed 2PT**: Field goals
   - **Made 3PT / Missed 3PT**: Three-pointers
   - **Made FT / Missed FT**: Free throws
   - **+Rebound, +Assist, +Steal, etc.**: Other stats
4. Stats update automatically and show in real-time
5. Tap **✓** to finish the game when done

### 4. View Statistics
1. Go to the **Stats** tab
2. Select a player from the dropdown
3. View:
   - Season averages (PPG, RPG, APG)
   - Shooting percentages
   - Performance trends (chart)
   - Recent game log
4. Export to CSV or share summary

### 5. Cloud Sync (Optional)
1. Go to **Settings** tab
2. Enable **Cloud Sync**
3. Use **Push to Cloud** to backup
4. Use **Pull from Cloud** to restore on another device

## Database Schema

### Teams Table
- `id` (TEXT PRIMARY KEY)
- `name` (TEXT)
- `logo` (TEXT, optional)
- `created_at` (TEXT)

### Players Table
- `id` (TEXT PRIMARY KEY)
- `name` (TEXT)
- `team_id` (TEXT, foreign key)
- `jersey_number` (INTEGER)
- `position` (TEXT)
- `created_at` (TEXT)

### Games Table
- `id` (TEXT PRIMARY KEY)
- `home_team_id` (TEXT, foreign key)
- `away_team_id` (TEXT, foreign key)
- `game_date` (TEXT)
- `location` (TEXT, optional)
- `is_complete` (INTEGER boolean)
- `home_score` (INTEGER)
- `away_score` (INTEGER)
- `created_at` (TEXT)

### Player Stats Table
- `id` (TEXT PRIMARY KEY)
- `game_id` (TEXT, foreign key)
- `player_id` (TEXT, foreign key)
- `points`, `rebounds`, `assists` (INTEGER)
- `field_goals_made`, `field_goals_attempted` (INTEGER)
- `three_pointers_made`, `three_pointers_attempted` (INTEGER)
- `free_throws_made`, `free_throws_attempted` (INTEGER)
- `steals`, `blocks`, `turnovers`, `personal_fouls` (INTEGER)
- `minutes_played` (INTEGER)
- `created_at`, `updated_at` (TEXT)

## Customization

### Change Theme Colors
Edit `lib/main.dart`:
```dart
primarySwatch: Colors.orange,  // Change to your color
```

### Add More Stats
1. Add fields to `PlayerStats` model
2. Update database schema in `database_helper.dart`
3. Add UI controls in `live_game_screen.dart`

### Modify Positions
Edit the dropdown in `team_detail_screen.dart`:
```dart
['Point Guard', 'Shooting Guard', ...]  // Add your positions
```

## Troubleshooting

### Firebase Not Working
- Ensure you ran `flutterfire configure`
- Check `lib/firebase_options.dart` exists
- Verify Firebase project is active

### Database Issues
- Delete app and reinstall to reset database
- Or use "Reload Data" in Settings

### Export Not Working
- Grant storage permissions on Android
- Check file access permissions on iOS

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

## Platform-Specific Setup

### Android
- Minimum SDK: 21 (Android 5.0)
- Add permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS
- Minimum iOS: 12.0
- Run `cd ios && pod install`

### Web
- Run `dart run sqflite_common_ffi_web:setup` to generate capabilities
- Firebase works with limited config (offline mode supported)

## Future Enhancements

Potential features to add:
- Shot charts (location tracking)
- Team comparisons
- League/season management
- Player photos
- Game video/photo attachments
- Advanced analytics (PER, TS%, etc.)
- Multi-language support
- Dark mode toggle

## Contributing

Feel free to fork and customize this app for your needs!

## License

This project is open source and available under the MIT License.

## Support

For issues or questions:
1. Check this README
2. Review the code comments
3. Check Flutter documentation: https://flutter.dev/docs

## Technologies Used

- **Flutter**: Cross-platform framework
- **SQLite**: Local database (via sqflite package)
- **Firebase**: Cloud sync (via firebase_core, cloud_firestore)
- **Provider**: State management
- **FL Chart**: Data visualization
- **Share Plus**: Sharing functionality
- **CSV**: Export functionality
- **UUID**: Unique ID generation

---

Enjoy tracking your basketball stats! 🏀
