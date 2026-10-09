# Bluetooth Robot Controller

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Arduino](https://img.shields.io/badge/Arduino-00979D?style=flat-square&logo=arduino&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?style=flat-square&logo=android&logoColor=white)

A Flutter (Android) app that connects to an Arduino over Bluetooth and sends drive commands to a robot or RC car, and shows the responses the Arduino sends back.

## Features

- Scan for and connect to a Bluetooth serial device (HC-05 / HC-06 class modules)
- Send single-character motion commands (forward, turn, stop) to the board
- Receive and display the Arduino's responses in a chat-style view
- Arduino sketch included, so the whole loop can be tested end to end

## Repository layout

| Path | Description |
| --- | --- |
| `lib/` | Flutter app: connection handling, device list, chat view, LED / battery widgets |
| `FS9RVMZIQV7K9Q5.ino` | Arduino sketch that reads commands over serial and drives the motors with PWM |
| `android/` | Android host project |

## Getting started

**Requirements:** Flutter SDK, an Android phone, an Arduino with a Bluetooth serial module and a motor driver.

```bash
git clone https://github.com/mh-masum6875/BluetoothController.git
cd BluetoothController
flutter pub get
flutter run
```

1. Upload `FS9RVMZIQV7K9Q5.ino` to the Arduino. The motor pins are set at the top of the sketch.
2. Pair the Bluetooth module with the phone in Android settings.
3. Open the app, pick the paired device, and send commands.

## Tech

Flutter, Dart, [`flutter_bluetooth_serial`](https://pub.dev/packages/flutter_bluetooth_serial), Arduino C++.

## Credits

Built from an open-source Flutter Bluetooth template and adapted for Arduino robot control.
