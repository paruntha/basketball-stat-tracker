# Basketball Stat Tracker
# Version: 1.0.0
# Created: 2026

description: A comprehensive basketball statistics tracking application
platforms:
  - Android
  - iOS
  - Web
  - macOS
  - Windows
  - Linux

## Quick Start

1. Run setup script:
   - macOS/Linux: `./setup.sh`
   - Windows: `setup.bat`

2. Or manually:
   ```bash
   flutter pub get
   flutter run
   ```

## File Count Summary
- Models: 4 files
- Services: 3 files
- Providers: 1 file
- Screens: 7 files
- Main: 1 file
- Config: 1 file
- Total Dart Files: 17

## Key Features Implemented
✅ Multi-team management
✅ Player roster management
✅ Live game tracking
✅ Basic stats (Points, Rebounds, Assists)
✅ Advanced stats (FG%, 3P%, Steals, Blocks, Turnovers)
✅ Historical stats and trends
✅ Performance charts
✅ CSV export
✅ Share functionality
✅ SQLite local storage
✅ Firebase cloud sync (optional)
✅ Cross-platform support

## Technology Stack
- Flutter SDK 3.0+
- Dart 2.17+
- SQLite (via sqflite)
- Firebase (optional)
- Provider (state management)
- FL Chart (visualization)

## Database
- 4 tables (teams, players, games, player_stats)
- Foreign key relationships
- Cascading deletes
- Optimized queries

## Lines of Code (Approximate)
- Models: ~300 lines
- Services: ~600 lines
- Providers: ~250 lines
- Screens: ~1,800 lines
- Total: ~3,000 lines of Dart code

## Package Dependencies
Core: flutter, provider
Database: sqflite, path
Firebase: firebase_core, firebase_auth, cloud_firestore
UI: fl_chart, intl
Utils: uuid, csv, path_provider, share_plus
