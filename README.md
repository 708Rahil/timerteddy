# Timer Teddy 🧸
A friendly iOS productivity timer app built with SwiftUI, MVVM, and local persistence.

---

## Project Structure

```
TimerTeddy/
├── TimerTeddyApp.swift       — @main app entry, injects SessionStore
├── ContentView.swift         — Root view (hosts HomeView)
├── HomeView.swift            — Activity selection grid + navigation
├── TimerView.swift           — Timer screen with countdown + controls
├── DashboardView.swift       — Analytics: time totals, activity breakdown, recent sessions
├── DailyGoalView.swift       — Set & track daily focus goal with progress ring
├── TimerViewModel.swift      — Timer logic (Combine), notifications (UNUserNotificationCenter)
├── Session.swift             — Session data model (Codable)
├── SessionStore.swift        — ObservableObject persistence layer (UserDefaults + JSON)
├── ActivityType.swift        — Enum: study / work / sleep / fun / custom
├── TeddyLevel.swift          — Gamification levels (Baby → Master Teddy)
└── ColorExtensions.swift     — Hex color init + design tokens
```

---

## Setup in Xcode

### 1. Create a new Xcode project
- Open Xcode → **File → New → Project**
- Choose **iOS → App**
- Product Name: `TimerTeddy`
- Interface: **SwiftUI**
- Language: **Swift**
- Minimum deployment: **iOS 17.0**
- **Uncheck** SwiftData / CoreData (this app uses UserDefaults)

### 2. Add the Swift files
Copy all `.swift` files from this folder into your Xcode project, replacing the default `ContentView.swift`.

### 3. Add Teddy Bear Image Assets
In `Assets.xcassets`, add image sets with these exact names:
| Image Name       | Used For          |
|------------------|-------------------|
| `teddy_reading`  | Study activity    |
| `teddy_laptop`   | Work activity     |
| `teddy_sleeping` | Sleep activity    |
| `teddy_playing`  | Fun activity      |
| `teddy_default`  | Custom activity   |

> **Tip**: The app gracefully falls back to emoji if images are missing, so it works without assets too.

### 4. Add Notification Permission to Info.plist
Add the following key to `Info.plist`:
```xml
<key>NSUserNotificationUsageDescription</key>
<string>Timer Teddy notifies you when your session finishes.</string>
```

### 5. Build & Run
Select a simulator running iOS 17+ and hit ▶ Run.

---

## Architecture

```
View Layer          ViewModel              Store / Model
─────────────       ──────────             ─────────────
HomeView            TimerViewModel         SessionStore (ObservableObject)
TimerView      ───► (countdown logic,  ──► Session (Codable)
DashboardView       notifications)         ActivityType (enum)
DailyGoalView                              TeddyLevel (enum)
```

- **MVVM**: Views observe `TimerViewModel` and `SessionStore` via `@StateObject` / `@EnvironmentObject`.
- **Persistence**: `SessionStore` encodes `[Session]` to JSON and writes to `UserDefaults`. No backend required.
- **Timer**: Uses `Combine`'s `Timer.publish` for 1-second ticks; cancellable on pause/reset/end.
- **Notifications**: `UNUserNotificationCenter` schedules a local notification when timer starts; cancelled on pause/reset.

---

## Features

| Feature                | Details                                             |
|------------------------|-----------------------------------------------------|
| 5 Activities           | Study, Work, Sleep, Fun, Custom — each with colors |
| Duration Picker        | Hours + minutes wheel picker before starting       |
| Circular Countdown     | Animated progress ring with MM:SS display          |
| Pause / Reset / End    | Full timer control; partial sessions saved on End  |
| Session Persistence    | All completed sessions saved locally               |
| Dashboard              | Today/week totals, per-activity bars, recent list  |
| Daily Goal             | Set goal, track progress ring, "Teddy is proud" 🎉 |
| Teddy Evolution        | 4 levels based on total accumulated hours          |
| Local Notifications    | Fires when countdown reaches zero                  |
| SwiftUI Previews       | All views have `#Preview` blocks                   |

---

## Teddy Levels

| Level         | Badge | Hours Required |
|---------------|-------|----------------|
| Baby Teddy    | 🐣    | 0 – 5 hrs      |
| Student Teddy | 🎒    | 5 – 20 hrs     |
| Focus Teddy   | 🔥    | 20 – 50 hrs    |
| Master Teddy  | 🏆    | 50+ hrs        |
