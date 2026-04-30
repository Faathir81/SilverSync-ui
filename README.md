# 📱 SilverSync Mobile (Frontend)

![Flutter Version](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat&logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green.svg)

SilverSync Mobile is the frontend client built with Flutter. It serves as an offline-first music player that communicates with the SilverSync Go API to synchronize Spotify playlists, download audio files directly from Google Drive to local storage, and manage device memory efficiently.

## 🏗️ Core Application Flow

1. **Sync:** User inputs a Spotify URL and triggers the backend processing.
2. **Fetch:** App retrieves the list of processed tracks and their Google Drive download links from the API.
3. **Download:** App downloads the `.mp3` files from Google Drive and saves them to the device's internal application storage.
4. **Play:** App plays the downloaded audio files entirely offline.
5. **Manage:** App automatically manages storage space by clearing old tracks if the storage limit is reached.

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** Riverpod / Provider (TBD)
* **Audio Engine:** `just_audio` (for background playback & playlist management)
* **Networking:** `dio` or `http`
* **Local Storage:** `path_provider` & `shared_preferences` / `sqflite`

---

## 🗺️ Development Roadmap

This roadmap focuses purely on technical implementation, system architecture, and performance optimization.

### Phase 1: Project Setup & Technical Layouts ⏳ (In Progress)
- [ ] Initialize Flutter project and organize folder structure (e.g., features, core, shared components).
- [ ] Implement base routing and navigation scheme.
- [ ] Translate structured technical layouts (generated via Figma AI) into reusable Flutter widgets.
- [ ] Setup State Management boilerplate.

### Phase 2: Local Storage & File Management 📝 (Planned)
- [ ] Implement `path_provider` to locate the secure application documents directory.
- [ ] Create a `DownloadManager` service to handle downloading files from Google Drive URLs to the local directory.
- [ ] Handle OS-level storage permissions (Android/iOS) using `permission_handler`.

### Phase 3: API Integration 📝 (Planned)
- [ ] Build HTTP client service using `dio` to communicate with the `SilverSync-API`.
- [ ] Implement endpoints: Send Sync request, Fetch available tracks, and check Sync status.
- [ ] Create data models/entities for parsing JSON responses.

### Phase 4: Audio Player Engine Integration 📝 (Planned)
- [ ] Integrate `just_audio` for local file playback.
- [ ] Implement playlist queueing, play/pause, next/previous logic.
- [ ] Setup background audio execution so music plays when the screen is locked or the app is minimized.
- [ ] Bind the audio player state to the UI progress bars and controls.

### Phase 5: Memory & Performance Optimization 📝 (Planned)
- [ ] Implement `ListView.builder` (Lazy Loading) for rendering large tracklists efficiently without memory leaks.
- [ ] Develop an LRU (Least Recently Used) Cache mechanism: automatically delete the oldest `.mp3` files when the app's local storage exceeds a predefined threshold (e.g., 2GB).
- [ ] Optimize state rebuilds to ensure UI components only update when their specific state changes.

---

## ⚙️ Prerequisites

To run this project locally, you need to install:
1. **Flutter SDK**
2. **Android Studio** (for Android Emulator) or **Xcode** (for iOS Simulator)
3. **VS Code** or another preferred IDE

## 🚀 How to Run (Local Development)
```bash
# Clone the repository
git clone [https://github.com/yourusername/silversync-mobile.git](https://github.com/yourusername/silversync-mobile.git)

# Go to project directory
cd silversync-mobile

# Get dependencies
flutter pub get

# Run the app (ensure an emulator or physical device is connected)
flutter run
