# 📱 SilverSync Mobile (Frontend)

![Flutter Version](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat&logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green.svg)

SilverSync Mobile is a premium **Cloud Streaming** client built with Flutter. It serves as a sleek, cyberpunk-styled music player that synchronizes Spotify playlists to a private Google Drive storage via the SilverSync Go API, enabling seamless streaming without consuming local device storage.

## 🏗️ Core Application Flow

1. **Sync:** User inputs a Spotify URL and triggers the backend processing.
2. **Cloud Storage:** Backend downloads tracks and uploads them to the user's private Google Drive.
3. **Stream:** App fetches the track list and streams audio directly from Google Drive via the proxy API.
4. **Interactive UI:** Real-time sync monitoring, smart marquee text, and dynamic audio controls.

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (Functional & Persistent)
- **Audio Engine:** `just_audio` (with background playback & seek support)
- **Networking:** `dio` (for high-performance API communication)
- **Visuals:** Custom `AngularContainer` system & `Marquee` integration

---

## 🗺️ Development Roadmap

### Phase 1: Project Setup & Technical Layouts ✅
- [x] Initialize Flutter project and organize folder structure.
- [x] Implement base routing and navigation scheme.
- [x] Create reusable "Cyberpunk 2.0" widgets (AngularContainer).
- [x] Setup State Management with Riverpod.

### Phase 2: Cloud Integration & Sync 🚀 ✅
- [x] Build HTTP client service using `dio`.
- [x] Implement real-time Sync Status tracking with background polling.
- [x] Create "Auto-Resume" logic to persist sync activity across app restarts.
- [x] Implement "Dismiss" functionality for stale/finished sync jobs.

### Phase 3: Audio Engine & Streaming ✅
- [x] Integrate `just_audio` with full background execution.
- [x] **Real Seek Support:** Implementation of HTTP Range headers in Backend & Frontend for scrubbing.
- [x] Smart Marquee: Conditional scrolling text for long titles and artists.
- [x] UI/UX Optimization: 180px bottom padding for persistent player accessibility.

### Phase 4: Polish & Refinement 📝 (Current)
- [ ] Implement smart caching for album art to reduce data usage.
- [ ] Add more "Cyberpunk" micro-animations for better user engagement.
- [ ] Finalize metadata editing (Title/Artist) directly from the mobile client.

---

## ⚙️ Prerequisites
1. **Flutter SDK**
2. **SilverSync-API** (Running on your server/local machine)
