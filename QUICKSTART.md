# 🏀 Basketball Stat Tracker - Quick Start Guide

## What You Got

A **complete, production-ready Flutter app** for tracking basketball statistics with:
- ✅ **17 Dart files** (3,000+ lines of code)
- ✅ **SQLite database** with 4 tables
- ✅ **Firebase cloud sync** (optional)
- ✅ **Live game tracking** with real-time stats
- ✅ **Export to CSV** and share functionality
- ✅ **Performance charts** and trends
- ✅ **Cross-platform** (Android, iOS, Web, Desktop)

## Installation (2 Minutes)

### Option 1: Automated Setup (Recommended)

**macOS/Linux:**
```bash
cd basketball_stat_tracker
./setup.sh
```

**Windows:**
```cmd
cd basketball_stat_tracker
setup.bat
```

### Option 2: Manual Setup

```bash
cd basketball_stat_tracker
flutter pub get

# For Web Support (REQUIRED for web):
dart run sqflite_common_ffi_web:setup

flutter run
```

## First Steps

### 1. Create Your First Team (30 seconds)
1. Launch app → Tap **Teams** tab
2. Tap **+** button
3. Enter team name → Tap **Add**

### 2. Add Players (1 minute)
1. Tap on your team → Tap **Add Player**
2. Enter: Name, Jersey #, Position
3. Repeat for more players

### 3. Track Your First Game (2 minutes)
1. **Games** tab → **New Game**
2. Select teams and date
3. Tap on game → **Select a player**
4. Use **Quick Action buttons**:
   - **Made 2PT**: +2 points
   - **Made 3PT**: +3 points
   - **+Rebound**, **+Assist**, etc.
5. Stats update in real-time!
6. Tap **✓** when finished

### 4. View Statistics
**Stats** tab → Select player → See averages, trends, charts!

### 5. Export Data
**Stats** screen → **⋮** menu → **Export CSV** or **Share Summary**

## Core Features

**Stats Tracked:**
- Basic: Points, Rebounds, Assists
- Advanced: FG%, 3P%, FT%, Steals, Blocks, Turnovers, Fouls

**Analytics:**
- Season averages (PPG, RPG, APG)
- Shooting percentages
- Performance trends chart
- Game-by-game breakdown

**Cloud Sync (Optional):**
Settings → Enable Cloud Sync → Backup to Firebase

## Platform Support

✅ Android | iOS | Web | macOS | Windows | Linux

## Firebase Setup (Optional - 5 minutes)

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

**Without Firebase:** App works perfectly with local storage!

## Common Commands

```bash
flutter run                 # Run app
flutter run -d android     # Android
flutter run -d ios         # iOS
flutter run -d chrome      # Web
flutter build apk          # Build Android
```

## Troubleshooting

**Package errors:** `flutter pub get`
**Build errors:** `flutter clean && flutter pub get`
**Firebase errors:** Skip it, app works without cloud sync

## Pro Tips

1. Track games **live** during actual games
2. Use **quick actions** for fast entry
3. **Export regularly** for backups
4. **Enable cloud sync** for multi-device use
5. Tap **player chips** to quickly switch

---

**Enjoy tracking! 🏀** 

Full docs in README.md | Technical details in TECHNICAL_OVERVIEW.md
