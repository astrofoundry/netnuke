# NetNuke

A macOS menu bar utility that toggles all network interfaces on/off. When off, network stays dead across reboots until manually re-enabled.

## Requirements

- macOS 26 Tahoe or later

## Install

1. Download `NetNuke.dmg` from [Releases](https://github.com/astrofoundry/netnuke/releases)
2. Drag `NetNuke.app` to Applications
3. On first launch, macOS will block the app because it is unsigned. To allow it:
   - Open **System Settings → Privacy & Security**
   - Scroll down to find *"NetNuke" was blocked from use because it is not from an identified developer*
   - Click **Open Anyway** and authenticate with your password
4. After that, NetNuke will launch normally

## Usage

Click the shield icon in the menu bar:

| State | Icon | Meaning |
|-------|------|---------|
| ON | Shield (green) | Network active |
| OFF | Shield slashed (red) | Network killed, persists across reboots |

- **Toggle OFF** — Disables all network interfaces and installs a LaunchDaemon to keep them off after reboot
- **Toggle ON** — Re-enables all interfaces and removes the LaunchDaemon

An admin password prompt appears on each toggle.

**Launch at Login** is enabled by default — NetNuke will start automatically after reboot so you always have access to the toggle.

## How It Works

- Discovers interfaces dynamically via `networksetup -listallnetworkservices`
- Toggles each interface with `networksetup -setnetworkserviceenabled`
- Installs a LaunchDaemon at `/Library/LaunchDaemons/com.netguard.killnet.plist` to persist the kill state across reboots
- Uses a boot script at `/usr/local/bin/netguard-killnet.sh` to re-disable interfaces on startup

## Build

```bash
xcodebuild -scheme NetNuke -configuration Release build
```

## License

MIT
