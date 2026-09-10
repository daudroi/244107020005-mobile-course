# Academic Overview

A responsive Flutter dashboard for the Week 2 declarative UI task.

## Features

- Student profile header for Alex Morgan
- Assignments, attendance, portfolio, and current week cards
- Semester progress and upcoming deadline panels
- Light and dark themes with `CupertinoSwitch`
- Screen-reader labels using `Semantics`
- Responsive one-column and multi-column layouts

The named breakpoint is `kWideBreakpoint = 700`. Narrow screens stack content vertically; wide screens use `Row` and `Expanded` for balanced columns.

## Run and verify

```powershell
cd prak_week2
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

The widget tests cover narrow and wide layouts, theme switching, and accessibility labels. Windows desktop builds additionally require Visual Studio with `Desktop development with C++`.
