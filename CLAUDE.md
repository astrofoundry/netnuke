# NetNuke — Project Guidelines

## Overview

macOS menu bar utility (Swift 6 / SwiftUI) that toggles all network interfaces on/off with reboot persistence via LaunchDaemon.

## Tech Stack

- **Language**: Swift 6 (strict concurrency)
- **UI**: SwiftUI with `MenuBarExtra`
- **Platform**: macOS 26 Tahoe+
- **Build**: Xcode / `xcodebuild`
- **Distribution**: Unsigned `.dmg` via GitHub Releases
- **CI**: GitHub Actions

## Bundle ID

`com.astrofoundry.netnuke`

## Architecture

- `NetNukeApp.swift` — `@main` entry, `MenuBarExtra` scene, no dock icon
- `Views/MenuBarView.swift` — Toggle switch + Quit dropdown
- `ViewModels/NetworkViewModel.swift` — `@Observable @MainActor`, orchestrates toggle
- `Services/NetworkService.swift` — Interface discovery, shell script building
- `Services/PrivilegedExecutor.swift` — `NSAppleScript` admin execution
- `Services/LaunchDaemonManager.swift` — Plist/script install and removal

## Key Patterns

- **Caseless enums** for service types (no instances, static methods only)
- **Single auth prompt** per toggle — all commands combined into one shell script
- **State source of truth**: daemon plist existence on disk (`/Library/LaunchDaemons/com.netguard.killnet.plist`)
- **No defensive programming** — let exceptions bubble up, fail fast

## Build & Verify

```bash
xcodebuild -scheme NetNuke -configuration Release build
```

## Releasing

**Every deployment MUST go through `make release-*`.** Never push tags manually or deploy without it.

When the user asks to release, deploy, or ship — always run the appropriate make target after all code is committed and pushed:

```bash
make release-patch   # v1.0.0 → v1.0.1
make release-minor   # v1.0.1 → v1.1.0
make release-major   # v1.1.0 → v2.0.0
```

This updates `CFBundleShortVersionString` in `Info.plist`, commits, tags, pushes branch then tag separately (required for GitHub Actions to trigger). The CI workflow builds the `.app`, packages a versioned `.dmg` (`NetNuke-X.Y.Z.dmg`), and uploads it to GitHub Releases.

**Checklist before releasing:**
1. All code changes committed and pushed to `main`
2. Build succeeds locally: `xcodebuild -scheme NetNuke -configuration Release build`
3. Run `make release-{patch|minor|major}` (user specifies which)
4. Verify CI passes: `gh run list --repo astrofoundry/netnuke --limit 1`

## System Paths

- LaunchDaemon: `/Library/LaunchDaemons/com.netguard.killnet.plist`
- Kill script: `/usr/local/bin/netguard-killnet.sh`

## Conventions

- Swift 6 strict concurrency — all shared mutable state must be `@MainActor` or actor-isolated
- SF Symbols for menu bar icons (`shield` / `shield.slash`)
- No `any` types — use concrete types or generics
- Double quotes in string literals
- Self-descriptive code, minimal comments
