# CLAUDE.md – Project Design Primer

> **Purpose** – Give any AI assistant (Claude, ChatGPT, etc.) an unambiguous snapshot of the minimalist **strength‑training tracker** we are building as a native iOS app with CloudKit sync, zero server costs, and offline‑first design.

---

## 1 · High‑Level Overview

- **Scope**  Log barbell/DB exercises only (no cardio, nutrition, or body‑weight modules).
- **Platform**  iOS-only – optimized for iPhone with iPad support.
- **Offline‑first**  All writes land in Core Data, sync via CloudKit across user's devices.
- **Theme**  Monochrome — `#000` background, `#3a3a3a` components, `#fff` active states (WCAG AA contrast).
- **Distribution**  Free app, no backend costs, privacy-focused with iCloud sync.
- **Commit often after each change**

---

## 2 · Tech Stack

### 2.1 Native iOS – Swift + UIKit/SwiftUI

| Concern            | Choice                                               | Rationale                                        |
| ------------------ | ---------------------------------------------------- | ------------------------------------------------ |
| Language / Tooling | **Swift 5.9+**, Xcode 15+                          | Native performance, full platform access.        |
| UI Framework       | **SwiftUI** with UIKit bridges                      | Modern declarative UI, backward compatibility.   |
| Architecture       | **MVVM** + Combine                                  | Reactive data flow, testable separation.         |
| Charts             | **Swift Charts** (iOS 16+)                          | Native, performant, follows system design.       |
| Local Storage      | **Core Data** + CloudKit                            | Apple's ORM with built‑in sync capabilities.     |
| Authentication     | **CloudKit** (iCloud account)                       | Zero auth complexity, automatic across devices.  |
| Testing            | **XCTest** + **XCUITest**                           | Native unit & UI testing frameworks.             |
| Notifications      | **UserNotifications** framework                     | Rest timer alerts, workout reminders.            |

### 2.2 Data & Sync – CloudKit + Core Data

| Concern         | Choice                                                     | Rationale                                    |
| --------------- | ---------------------------------------------------------- | -------------------------------------------- |
| Local Database  | **Core Data** with CloudKit schema                        | Offline‑first, automatic CloudKit mapping.   |
| Cloud Sync      | **CloudKit** private database                             | Free for users, handles conflicts, secure.   |
| Data Model      | Core Data entities with `CKRecord` attributes             | CloudKit‑compatible schema design.           |
| Conflict Res.   | CloudKit's built‑in last‑writer‑wins + manual resolution  | Handles offline/online sync automatically.   |
| Privacy         | Private CloudKit database                                  | Data stays in user's iCloud, not shared.     |
| Backup          | Automatic via iCloud + Core Data                          | Users' data backed up with their iCloud.     |

### 2.3 Development & Tooling

- **Package Manager:** Swift Package Manager for dependencies.
- **CI:** GitHub Actions → SwiftLint, unit tests, build validation.
- **Distribution:** App Store Connect via Xcode Cloud or fastlane.
- **Analytics:** None (privacy‑first) or minimal native frameworks.

---

## 3 · Core Data Schema (CloudKit Compatible)

> Entity & attribute names use `camelCase`. All entities include `createdAt`, `updatedAt` timestamps. CloudKit handles soft‑delete via `recordChangeTag`.

### 3.1 Core Training Entities

| Entity                 | Key Attributes                                                                                            | Purpose                                                                      |
| ---------------------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **Exercise**           | `id UUID`, `name String`, `category String`, `variantOf Exercise?`                                       | Seeded with ≈150 movements; variants (e.g., _Paused Bench_) reference parent. |
| **WorkoutTemplate**    | `id UUID`, `name String`, `daysPerWeek Int16`                                                            | Powers cards on **Workouts** tab.                                            |
| **TemplateExercise**   | `template WorkoutTemplate`, `exercise Exercise`, `displayOrder Int16`, `targetSets Int16`, `targetReps Int16` | Join entity for template ↔ exercise relationships.                           |
| **WorkoutSession**     | `id UUID`, `template WorkoutTemplate?`, `startedAt Date`, `finishedAt Date?`                             | One per workout execution.                                                   |
| **ExerciseSet**        | `session WorkoutSession`, `exercise Exercise`, `setIndex Int16`, `reps Int16`, `load Double`, `isPartial Bool`, `dropsetOfIndex Int16?` | Individual sets within a workout session.                                    |
| **RestLog**            | `session WorkoutSession`, `setIndex Int16`, `seconds Int32`                                              | Rest‑timer data for analytics.                                              |

### 3.2 CloudKit Integration

- **Record Zones:** Private database, custom zone for atomic sync operations
- **Relationships:** Core Data relationships map to `CKReference` fields
- **Conflict Resolution:** CloudKit's automatic merge + manual resolution for competing writes
- **Schema Migration:** Handled via Core Data model versions, CloudKit schema updates
- **Authentication:** Automatic via user's iCloud account, no separate auth needed

---

## 4 · Data Operations (Local + CloudKit Sync)

> No REST API needed. All operations are local Core Data calls that automatically sync via CloudKit when network is available.

### 4.1 Core Data Operations

```swift
// All CRUD operations use NSManagedObjectContext
let context = persistentContainer.viewContext

// CloudKit sync happens automatically in background
// No manual sync calls needed
```

### 4.2 CloudKit Sync Behavior

| Operation | Local Behavior | CloudKit Sync |
| --------- | -------------- | ------------- |
| **Create** | Immediate save to Core Data | Syncs on next network availability |
| **Update** | Immediate local update | Automatic background sync |
| **Delete** | Soft delete locally | CloudKit tombstone record |
| **Fetch**  | Always from local Core Data | CloudKit updates merged automatically |

### 4.3 Data Access Patterns

| Use Case | Implementation |
| -------- | -------------- |
| **Start Workout** | Create `WorkoutSession`, link to `WorkoutTemplate` |
| **Log Set** | Create `ExerciseSet` linked to current session |
| **View History** | `NSFetchRequest` with date predicates |
| **Calculate 1RM** | Local computation from `ExerciseSet` data |
| **Export Data** | Generate JSON/CSV from Core Data query results |

---

## 5 · Data Flow (Offline‑First + CloudKit)

1. User taps **Start** on a Workout card → Creates `WorkoutSession` in Core Data, available immediately.
2. Each set saved to Core Data → CloudKit sync queued automatically in background.
3. Rest timer fires `UserNotifications` → Works completely offline.
4. App launch/foreground → CloudKit automatically fetches remote changes and merges.
5. **Conflict Resolution:** CloudKit handles most conflicts; app resolves exercise‑specific conflicts (e.g., competing set updates).

---

## 6 · iOS UI Components

| Screen       | SwiftUI Component                         | Notes                                    |
| ------------ | ----------------------------------------- | ---------------------------------------- |
| Workouts Tab | `List` + custom `WorkoutCard` views       | Monochrome design, haptic feedback.      |
| Calendar Tab | `CalendarView` (iOS 16+) or third‑party   | Month view with workout indicators.       |
| Progress Tab | `Chart` (Swift Charts)                    | Line (1RM) & bar (volume) native charts. |
| Workout View | Custom timer UI + `ScrollView`            | Live rest timer, set logging interface.  |
| Persistence  | `Core Data` + `CloudKit`                  | Automatic sync, offline‑first storage.   |

---

## 7 · Formulas & Calculations

- **Work per set:** `work = reps × load`.
- **1RM estimate:** Epley formula  `1RM = load × (1 + reps / 30)` (valid ≤ 10 reps).
- **Weekly Volume:** rolling 7‑day sum of `work` grouped by exercise.

---

## 8 · Security & Privacy

- **No Authentication Required:** Uses iCloud account automatically.
- **Data Privacy:** All data stays in user's private iCloud, never on external servers.
- **Local Security:** iOS Keychain for sensitive data, Core Data encryption at rest.
- **Network Security:** All CloudKit communication uses Apple's TLS infrastructure.
- **No Tracking:** Zero analytics or user tracking, completely privacy‑focused.

---

## 9 · Build & Deployment

1. **Local Dev:** Xcode 15+ → iOS Simulator, CloudKit Development environment.
2. **CI:** GitHub Actions → SwiftLint, XCTest unit tests, build verification.
3. **Distribution:** App Store Connect → TestFlight beta, App Store release.
4. **CloudKit Setup:** Configure CloudKit schema, enable CloudKit in Xcode project.
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