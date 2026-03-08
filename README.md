# ADB Launcher (Batch)

ADB Launcher is a simple Windows batch tool that provides a **menu-based interface** for running common ADB commands without typing them manually.

The launcher helps users interact with Android devices through ADB using an easy CLI menu system.

This project is currently in **development builds**.

---

## Features

- Automatic **platform-tools detection**
- **Device selection** (supports multiple connected devices)
- **Install APK**
- **Uninstall applications**
- **Device reboot options**
  - Reboot
  - Reboot to bootloader
  - Reboot to recovery
- **Push files to device**
- **Pull files from device**
- **ADB shell**
- **Device information**
- **Start / Kill ADB server**
- **Start Shizuku**
- **Scrcpy integration**
  - Normal Scrcpy launch
  - Scrcpy with custom parameters
- **App list viewer**
  - Displays installed apps as:
  - `App Name [package.name]`

---

## Requirements

- Windows
- Android device with **USB debugging enabled**
- **Android platform-tools (ADB)**
- *(Optional)* **Scrcpy** for screen mirroring

---

## Installation

1. Download **Android platform-tools** from the official Android developer website.
2. Extract the folder somewhere on your system.
3. Place `adb_launcher.bat` inside the `platform-tools` folder  
   or make sure the launcher can find the folder automatically.
4. Run the script **as Admimistrator.**

---

## Usage

1. Connect your Android device with **USB debugging enabled**.
2. Run as administrator: adb_launcher.bat
3. Choose an option from the menu.

---

## Version Information
Current codename:
**Deep Sea**
Example version format:
v0.0.1-dev
v0.0.2-dev
v0.0.2.1-dev
Development builds are marked as **pre-releases**.

---

## Project Status

⚠ This project is currently in **active development**.

Features may change and bugs may appear between versions.

---

## License

See the LICENSE file included in this repository.
