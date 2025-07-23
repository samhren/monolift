# Monolift React Native

A minimalist strength training tracker built with React Native and Expo.

## Features

- ✅ Create workout templates with preset names or custom names
- ✅ Combine muscle groups (e.g., "Chest + Back + Shoulders") 
- ✅ Select workout days for each template
- ✅ Clean, dark monochrome UI
- ✅ iCloud sync on iOS (via react-native-cloud-storage)
- ✅ Offline-first with cloud backup

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npx expo start
```

3. Run on device:
- iOS: Press `i` or scan QR code with Camera app
- Android: Press `a` or scan QR code with Expo Go app
- Web: Press `w`

## Architecture

- **Storage**: `react-native-cloud-storage` for iCloud sync on iOS
- **Navigation**: React Navigation with bottom tabs
- **State**: React Context for workout data management
- **UI**: Custom components with monochrome design (#000 background, #3a3a3a components, #fff active states)

## Project Structure

```
├── components/           # Reusable UI components
├── contexts/            # React Context providers
├── screens/            # Main app screens
├── types/              # TypeScript type definitions
├── utils/              # Utility functions (storage, etc.)
└── App.tsx            # Main app component
```

## Cloud Storage

Uses `react-native-cloud-storage` which provides:
- **iOS**: Native iCloud integration 
- **Android/Web**: Google Drive integration (requires setup)
- **Offline-first**: All data stored locally, synced to cloud when available

Data is stored as JSON files in the user's cloud storage, automatically syncing across their devices.

## Development

This is a complete port of the Swift iOS app with all the same features:
- Snappy picker for workout name selection
- Days selection with toggleable weekdays
- Body parts combination system
- Clean, minimal UI with proper animations
- Template creation and management

The app maintains the same monochrome aesthetic and smooth interactions as the original Swift version.