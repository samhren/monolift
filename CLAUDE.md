# CLAUDE.md – Project Design Primer

> **Purpose** – Give any AI assistant (Claude, ChatGPT, etc.) an unambiguous snapshot of the minimalist **strength‑training tracker** we are building as a cross-platform Flutter app with cloud sync, zero server costs, and offline‑first design.

---

## 1 · High‑Level Overview

- **Scope**  Log barbell/DB exercises only (no cardio, nutrition, or body‑weight modules).
- **Platform**  Cross-platform – optimized for iOS and Android with responsive design.
- **Offline‑first**  All writes land in local database, sync via cloud storage across user's devices.
- **Theme**  Monochrome — `#000` background, `#3a3a3a` components, `#fff` active states (WCAG AA contrast).
- **Distribution**  Free app, no backend costs, privacy-focused with cloud sync.
- **Commit often after each change**

---

## 2 · Tech Stack

### 2.1 Flutter – Dart + Material/Cupertino Design

| Concern            | Choice                                               | Rationale                                        |
| ------------------ | ---------------------------------------------------- | ------------------------------------------------ |
| Language / Tooling | **Dart 3.8+**, Flutter 3.24+                       | Cross-platform performance, hot reload.          |
| UI Framework       | **Flutter** with Material + Cupertino widgets       | Single codebase, native-feeling UI on both platforms. |
| Architecture       | **Riverpod** + **Provider** pattern                 | Reactive state management, testable separation.  |
| Charts             | **fl_chart** or **charts_flutter**                  | Rich charting capabilities, customizable.        |
| Local Storage      | **Hive** + **SQLite** (drift/floor)                 | Fast local database with cloud sync support.     |
| Cloud Storage      | **icloud_storage** package                          | Native iCloud sync for iOS, automatic backups.   |
| Authentication     | **Platform-specific** (iCloud/Google Drive)         | Zero auth complexity, automatic across devices.  |
| Testing            | **flutter_test** + **integration_test**             | Built-in unit & integration testing frameworks.  |
| Notifications      | **flutter_local_notifications**                     | Rest timer alerts, workout reminders.            |

### 2.2 Data & Sync – Local Database + Cloud Storage

| Concern         | Choice                                                     | Rationale                                    |
| --------------- | ---------------------------------------------------------- | -------------------------------------------- |
| Local Database  | **Hive** or **Drift** (SQLite) with cloud sync layer     | Offline‑first, fast local operations.       |
| Cloud Sync      | **icloud_storage** (iOS) + **Google Drive** (Android)    | Platform-native cloud storage using icloud_storage package. |
| Data Model      | Dart classes with JSON serialization                      | Type-safe models with cloud sync support.    |
| Conflict Res.   | Last-writer-wins with timestamp-based resolution          | Simple conflict resolution for offline/online sync. |
| Privacy         | User's private cloud storage                               | Data stays in user's cloud, not shared.     |
| Backup          | Automatic via platform cloud storage                      | Users' data backed up with their accounts.   |

### 2.3 Development & Tooling

- **Package Manager:** pub.dev for Flutter packages and dependencies.
- **CI:** GitHub Actions → dart format, flutter analyze, tests, build validation.
- **Distribution:** App Store Connect (iOS) + Google Play Store (Android).
- **Analytics:** None (privacy‑first) or minimal platform-specific frameworks.

---

## 3 · Data Schema

> Entity & attribute names use `camelCase`. All entities include `createdAt`, `updatedAt` timestamps. Cloud sync handles data persistence via icloud_storage package.

### 3.1 Core Training Entities (Dart Models)

| Entity                 | Key Attributes                                                                                            | Purpose                                                                      |
| ---------------------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **Exercise**           | `id String`, `name String`, `category String`, `variantOf String?`                                       | Seeded with ≈150 movements; variants (e.g., _Paused Bench_) reference parent. |
| **WorkoutTemplate**    | `id String`, `name String`, `daysPerWeek int`                                                           | Powers cards on **Workouts** tab.                                            |
| **TemplateExercise**   | `templateId String`, `exerciseId String`, `displayOrder int`, `targetSets int`, `targetReps int`        | Join entity for template ↔ exercise relationships.                           |
| **WorkoutSession**     | `id String`, `templateId String?`, `startedAt DateTime`, `finishedAt DateTime?`                         | One per workout execution.                                                   |
| **ExerciseSet**        | `sessionId String`, `exerciseId String`, `setIndex int`, `reps int`, `load double`, `isPartial bool`, `dropsetOfIndex int?` | Individual sets within a workout session.                                    |
| **RestLog**            | `sessionId String`, `setIndex int`, `seconds int`                                                       | Rest‑timer data for analytics.                                              |

### 3.2 Cloud Storage Integration

- **iCloud Storage:** iOS integration via `icloud_storage` package for seamless sync
- **Local Database:** Hive for fast local operations with JSON serialization
- **Conflict Resolution:** Last-writer-wins with timestamp-based resolution
- **Data Persistence:** JSON files stored in iCloud container, auto-synced across devices
- **Authentication:** Automatic via user's iCloud account, no separate auth needed

---

## 4 · Data Operations (Local + Cloud Sync)

> No REST API needed. All operations are local Hive/SQLite calls that automatically sync via icloud_storage when network is available.

### 4.1 Local Database Operations

```dart
// All CRUD operations use Hive boxes or SQLite queries
final box = await Hive.openBox<WorkoutTemplate>('templates');

// Cloud sync happens automatically in background
// No manual sync calls needed
```

### 4.2 Cloud Sync Behavior

| Operation | Local Behavior | Cloud Sync |
| --------- | -------------- | ----------- |
| **Create** | Immediate save to Hive/SQLite | Syncs JSON to iCloud on next network availability |
| **Update** | Immediate local update | Automatic background sync to iCloud |
| **Delete** | Soft delete locally | Remove from iCloud storage |
| **Fetch**  | Always from local database | iCloud updates merged automatically |

### 4.3 Data Access Patterns

| Use Case | Implementation |
| -------- | -------------- |
| **Start Workout** | Create `WorkoutSession`, link to `WorkoutTemplate` |
| **Log Set** | Create `ExerciseSet` linked to current session |
| **View History** | Hive query with date filters |
| **Calculate 1RM** | Local computation from `ExerciseSet` data |
| **Export Data** | Generate JSON/CSV from local database queries |

---

## 5 · Data Flow (Offline‑First + Cloud Sync)

1. User taps **Start** on a Workout card → Creates `WorkoutSession` in local database, available immediately.
2. Each set saved to Hive/SQLite → iCloud sync queued automatically in background.
3. Rest timer fires local notifications → Works completely offline.
4. App launch/foreground → icloud_storage automatically fetches remote changes and merges.
5. **Conflict Resolution:** Last-writer-wins with timestamp comparison for competing updates.

---

## 6 · Flutter UI Components

| Screen       | Flutter Widget                            | Notes                                    |
| ------------ | ----------------------------------------- | ---------------------------------------- |
| Workouts Tab | `ListView` + custom `WorkoutCard` widgets | Monochrome design, haptic feedback.      |
| Calendar Tab | `TableCalendar` or custom calendar widget | Month view with workout indicators.       |
| Progress Tab | `fl_chart` LineChart + BarChart           | Line (1RM) & bar (volume) charts.        |
| Workout View | Custom timer UI + `Column`/`ListView`     | Live rest timer, set logging interface.  |
| Navigation   | `BottomNavigationBar` + `Navigator`       | Tab-based navigation matching RN app.    |
| Persistence  | `Hive` + `icloud_storage`                 | Automatic sync, offline‑first storage.   |

---

## 7 · Formulas & Calculations

- **Work per set:** `work = reps × load`.
- **1RM estimate:** Epley formula  `1RM = load × (1 + reps / 30)` (valid ≤ 10 reps).
- **Weekly Volume:** rolling 7‑day sum of `work` grouped by exercise.

---

## 8 · Security & Privacy

- **No Authentication Required:** Uses iCloud account automatically via icloud_storage package.
- **Data Privacy:** All data stays in user's private iCloud, never on external servers.
- **Local Security:** Flutter secure storage for sensitive data, Hive encryption at rest.
- **Network Security:** All iCloud communication uses Apple's TLS infrastructure.
- **No Tracking:** Zero analytics or user tracking, completely privacy‑focused.

---

## 9 · Build & Deployment

1. **Local Dev:** Flutter SDK → iOS Simulator/Android Emulator, iCloud Development environment.
2. **CI:** GitHub Actions → dart format, flutter analyze, flutter test, build verification.
3. **Distribution:** App Store Connect (iOS) + Google Play Store (Android) → TestFlight/Internal Testing, production release.
4. **iCloud Setup:** Configure icloud_storage package, enable iCloud capabilities in iOS.
5. **No Server Costs:** Zero infrastructure to maintain or monitor.

---

## 10 · Business Model & Distribution

- **Pricing:** Completely free - no subscriptions, no ads, no server costs.
- **User Acquisition:** App Store organic discovery, fitness community sharing.
- **Value Proposition:** Privacy-first, works offline, syncs across devices, zero complexity.
- **Future Monetization:** Optional premium features (advanced analytics, coach sharing) if user base grows.
- **Competitive Advantage:** Zero ongoing costs allows permanent free tier.

---

##