# Search UGM Mobile - AI Development Guide

## Project Overview

Flutter mobile app (v1.2.0+3) for Search UGM Digital Services Hub. Single-file architecture with integrated search, AI chat, facility mapping, and service directory—no authentication required.

**Critical**: This is a production-ready Indonesian-language app for Universitas Gadjah Mada. All UI text, comments, and documentation must be in Bahasa Indonesia.

## Architecture & File Structure

### Monolithic App Design
All UI screens live in `lib/src/app.dart` (~1187 lines):
- `MainShell`: Bottom nav with 5 tabs (Beranda, Cari, AI, Layanan, Histori)
- `HomeScreen`: Expandable/collapsible 11-category quick access grid
- `SearchScreen`: Search with category chips, Tri Dharma & year filters
- `AiScreen`: RAG-powered chat with session-based Q&A
- `FacilityMapScreen`: Full-screen OSM map with pinch-zoom and draggable sheet
- `UgmTileMap`: Custom tile renderer with mathematical projection (no map library!)

**Why monolithic?**: Rapid prototyping. Documented tech debt in `BUILD_REPORT_v1.2.0.md` recommends splitting into feature modules + repository/state management layer for v2.0.

### Core Files
- `lib/src/api_client.dart`: HTTP client using `dart:io` HttpClient (no external packages). Single endpoint with action-based routing.
- `lib/src/models.dart`: Plain Dart classes (`SearchItem`, `Facility`, `ChatAnswer`). No JSON serialization libs.
- `lib/src/device_bridge.dart`: Platform channel for URL launching & local history (SharedPreferences on Android).
- `android/app/.../MainActivity.kt`: **Missing in source** - method channel handlers `openUrl`, `getHistory`, `saveHistory` should exist but folder is empty. Check if implementation exists or create stub.

## API Integration Patterns

### Endpoint Configuration
```dart
static const _endpoint = 'https://search.ugm.ac.id/ai/search%26dsh/api/api.php';
```
**Never change this** without backend coordination. No staging environment configured (backlog item: `--dart-define=API_BASE_URL`).

### Browse vs. Search Parameters
**Critical distinction** (caused production bug):
```dart
// Browse (empty query) uses 'type' parameter (NOT 'entity_type')
{'action': 'browse', 'type': 'news', 'page': '1', 'limit': '30'}

// Search uses 'types' parameter
{'action': 'smart_search', 'q': 'beasiswa', 'types': 'all'}
```
Parameter naming follows web implementation. Tests enforce this in `widget_test.dart`.

### Tech4disaster Special Case
```dart
// Maps to publication with gok filter
type == 'tech4disaster' → {'type': 'publication', 'publication_gok': 'Tech4disaster'}
```

### Entity Type Validation
Results from browse may contain mixed types due to backend behavior. Client-side filter:
```dart
items = items.where((item) => item.type == expectedType).toList();
```

## UI/UX Conventions

### Color Palette
```dart
const ugmBlue = Color(0xFF003F88);   // Primary brand
const navy = Color(0xFF071D49);      // Dark text/accents
const surface = Color(0xFFF5F7FB);   // Background
```

### Expand/Collapse Animation Pattern
Quick access grid uses `AnimatedCrossFade` + `AnimatedRotation` + `AnimatedSwitcher` combo (180ms-420ms durations). Cubic easing for smooth expansion. See `HomeScreen._build()`.

### Jelajahi Category Labels
11 hardcoded categories with icon mappings:
```dart
(label: 'Tech4disaster', type: 'tech4disaster', icon: Icons.emergency_outlined)
```
Add new categories here + update `buildSearchParameters()` for special mappings.

## Map Implementation Deep Dive

### Custom Tile Rendering (No Package!)
`UgmTileMap` manually implements Web Mercator projection:
```dart
math.Point<double> world(double lat, double lon, [double? atZoom]) {
  final scale = math.pow(2, atZoom ?? zoom) * 256.0;
  final x = (lon + 180) / 360 * scale;
  final sinLat = math.sin(lat * math.pi / 180).clamp(-0.9999, 0.9999);
  final y = (0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi)) * scale;
  return math.Point(x, y);
}
```
**Why manual?**: Full control over gestures. Don't refactor to flutter_map/google_maps without UX approval.

### Gesture Handling
- `GestureDetector.onScaleStart/Update` for pinch-zoom (11.0-19.0 range)
- `onDoubleTap` for +1 zoom
- Floating zoom buttons for accessibility
- Tests validate multi-pointer gestures (see `widget_test.dart` pinch test)

### OSM Attribution
**Legal requirement**:
```dart
'© OpenStreetMap contributors' // Bottom-left overlay, tappable link
```
Keep attribution visible on all tile implementations.

## Platform Channel Patterns

### Method Channel Usage
```dart
static const _channel = MethodChannel('id.ac.ugm.search/device');
await _channel.invokeMethod<void>('openUrl', {'url': url});
```

**Expected Android implementation** (missing from source):
- `openUrl`: Launch CustomTabs or browser intent
- `getHistory`: Read from SharedPreferences `search_history` key
- `saveHistory`: Persist top 20 queries as JSON array

### History Management
Client-side deduplication + 20-item limit. No server sync. Data lost on app uninstall.

## Development Workflow

### Quality Gates (Run Before Commit)
```bash
flutter analyze          # Zero tolerance for lints
flutter test             # All 3 tests must pass
```

### Running the App
```bash
flutter run              # Debug mode
flutter run --profile    # Performance testing
```
**Windows note**: Use PowerShell. Copy `android/local.properties.example` if needed:
```powershell
Copy-Item android/local.properties.example android/local.properties
```

### Build Commands
```bash
# Release APK (debug-signed in v1.2.0)
flutter build apk --release

# Split per ABI (recommended)
flutter build apk --release --split-per-abi

# App Bundle (for Play Store - NEEDS RELEASE KEYSTORE FIRST)
flutter build appbundle --release
```

### Test Categories
1. Navigation widget test (no Profil tab)
2. Browse parameter unit test (type vs. entity_type)
3. Pinch-to-zoom gesture test (no exceptions)

**Missing coverage**: Pagination, API error states, accessibility, integration tests.

## Known Technical Debt & Constraints

### Release Signing
**Production blocker**: Uses debug certificate. Before Play Store:
1. Obtain UGM upload keystore
2. Configure `android/app/build.gradle.kts` release signing
3. Never commit keystore or `key.properties`

### iOS Support
Project has Android-only configuration. To add iOS:
```bash
flutter create --platforms=ios .
cd ios; pod install; cd ..
```
Then configure bundle ID, Team signing, privacy descriptions.

### Monolithic App File
`app.dart` at 1187 lines. Recommended split (see `BUILD_REPORT_v1.2.0.md`):
- Feature modules: `features/home/`, `features/search/`, `features/map/`
- Repository layer for API abstraction
- State management (Riverpod/Bloc) for testability

### Missing Features (Backlog)
- Pagination/infinite scroll on search results
- Offline caching (search results, facilities)
- Map marker clustering at low zoom
- Observability (crash reporting, analytics)
- CI/CD pipelines

## Common Pitfalls

1. **Don't use 'entity_type' in browse**: Use 'type' parameter (backend contract).
2. **Don't skip client-side type filtering**: Backend may return mixed results.
3. **Don't remove OSM attribution**: Legal requirement.
4. **Don't add `flutter_map` without discussion**: Custom implementation is intentional.
5. **Don't hardcode API keys**: None exist in this project (public endpoint).
6. **Don't commit `android/local.properties`**: Gitignored for local SDK paths.
7. **Keep UI text in Bahasa Indonesia**: UGM audience requirement.

## Adding New Features

### New Browse Category
1. Add to `explore` list in `HomeScreen` with icon
2. Update `buildSearchParameters()` if special mapping needed (like Tech4disaster)
3. Add unit test for parameter generation
4. Smoke test API response manually

### New Screen
1. Add widget class in `app.dart` (for now)
2. Route via `Navigator.push()` or add to `MainShell.pages`
3. Use `DeviceBridge.openUrl()` for external links
4. Follow color palette (ugmBlue, navy, surface)

### Modifying API Client
1. Check `docs/BUILD_REPORT_v1.2.0.md` for endpoint contracts
2. Add method to `ApiClient` class
3. Create model in `models.dart` with `fromJson` factory
4. Handle `json['ok'] != true` error case
5. Add timeout (15s connect, 30-45s read)

## Key File Locations

- Entry point: `lib/main.dart` (8 lines)
- All screens: `lib/src/app.dart`
- HTTP logic: `lib/src/api_client.dart`
- Platform channel: `lib/src/device_bridge.dart`
- Data models: `lib/src/models.dart`
- Tests: `test/widget_test.dart`
- Build docs: `docs/BUILD_REPORT_v1.2.0.md`, `docs/DEVELOPMENT_INSTALLATION_GUIDE.md`
- Android config: `android/app/build.gradle.kts` (minSdk 24, targetSdk 36)
- Lints: `analysis_options.yaml` (avoid_print enabled)

## Resources

- Flutter version: 3.44.8 (Dart 3.12.2)
- Gradle: 8.13, AGP: 8.12.0, Kotlin: 2.2.0
- Target API: Android 36 (min 24)
- Zero external dependencies (pure Flutter SDK)
