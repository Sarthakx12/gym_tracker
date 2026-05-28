# GymTracker

A dark, minimal Android app for tracking gym workouts — built with Flutter.

## Download

**[→ Latest release (v1.0.0)](https://github.com/Sarthakx12/gym_tracker/releases/tag/v1.0.0)**

Download `app-release.apk`, enable "Install unknown apps" in Android settings, and install.

---

## Features

- **Workout logging** — exercises, sets, weight & reps per session
- **Live timer** — elapsed time shown during active workout
- **Rest timer** — 90s countdown after each set with haptic alert
- **Previous best** — shows last recorded weight × reps when adding a set
- **Exercise search** — search + muscle group filter in the exercise picker
- **Body weight tracking** — log and track your weight over time
- **Workout streak** — consecutive days trained shown with 🔥
- **Activity calendar** — dot matrix of the past 3 months
- **Volume & progress charts** — weekly volume bars, per-exercise strength line chart
- **BLE heart rate** — connects to Redmi Watch (or any BLE HR monitor) for live heart rate
- **Cloud sync** — optional Supabase backend; works fully offline with SQLite
- **Auth** — sign in / sign up to sync across devices, or use local-only guest mode

## Screenshots

> *(add screenshots here)*

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Local storage | SQLite via sqflite |
| Cloud sync | Supabase (Postgres + Auth) |
| State management | Provider |
| Charts | fl_chart |
| BLE | flutter_blue_plus |

## Building from source

**Requirements:** Flutter 3.44+, Java 17, Android SDK

```bash
git clone https://github.com/Sarthakx12/gym_tracker.git
cd gym_tracker
flutter pub get
flutter run
```

### Release build

You need a `android/key.properties` file and `android/app/upload-keystore.jks` (not included in the repo — keep these secret).

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

## Supabase setup (optional)

1. Create a project at [supabase.com](https://supabase.com)
2. Run `supabase_schema.sql` in the SQL Editor
3. Add your URL and anon key to `lib/main.dart`

The app works fully offline without Supabase — cloud sync is opt-in.

## License

MIT
