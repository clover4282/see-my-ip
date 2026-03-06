# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

All common tasks are in the Makefile:

```bash
make build          # Debug build
make release        # Release build
make run            # Build + kill existing + launch app
make rerun          # Kill + relaunch (no rebuild)
make kill           # Kill running app
make clean          # Clean build artifacts
make resolve        # Resolve SPM dependencies (Sparkle)
```

Direct xcodebuild: `xcodebuild -scheme SeeMyIP -configuration Debug build`

## Release Workflow

```bash
make bump V=0.2     # Update version in Info.plist
make sign           # Build Release, zip, sign with Sparkle EdDSA
make appcast        # Print appcast.xml <item> template (copy into docs/appcast.xml)
make dist TAG=v0.2  # Create GitHub Release with signed zip
```

After `make dist`, update `docs/appcast.xml` with the new `<item>` from `make appcast`, commit, and push to update GitHub Pages.

## Architecture

macOS menu bar app (SwiftUI `MenuBarExtra`) with no Dock icon (`LSUIElement = true`).

**App entry:** `SeeMyIPApp` creates a `MenuBarExtra` (popover window) and a separate `Window` for Settings. A single `IPDashboardViewModel` (`@Observable`, `@MainActor`) is shared via SwiftUI `.environment()`.

**Data flow:**
- `IPDashboardViewModel` is the central state holder — owns all services, manages refresh cycle, network monitoring, and history
- `LocalNetworkService` uses `NWPathMonitor` for real-time network change detection (2s debounce)
- Public IP is fetched via `PublicIPService` with multi-provider fallback (ipify → ifconfig.me → AWS CheckIP)
- `GeoLocationService` uses ip-api.com (HTTP, requires ATS exception in Info.plist)
- `IPHistoryService` persists IP change history to JSON file in Application Support

**Sparkle auto-update:** Conditionally compiled with `#if canImport(Sparkle)`. `AppDelegate` initializes `SPUStandardUpdaterController`. EdDSA public key in Info.plist (`SUPublicEDKey`). Appcast hosted at GitHub Pages (`docs/appcast.xml`). When Sparkle is unavailable, `UpdateService` provides manual update check via GitHub Releases API.

**UI pattern:** Interactive buttons use `InteractiveButtonStyle` (defined in `CopyableText.swift`) which provides hover cursor change (`NSCursor.pointingHand`) and press feedback. The `interactiveForeground` modifier handles idle/hover/pressed color states.

## Key Conventions

- Version is stored in `SeeMyIP/Resources/Info.plist` (`CFBundleShortVersionString`), not in build settings
- Settings are stored in `UserDefaults` with keys defined in `Constants.UserDefaultsKeys`
- All Sparkle-related code must be wrapped in `#if canImport(Sparkle)` guards
- No test target exists; verify changes by building and running the app
- Xcode project file (`project.pbxproj`) must be manually updated when adding new Swift files — add entries to PBXBuildFile, PBXFileReference, the parent PBXGroup, and PBXSourcesBuildPhase
