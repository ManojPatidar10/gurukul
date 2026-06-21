# Gurukul — Mobile App (Flutter)

One Flutter codebase, role-based home screen: teachers see attendance + class
announcements, parents see their child's attendance/fees/updates. Builds to
both Android and iOS.

## 1. Local setup

You'll need the Flutter SDK installed locally (this build environment doesn't
have it — install from https://docs.flutter.dev/get-started/install, it's free).

```bash
cd mobile
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

Use the same Supabase project you set up for the web dashboard (`../web/README.md`)
— same database, same schools/students/login accounts.

## 2. Build a testable APK today (free, no store needed)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-public-key
```

The signed APK lands at `build/app/outputs/flutter-apk/app-release.apk`. Share
it directly (Google Drive, WhatsApp, email) for pilot-school teachers/parents
to sideload — no Play Store account needed for this stage.

**Don't want Flutter installed locally?** Push this folder to GitHub and run
the included `.github/workflows/build-apk.yml` (Actions tab → "Build Gurukul
APK" → Run workflow). Add `SUPABASE_URL` and `SUPABASE_ANON_KEY` as repo
secrets first (Settings → Secrets and variables → Actions). The built APK
downloads from the workflow run's Artifacts section — completely free.

## 3. Push notifications (Firebase Cloud Messaging — free)

1. Create a free Firebase project: https://console.firebase.google.com
2. Install the FlutterFire CLI: `dart pub global activate flutterfire_cli`
3. Run `flutterfire configure` from the `mobile/` folder — this generates
   `lib/firebase_options.dart` and the native config files automatically
4. Uncomment the Firebase init lines in `lib/main.dart`
5. Wire the `send-attendance-notification` edge function (see
   `../docs/04-API-SPEC.md`) to call FCM with the device token

## 4. Publishing to the app stores — what's actually required

This is the one part of the stack that **isn't free** — Apple and Google
charge platform fees directly, independent of any tooling choice:

### Google Play Store
1. Pay the **one-time $25** Google Play Console registration fee:
   https://play.google.com/console/signup
2. Build the release bundle: `flutter build appbundle --release --dart-define=...`
3. Create the app listing in Play Console, upload the `.aab` from
   `build/app/outputs/bundle/release/`, fill in store listing + content rating
4. Submit for review (usually a few hours to a couple of days)

### Apple App Store
1. Enroll in the **$99/year** Apple Developer Program:
   https://developer.apple.com/programs/enroll
2. You'll need a Mac at some point in this pipeline (Xcode signing) — if you
   don't own one, Codemagic's free tier (500 build minutes/month) includes
   cloud Mac builds, so this is still achievable without buying hardware
3. Build via Xcode or Codemagic, then submit through App Store Connect
4. Apple's review is typically 1–3 days, and is stricter than Google's about
   completeness (working login, no placeholder content, working privacy policy)

**Recommended order:** validate with 1–2 pilot schools using the free
sideloaded APK first (step 2). Once the product is genuinely working day to
day, then spend the $25 + $99/year to list on the stores — that way you're
not paying for store presence before you know teachers/parents will use it.

## Folder structure

```
lib/
  main.dart                       App entry point, Supabase init, theme
  theme/colors.dart                Shared design tokens (matches web)
  services/
    supabase_service.dart          Supabase client init
    auth_state.dart                 Auth + profile state (ChangeNotifier)
  models/models.dart               Dart models matching the DB schema
  screens/
    auth/login_screen.dart
    home_router.dart               Routes to Teacher or Parent home by role
    teacher/
      teacher_home_screen.dart      List of assigned classes
      attendance_marking_screen.dart Core <60s attendance flow
    parent/
      parent_home_screen.dart        Attendance / Fees / Updates tabs
    shared/announcement_compose_screen.dart
  widgets/stamp_badge.dart          Shared "ink stamp" status badge
.github/workflows/build-apk.yml    Free CI: builds APK on every push
```
