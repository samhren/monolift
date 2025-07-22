# Monolift Development Plan

> **Status**: Based on analysis of existing code and CLAUDE.md specifications  
> **Generated**: July 22, 2025

## Project Overview

Monolift is a minimalist strength-training tracker with offline-first architecture. The current implementation has:

- ✅ **Basic structure**: Monorepo with apps/api and apps/mobile
- ✅ **Database schema**: Complete Prisma schema matching CLAUDE.md spec
- ✅ **Basic API server**: Express server with health endpoint
- ✅ **Basic mobile app**: Expo React Native starter
- ✅ **Docker setup**: Postgres database container

## Development Phases

### Phase 1: Foundation & Tooling ⚡ HIGH PRIORITY

#### 1.1 Package Dependencies & Configuration

- [ ] **API**: Add missing dependencies (TypeORM → keep Prisma, add Zod validation)
- [ ] **Mobile**: Add navigation, state management, storage, and UI dependencies
- [ ] **Root**: Configure ESLint, Prettier, and Husky pre-commit hooks
- [ ] **Database**: Create .env files and database connection setup

#### 1.2 Development Environment

- [ ] Fix workspace script references in root package.json
- [ ] Add database migration and seeding scripts
- [ ] Test full dev environment (`npm run dev`)
- [ ] Create sample exercise seed data (~150 movements)

### Phase 2: Backend API Implementation ⚡ HIGH PRIORITY

#### 2.1 Core Infrastructure

- [ ] Set up Zod schemas for request/response validation
- [ ] Implement error handling middleware (RFC 7807 Problem+JSON)
- [ ] Add request logging and structured logging
- [ ] Configure environment variables and validation

#### 2.2 Authentication System

- [ ] **POST /v1/auth/register** - User registration with PKCE
- [ ] **POST /v1/auth/token** - PKCE token exchange
- [ ] **POST /v1/auth/refresh** - Token rotation
- [ ] **POST /v1/auth/revoke** - Device key invalidation
- [ ] Device API key middleware for protected routes
- [ ] Argon2 password hashing implementation

#### 2.3 CRUD Endpoints

- [ ] **Exercise routes**: GET, POST, PATCH /v1/exercise
- [ ] **Template routes**: GET, POST, PATCH, DELETE /v1/template
- [ ] **Session routes**: POST /v1/session/start, PATCH /v1/session/:id/finish
- [ ] **Set routes**: POST, PATCH /v1/session/:id/set
- [ ] **Metrics routes**: GET /v1/metrics/weekly-volume, /v1/metrics/1rm-history

#### 2.4 Sync System (Backend)

- [ ] **POST /v1/sync/push** - Accept client changes, detect conflicts
- [ ] **GET /v1/sync/pull** - Return server changes since timestamp
- [ ] Conflict resolution logic and merge strategies
- [ ] Change logging for audit trail

### Phase 3: Mobile App Foundation ⚡ HIGH PRIORITY

#### 3.1 Architecture Setup

- [ ] Configure React Navigation (tab + stack navigators)
- [ ] Set up React Context for state management
- [ ] Integrate React Query for server state
- [ ] Configure Expo SQLite for local storage
- [ ] Implement secure token storage (expo-secure-store)

#### 3.2 Design System & Theme

- [ ] Create monochrome theme constants (#000, #3a3a3a, #fff)
- [ ] Build reusable UI components (Button, Input, Card, etc.)
- [ ] Ensure WCAG AA contrast compliance
- [ ] Set up typography and spacing scales

#### 3.3 Core Screens

- [ ] **Workouts Tab**: Template cards with FlatList
- [ ] **Calendar Tab**: Month view with react-native-calendars
- [ ] **Progress Tab**: Victory-native charts setup
- [ ] **Settings/Profile**: Basic user settings
- [ ] Navigation between screens and deep linking

#### 3.4 Local Database & Models

- [ ] SQLite schema matching Postgres structure
- [ ] Local CRUD operations for exercises, templates, sessions, sets
- [ ] Sync queue implementation for offline changes
- [ ] Data persistence and retrieval logic

### Phase 4: Offline-First Sync System 🔶 MEDIUM PRIORITY

#### 4.1 Client Sync Logic

- [ ] Detect network connectivity changes
- [ ] Queue local changes when offline
- [ ] Implement optimistic updates with rollback
- [ ] Background sync on app foreground
- [ ] Conflict resolution UI for user decisions

#### 4.2 Sync Queue Management

- [ ] Batch operations for efficient syncing
- [ ] Retry logic with exponential backoff
- [ ] Handle partial sync failures
- [ ] Sync status indicators in UI

#### 4.3 Data Integrity

- [ ] Validate data consistency between local/remote
- [ ] Handle edge cases (app killed during sync, etc.)
- [ ] Implement sync debugging tools
- [ ] Add sync analytics and monitoring

### Phase 5: Advanced Features & UX ⚡ HIGH PRIORITY

#### 5.1 Workout Flow

- [ ] Start workout from template
- [ ] Set entry with weight/reps input
- [ ] Rest timer with notifications
- [ ] Exercise substitution/notes
- [ ] Workout completion and summary

#### 5.2 Progress Tracking

- [ ] 1RM calculation and history (Epley formula)
- [ ] Weekly volume charts
- [ ] Progress photos (optional future)
- [ ] Personal records tracking
- [ ] Workout streak tracking

#### 5.3 Template Management

- [ ] Create/edit workout templates
- [ ] Exercise library with search/filter
- [ ] Template sharing (future)
- [ ] Program progression (future)

### Phase 6: Testing Infrastructure 🔶 MEDIUM PRIORITY

#### 6.1 Backend Testing

- [ ] Jest unit tests for API endpoints
- [ ] Supertest integration tests
- [ ] Database testing with test containers
- [ ] Auth flow testing
- [ ] Sync logic testing

#### 6.2 Mobile Testing

- [ ] React Native Testing Library setup
- [ ] Component unit tests
- [ ] Integration tests for key flows
- [ ] Detox E2E tests for critical paths
- [ ] Mock API responses for testing

#### 6.3 Test Automation

- [ ] Test data fixtures and factories
- [ ] Coverage reporting and thresholds
- [ ] Automated test runs in CI
- [ ] Visual regression testing (optional)

### Phase 7: CI/CD & Deployment 🔷 LOW PRIORITY

#### 7.1 GitHub Actions Setup

- [ ] Lint and type-check on PR
- [ ] Run tests for both apps
- [ ] Build verification
- [ ] Security scanning
- [ ] Dependency vulnerability checks

#### 7.2 Deployment Pipeline

- [ ] **API**: Docker build and deploy to Fly.io/Railway
- [ ] **Mobile**: Expo EAS build and submission
- [ ] Database migration automation
- [ ] Environment-specific configurations
- [ ] Health checks and monitoring

#### 7.3 Infrastructure

- [ ] Production Postgres setup (Supabase/etc)
- [ ] Redis for rate limiting (optional)
- [ ] CDN for static assets (future)
- [ ] Backup and disaster recovery
- [ ] Monitoring and alerting (Sentry, etc)

## Current Implementation Status

### ✅ Completed

- Basic monorepo structure with NPM workspaces
- Prisma schema with all required tables
- Docker Compose with Postgres
- Basic Express server with health check
- Expo React Native app shell

### 🚧 Partially Complete

- Package.json scripts (some workspace references need fixing)
- Basic dependencies installed (missing key libraries)

### ❌ Not Started

- Authentication system
- API endpoints beyond health check
- Mobile app screens and navigation
- Offline sync system
- Testing infrastructure
- CI/CD pipeline

## Recommended Start Order

1. **Fix development environment** (Phase 1.1-1.2)
2. **Build authentication system** (Phase 2.2)
3. **Create basic API endpoints** (Phase 2.3)
4. **Set up mobile app navigation** (Phase 3.1)
5. **Implement core workout flow** (Phase 5.1)
6. **Add sync system** (Phase 4.1-4.2)

## Success Criteria

- [ ] User can register and log in
- [ ] User can create workout templates
- [ ] User can start and complete workouts
- [ ] Data syncs between offline and online
- [ ] App works fully offline for core features
- [ ] Charts show progress over time
- [ ] All code passes tests and type checking
