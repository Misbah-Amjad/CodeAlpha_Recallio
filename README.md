# Recallio 🧠✨ — Flashcard Quiz App

<p align="center">
  <img src="assets/images/brain_mascot.png" width="160" alt="Recallio Brain Mascot">
</p>

<p align="center">
  <strong>Study Smart. Recall Better.</strong><br>
  A modern, interactive, and beautifully designed flashcard quiz application built with Flutter.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4CAF50" alt="Platforms">
  <img src="https://img.shields.io/badge/Tests-17%20Passed-success" alt="Tests">
  <img src="https://img.shields.io/badge/CodeAlpha-Task%201-blueviolet" alt="CodeAlpha">
</p>

---

## 📌 Project Overview

**Recallio** was developed as **Task 1: Flashcard Quiz App** for the **CodeAlpha App Development Internship**.

Designed around cognitive retention principles and spaced repetition, Recallio provides a clean, distraction-free environment for students, self-learners, and professionals to master concepts, test their knowledge, track their progress, and personalize their study journey.

### 🎯 Internship Task Requirements Checklist

| Requirement | Implementation in Recallio | Status |
|---|---|:---:|
| **Question on front, Answer on back** | 3D Matrix flip card animation with instant toggle | ✅ Completed |
| **"Show Answer" button** | Dynamic Show / Hide Answer button + full card flip | ✅ Completed |
| **Next & Previous navigation** | Dedicated responsive navigation buttons & swipe gestures | ✅ Completed |
| **Add, Edit, and Delete flashcards** | Full CRUD modal bottom sheet with category & difficulty tags | ✅ Completed |
| **Simple, clean, and intuitive UI** | Modern Material 3 UI, custom mascot, dark/light themes | ✅ Completed |
| **Extra: Interactive Quiz Mode** | Self-scoring quiz session with live accuracy & confetti | 🌟 Bonus |
| **Extra: Learner Profile & Goals** | Customizable profile, avatar picker, and daily study target | 🌟 Bonus |
| **Extra: Analytics Dashboard** | Mastery breakdown, category distribution, and level ranks | 🌟 Bonus |

---

## 📱 App Screenshots

Explore **Recallio — Study smarter, recall better**, a Flutter flashcard quiz app developed as part of my **CodeAlpha Mobile App Development Internship**.

### 🚀 Launch & Getting Started

<p align="center">
  <img src="screenshots/flutter%20launch%20screen.jpeg" alt="Recallio Flutter Launch Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/splash%20screen.jpeg" alt="Recallio Splash Screen" width="180"/>
</p>

### 🃏 Flashcard Study Experience

<p align="center">
  <img src="screenshots/study%20screen.jpeg" alt="Recallio Study Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/show%20answer%20screen.jpeg" alt="Recallio Show Answer Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/hint%20screen.jpeg" alt="Recallio Hint Screen" width="180"/>
</p>

### 📝 Flashcard Management

<p align="center">
  <img src="screenshots/Add%20flashcard%20screen.jpeg" alt="Recallio Add Flashcard Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/Manage%20card%20screen.jpeg" alt="Recallio Manage Cards Screen" width="180"/>
</p>

### 🎯 Quiz & Progress Tracking

<p align="center">
  <img src="screenshots/quiz%20screen.jpeg" alt="Recallio Quiz Screen" width="180"/>
  &nbsp;&nbsp;
<img src="screenshots/analytics.jpeg" alt="Recallio Analytics Screen" width="180"/></p>

### 👤 Personalization

<p align="center">
  <img src="screenshots/edit%20profile%20screen.jpeg" alt="Recallio Edit Profile Screen" width="180"/>
</p>

---

*Recallio — Study smarter, recall better.*

---

## 🚀 Key Features & Detailed Breakdown

### 1. 🧠 Custom Mascot & Polished Launch Experience
- **Cold-Boot Native Splash**: Completely custom Android launch screen (`launch_background.xml` & Android 12+ `values-v31/styles.xml`) featuring the white background and centered mascot.
- **Adaptive App Icons**: Multi-density launcher icons (`mdpi` through `xxxhdpi`) featuring Recallio's signature pink brain mascot lifting a barbell.
- **Interactive Animated Splash Screen**:
  - Smooth staggered entrance: soft radial teal glow, floating pastel decorative dots, and elastic bounce scale animation for the mascot.
  - Bold **Recallio** branding with tagline: *"Study Smart. Recall Better."*
  - Automatically transitions to the main study deck after 2.8 seconds.

### 2. 📖 3D Flip Card Study Mode
- **Realistic 3D Card Animation**: Built with custom `Matrix4` perspective transforms (550ms ease) allowing a true double-sided card flip.
- **Card Front**: Displays Question, Category pill, Difficulty badge (Easy, Medium, Hard), and Favorite bookmark toggle.
- **Card Back**: Reveals the complete Answer, category context, and an expandable **Hint Drawer** for extra clues.
- **Intuitive Navigation**:
  - Dedicated **"Previous"** and **"Next"** bottom control buttons.
  - Horizontal swipe gestures across cards.
  - Real-time card counter (e.g. `Card 4 of 50`).
- **Deck Selector Bar**: Horizontal scrollable categories with live card count pills:
  - *All Decks*, *Computer Science*, *Science & Biology*, *Languages & Vocab*, *World Capitals*, *History & Trivia*.
- **Smart End-of-Deck Notification**:
  - Non-intrusive floating SnackBar displaying *"Reached the end of this deck!"*.
  - Includes a quick **Restart** action button that auto-dismisses after 3 seconds.

### 3. 🎯 Self-Assessment Quiz Mode & Confetti Celebration
- **Mode Toggle**: Instantly switch between relaxed **Study Mode** and testing **Quiz Mode**.
- **Self-Evaluation**:
  - Flip the card to check the answer, then rate your recall:
    - ❌ **Needs Practice** (marks card for review).
    - ✅ **Got It Right** (increases mastery rating).
- **Celebration Dialog**:
  - Reaching the end triggers a colorful confetti shower (`confetti` package).
  - Shows session score, accuracy percentage, and cards mastered.
  - One-tap option to restart or **Review Missed Cards** exclusively.

### 4. ✏️ Comprehensive Card Management (CRUD)
- **Add New Flashcards**:
  - Modern modal bottom sheet with full form validation.
  - Fields: Question, Answer, Category (presets or custom), Difficulty level, and optional Study Hint.
- **Edit Existing Cards**:
  - Edit any field at any time from both the Study screen popup and the Manage tab.
- **Delete with Undo Safety**:
  - Delete cards with instant undo notification toast.
- **Real-Time Keyword Search**:
  - Instant live filtering across questions, answers, and hints.
- **Filters**:
  - One-tap **Favorites** filter chip.
  - Category selector chips.

### 5. 👤 Learner Profile & Study Targets (Analytics Screen)
- **Profile Header Card**:
  - **Customizable Avatar**: Choose between the cute Recallio Mascot or 7 icon personas (🎓 Scholar, 🚀 Explorer, ⚡ Speed, 🔥 Streak, 💡 Genius, 🏆 Champion, ⭐ Master).
  - **Learner Identity**: Display Name and study focus / title.
  - **Dynamic Rank & Level**: Progression system calculated from total reviews:
    - *Level 1 • Apprentice Mind* (0–9 reviews)
    - *Level 2 • Curious Scholar* (10–29 reviews)
    - *Level 3 • Memory Champion* (30–59 reviews)
    - *Level 4 • Knowledge Master* (60–99 reviews)
    - *Level 5 • Recall Grandmaster* (100+ reviews)
- **Daily Review Target Progress**:
  - Real-time progress bar tracking reviews completed today vs. your daily goal (5, 10, 15, 20, 25, 30 cards/day).
  - Visual goal achievement badge upon hitting daily target.
- **Active Study Streak**: Daily streak tracker (`🔥 Day Streak`) and join date.
- **Interactive Edit Profile Dialog**:
  - Slide-up bottom sheet allowing real-time edits to name, title presets, avatar, and daily goal.

### 6. 📊 Analytics & Visual Insights
- **Hero Mastery Overview Banner**:
  - Quiz Accuracy %, Total Review count, and Mastered Cards count.
- **Quick Metrics Grid**:
  - Total collection size and total bookmarked favorites.
- **Decks Breakdown**:
  - Visual category distribution with colored progress bars matching each deck's identity.

### 7. 🌓 Dark / Light Themes & Settings
- **Theme Mode**: Full dark and light theme support with smooth transition and persistent state.
- **Default Decks Restore**: One-tap reset to restore the 50 starter flashcards (10 per category).

---

## 🏗️ Project Architecture & File Structure

```text
codealpha_flashcard_quiz_app/
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml          # App label "Recallio", back gestures, intent filters
│       └── res/
│           ├── drawable/                # Native launch splash background
│           ├── drawable-v21/            # Android 5.0+ launch background
│           ├── values-v31/              # Android 12+ SplashScreen theme
│           └── mipmap-*/                # Multi-density launcher icons
├── assets/
│   └── images/
│       └── brain_mascot.png             # Official Recallio mascot asset
├── lib/
│   ├── models/
│   │   ├── deck_category.dart           # Deck category definitions, colors & icons
│   │   ├── flashcard.dart               # Flashcard model with serialization & stats
│   │   └── user_profile.dart            # User profile model & rank tier calculations
│   ├── screens/
│   │   ├── manage_cards_screen.dart     # Card management, search, and filter list
│   │   ├── splash_screen.dart           # Animated splash screen with mascot & typography
│   │   ├── stats_screen.dart            # Profile section, analytics dashboard & settings
│   │   └── study_quiz_screen.dart       # Main 3D card study view & quiz mode
│   ├── services/
│   │   ├── flashcard_service.dart       # SharedPreferences CRUD & 50 starter cards
│   │   ├── theme_service.dart           # Persistent light/dark theme provider
│   │   └── user_profile_service.dart    # Persistent user profile & daily goal state
│   ├── widgets/
│   │   ├── add_edit_card_dialog.dart    # Modal bottom sheet for card creation/edit
│   │   ├── deck_selector_bar.dart       # Horizontal scrollable category pills
│   │   ├── edit_profile_dialog.dart     # Modal bottom sheet for profile customization
│   │   ├── flashcard_view.dart          # 3D Matrix flip card widget
│   │   └── quiz_completion_dialog.dart  # Confetti results dialog with retry missed
│   └── main.dart                        # App entry point, ThemeData & bottom navigation
├── screenshots/                         # App showcase images
├── test/
│   ├── flashcard_service_test.dart      # 8 unit tests for FlashcardService
│   ├── user_profile_service_test.dart   # 4 unit tests for UserProfile & ranks
│   └── widget_test.dart                 # 5 widget tests for UI, flips, search & profile
└── pubspec.yaml                         # Dependencies, assets & fonts configuration
```

---

## 🛠️ Tech Stack & Packages

- **Framework**: [Flutter 3.x](https://flutter.dev) (Dart 3.x)
- **UI Architecture**: Material 3 Design with custom typography using `google_fonts` (Plus Jakarta Sans & Nunito)
- **State Management**: `ChangeNotifier` with reactive listeners
- **Local Persistence**: `shared_preferences` for cards, profile, and theme settings
- **ID Generation**: `uuid` for unique card IDs
- **Celebration Effects**: `confetti` for celebratory quiz completion animations
- **Testing**: `flutter_test` suite with complete unit and widget test coverage

---

## 🧪 Automated Test Suite

Recallio includes a robust test suite covering all critical services, widget interactions, 3D card flips, and dialog workflows:

```bash
flutter test
```

### ✅ Test Results (17/17 Passing)
- **`flashcard_service_test.dart`**:
  - Initializes with 50 starter cards (10 per category) on first run
  - Adds new flashcard
  - Updates existing flashcard
  - Deletes flashcard
  - Toggles favorite status
  - Accurately tracks quiz results and accuracy
  - Filters cards by category
  - Resets cards to default collection
- **`user_profile_service_test.dart`**:
  - Initializes with default profile
  - Updates name, title, avatar, and daily study goal
  - Persists profile across instances
  - Correctly calculates level and rank titles
- **`widget_test.dart`**:
  - `FlashcardView` question display and 3D flip animation
  - `StudyQuizScreen` card navigation (Next / Previous)
  - `ManageCardsScreen` live keyword search and filtering
  - `SplashScreen` mascot, typography, and timed callback
  - `StatsScreen` Profile section rendering and interactive profile editing

---

## ⚡ Getting Started & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10 or higher)
- Android Studio / VS Code with Flutter extension
- An Android device or emulator (tested on Android 13 / API 33)

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/codealpha_flashcard_quiz_app.git
   cd codealpha_flashcard_quiz_app
   ```

2. **Install project dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run automated tests**:
   ```bash
   flutter test
   ```

4. **Run the application**:
   - For connected Android phone:
     ```bash
     flutter run
     ```
   - For Chrome / Web:
     ```bash
     flutter run -d chrome
     ```

---

## 👨‍💻 Developer & Internship Information

- **Internship**: **CodeAlpha App Development Internship**
- **Task Assigned**: **Task 1 — Flashcard Quiz App**
- **App Name**: **Recallio**
- **Tagline**: *Study Smart. Recall Better.*

---

<p align="center">
  Made with ❤️ and Flutter for <strong>CodeAlpha</strong>.
</p>