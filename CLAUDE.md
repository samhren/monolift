# CLAUDE.md – Project Design Primer

> **Purpose** – Give any AI assistant (Claude, ChatGPT, etc.) an unambiguous snapshot of the minimalist **strength‑training tracker** we are building, including tech stack, schema, auth model, REST endpoints, offline‑first sync rules, and UI conventions.

---

## 1 · High‑Level Overview

- **Scope**  Log barbell/DB exercises only (no cardio, nutrition, or body‑weight modules).
- **Audience**  A single lifter on one phone, but architecture allows multiple users later.
- **Offline‑first**  All writes land in a local SQLite store, then merge upstream on connectivity.
- **Theme**  Monochrome — `#000` background, `#3a3a3a` components, `#fff` active states (WCAG AA contrast).

---

## 2 · Tech Stack

### 2.1 Frontend – Expo React Native

| Concern            | Choice                                               | Rationale                                        |
| ------------------ | ---------------------------------------------------- | ------------------------------------------------ |
| Language / Tooling | **TypeScript**, Expo SDK ^51                         | Strict types, hot‑reload via Expo Go.            |
| Navigation         | `@react-navigation/native`                           | Battle‑tested, deep‑link support.                |
| State & Caching    | React Context + `react-query`                        | Handles optimistic updates & background refetch. |
| Charts             | `victory-native`                                     | Skia‑accelerated, MIT license, Expo‑compatible.  |
| Local Storage      | `expo-sqlite` or `@nozbe/watermelondb`               | Fast reads/writes, sync‑oriented design.         |
| Secure Storage     | `expo-secure-store`                                  | Encrypted keychain for tokens.                   |
| Testing            | **Detox** (E2E), React Native Testing Library (unit) | Covers UI & logic.                               |

### 2.2 Backend – Express + TypeScript + Postgres

| Concern         | Choice                                                     | Rationale                                    |
| --------------- | ---------------------------------------------------------- | -------------------------------------------- |
| HTTP Server     | **Express 5** (when stable)                                | Thin, extensible, wide community.            |
| Language        | **TypeScript** (esbuild + ts-node-dev)                     | Type‑safe routes & middleware.               |
| Validation      | **Zod**                                                    | Declarative schemas shared with RN app.      |
| ORM / DB Access | **TypeORM** (v0.3)                                         | Decorators, migrations, Postgres‑first.      |
| Auth            | Argon2 password hashing + PKCE OAuth 2.0 + device API keys | Native‑app‑friendly; avoids long‑lived JWTs. |
| Rate Limiting   | `express-rate-limit` + Redis (optional)                    | Protects `/auth/**` & `/sync/**`.            |
| Testing         | **Jest** + **Supertest**                                   | Fast API unit/integration coverage.          |
| DevOps          | Docker Compose: `api`, `postgres`, optional `redis`        | One‑command spin‑up.                         |
| Hosting         | Fly.io / Railway / Supabase Functions                      | Each supports Postgres + TLS by default.     |

### 2.3 Monorepo & Tooling

- **Package Manager:** NPM workspaces (root + `apps/mobile` + `apps/api`).
- **CI:** GitHub Actions → lint, type‑check, test for both apps.
- **CD:** Expo EAS for mobile; Docker image pushed to Fly.io for API.
- **Lint & Format:** ESLint, Prettier, Husky pre‑commit hook.

---

## 3 · Relational Schema (Postgres)

> Table & field names are `snake_case`. All tables include `created_at`, `updated_at`, and nullable `deleted_at` (soft‑delete).

### 3.1 Core Training Tables

| Table                  | Key Columns                                                                                               | Purpose                                                                      |
| ---------------------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| **users**              | `id UUID PK`, `email UNIQUE`, `password_hash`, `pkce_refresh_token`                                       | Single user now; future‑proof for >1.                                        |
| **devices**            | `id UUID PK`, `user_id FK`, `platform`, `api_key_hash`                                                    | Multiple phones per user; hashed device key.                                 |
| **exercises**          | `id PK`, `name`, `category`, `variant_of FK`                                                              | Seeded with ≈150 movements; variants (e.g., _Paused Bench_) point to parent. |
| **workout_templates**  | `id PK`, `user_id`, `name`, `days_per_week`                                                               | Powers cards on **Workouts** tab.                                            |
| **template_exercises** | `template_id FK`, `exercise_id FK`, `display_order`, `target_sets`, `target_reps`                         |                                                                              |
| **sessions**           | `id PK`, `template_id FK`, `start_ts`, `end_ts`                                                           | One per workout execution.                                                   |
| **sets**               | `session_id FK`, `exercise_id FK`, `set_idx`, `reps`, `load`, `is_partial`, `dropset_of set_idx nullable` |                                                                              |
| **rest_logs**          | `session_id`, `set_idx`, `seconds`                                                                        | Rest‑timer analytics.                                                        |

### 3.2 Sync & Audit Tables

| Table          | Key Columns                                                                                        | Purpose                               |
| -------------- | -------------------------------------------------------------------------------------------------- | ------------------------------------- |
| **sync_queue** | `id PK`, `user_id`, `table_name`, `row_id`, `op ENUM('INSERT','UPDATE','DELETE')`, `payload JSONB` | Local changes awaiting push.          |
| **change_log** | `id PK`, `user_id`, `table_name`, `row_id`, `change JSONB`                                         | Immutable audit for debugging merges. |

### 3.3 Auth Extras

- **Row‑Level Security (RLS)** enforces `user_id = current_setting('app.current_user')` on every table.
- Passwords hashed with Argon2; mobile clients use PKCE flow (code + verifier). Device API keys rotate every 30 days.

---

## 4 · API Surface (v1)

All endpoints are versioned under `/v1` and speak JSON over HTTPS. Error format: RFC 7807 Problem+JSON.

### 4.1 Auth

| Verb                  | Path                                                                                      | Description |
| --------------------- | ----------------------------------------------------------------------------------------- | ----------- |
| `POST /auth/register` | `{email, password, pkce_code}` → creates **user**, **device**, returns `{device_api_key}` |             |
| `POST /auth/token`    | PKCE exchange → returns short‑lived access + refresh token                                |             |
| `POST /auth/refresh`  | Rotate tokens                                                                             |             |
| `POST /auth/revoke`   | Invalidate current `device_api_key`                                                       |             |

Header: `Authorization: Device {device_api_key}` on all protected routes.

### 4.2 Sync

| Verb                         | Path                                                     | Purpose |
| ---------------------------- | -------------------------------------------------------- | ------- |
| `POST /sync/push`            | Client → server diff, returns `{conflicts, server_time}` |         |
| `GET  /sync/pull?since=<ts>` | Server deltas newer than timestamp                       |         |

### 4.3 CRUD

| Resource             | Routes                                                                           |
| -------------------- | -------------------------------------------------------------------------------- |
| **Exercise**         | `GET /exercise`, `POST /exercise`, `PATCH /exercise/:id`                         |
| **Workout Template** | `GET /template`, `POST /template`, `PATCH /template/:id`, `DELETE /template/:id` |
| **Session**          | `POST /session/start`, `PATCH /session/:id/finish`                               |
| **Set**              | `POST /session/:id/set`, `PATCH /session/:id/set/:idx`                           |
| **Metrics**          | `GET /metrics/weekly-volume`, `GET /metrics/1rm-history?exercise_id=`            |

---

## 5 · Client Data Flow

1. User taps **Start** on a Workout card → `POST /session/start` returns `session_id`.
2. Each set saved locally → appended to **sync_queue**.
3. Rest timer fires local notification; when network resumes, queue flushes via `/sync/push` (TLS‑only).
4. `GET /sync/pull` runs on app foreground to hydrate missed changes.

---

## 6 · Front‑End Components

| Screen       | Library                                  | Notes                                    |
| ------------ | ---------------------------------------- | ---------------------------------------- |
| Workouts Tab | `FlatList` + `reanimated` press feedback | Monochrome card UI.                      |
| Calendar Tab | `react-native-calendars`                 | Month view with marked dates.            |
| Progress Tab | `victory-native`                         | Line (1RM) & bar (weekly volume) charts. |
| Persistence  | `expo-sqlite` / `watermelondb`           | Offline storage & sync queue.            |

---

## 7 · Formulas & Calculations

- **Work per set:** `work = reps × load`.
- **1RM estimate:** Epley formula  `1RM = load × (1 + reps / 30)` (valid ≤ 10 reps).
- **Weekly Volume:** rolling 7‑day sum of `work` grouped by exercise.

---

## 8 · Security Notes

- Secrets in `expo-secure-store`.
- Device API keys rotate every 30 days.
- Backend: Helmet, rate‑limit middleware, parametrized queries.
- Postgres RLS + parameterized queries mitigate SQLi.

---

## 9 · Build & Deployment

1. **Local Dev:** `npm i && npm dev` → spins up Expo + Docker Compose (Postgres + API).
2. **CI:** GitHub Actions – lint, type‑check, Jest, Detox.
3. **CD:** Expo EAS for mobile; Fly.io (or Railway) for API; Postgres on Supabase.

---

##
