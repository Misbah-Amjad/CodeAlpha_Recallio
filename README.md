# Recallio 🧠✨ — Flashcard Quiz App

<p align="center">
  <img src="assets/images/brain_mascot.png" width="140" alt="Recallio Brain Mascot"/>
</p>

<h3 align="center">Study Smart. Recall Better.</h3>

<p align="center">
  An interactive Flutter flashcard application designed to make studying more engaging through flashcards, self-assessment quizzes, personalized study goals, and learning analytics.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart"/>
  <img src="https://img.shields.io/badge/Material-3-6750A4" alt="Material 3"/>
  <img src="https://img.shields.io/badge/Tests-17%20Passing-success" alt="Tests"/>
  <img src="https://img.shields.io/badge/CodeAlpha-Internship-blueviolet" alt="CodeAlpha Internship"/>
</p>

<p align="center">
  <a href="#-screenshots">Screenshots</a> •
  <a href="#-features">Features</a> •
  <a href="#-tech-stack">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a>
</p>

---

## 📌 About the Project

**Recallio** is a modern flashcard and quiz application developed as **Task 1 — Flashcard Quiz App** during my **CodeAlpha App Development Internship**.

The app provides an organized learning experience where users can create and manage flashcards, test their knowledge, track their progress, and personalize their study goals through a clean and intuitive interface.

Beyond the core internship requirements, I extended the application with interactive quiz sessions, animated flashcards, learner profiles, progress analytics, and persistent local storage.

### 🎯 Internship Task Requirements

| Requirement | Implementation | Status |
|---|---|---|
| Question and answer flashcards | Interactive double-sided cards | ✅ Complete |
| Show Answer functionality | Animated card flip and answer reveal | ✅ Complete |
| Next and Previous navigation | Navigation buttons and swipe gestures | ✅ Complete |
| Add, Edit, and Delete cards | Flashcard management with CRUD operations | ✅ Complete |
| Clean and intuitive interface | Material 3 design with light and dark themes | ✅ Complete |
| Additional functionality | Quiz mode, profiles, goals, and analytics | ⭐ Bonus |

## 📱 Screenshots

Explore Recallio's interface and core learning workflows.

### 🚀 Launch Experience

<p align="center">
  <img src="screenshots/flutter%20launch%20screen.jpeg" alt="Recallio Flutter Launch Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/splash%20screen.jpeg" alt="Recallio Splash Screen" width="180"/>
</p>

### 🃏 Flashcard Study Mode

<p align="center">
  <img src="screenshots/study%20screen.jpeg" alt="Recallio Study Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/show%20answer%20screen.jpeg" alt="Recallio Show Answer Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/hint%20screen.jpeg" alt="Recallio Hint Screen" width="180"/>
</p>

### ✏️ Flashcard Management

<p align="center">
  <img src="screenshots/Add%20flashcard%20screen.jpeg" alt="Recallio Add Flashcard Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/Manage%20card%20screen.jpeg" alt="Recallio Manage Cards Screen" width="180"/>
</p>

### 🎯 Quiz and Learning Analytics

<p align="center">
  <img src="screenshots/quiz%20screen.jpeg" alt="Recallio Quiz Screen" width="180"/>
  &nbsp;&nbsp;
  <img src="screenshots/Analytics%20screen.jpeg" alt="Recallio Analytics Screen" width="180"/>
</p>

### 👤 Personalized Learning

<p align="center">
  <img src="screenshots/edit%20profile%20screen.jpeg" alt="Recallio Edit Profile Screen" width="180"/>
</p>

---

## ✨ Features

### 🧠 Interactive Flashcard Study Experience
- Animated 3D card flips to reveal questions and answers.
- Contextual hints to support recall.
- Previous and Next navigation with swipe gestures.
- Category and difficulty labels.
- Favorites for quick access to important cards.

### 📝 Flashcard Management
- Create, edit, and delete flashcards.
- Add questions, answers, categories, difficulty levels, and optional hints.
- Search cards by keywords.
- Filter cards by category and favorites.
- Undo support for deleted cards.

### 🎯 Interactive Quiz Mode
- Evaluate your own answers during study sessions.
- Track quiz accuracy and review progress.
- Celebrate completed sessions with confetti animations.
- Review missed cards and retry a session.

### 📊 Learning Analytics and Progress
- View quiz accuracy and review statistics.
- Track mastered cards and total flashcards.
- Explore category-wise learning progress.
- Monitor daily study targets and streaks.
- Earn progress-based learner ranks.

### 👤 Personalized Learner Profile
- Customize your display name, study title, and avatar.
- Set a daily study goal.
- Track progress toward your learning target.
- View your current rank and study streak.

### 🎨 Modern UI and Custom Branding
- Material 3 interface with a consistent visual style.
- Light and dark themes.
- Custom Recallio mascot and app icon.
- Animated splash screen and native Android launch experience.
- Responsive layouts for supported screen sizes.

### 💾 Local Data Persistence
- Save flashcards, favorites, profile settings, and theme preferences locally.
- Start with a collection of 50 sample flashcards across five categories.
- Restore the default starter collection when needed.

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application logic and data models |
| Material 3 | UI components and visual design |
| ChangeNotifier | Reactive state updates |
| SharedPreferences | Local persistence |
| UUID | Unique flashcard identifiers |
| Google Fonts | Custom typography |
| Confetti | Quiz completion celebrations |
| Flutter Test | Unit and widget testing |

---

## 🏗️ Project Structure

```text
lib/
├── models/
│   ├── deck_category.dart
│   ├── flashcard.dart
│   └── user_profile.dart
├── screens/
│   ├── manage_cards_screen.dart
│   ├── splash_screen.dart
│   ├── stats_screen.dart
│   └── study_quiz_screen.dart
├── services/
│   ├── flashcard_service.dart
│   ├── theme_service.dart
│   └── user_profile_service.dart
├── widgets/
│   ├── add_edit_card_dialog.dart
│   ├── deck_selector_bar.dart
│   ├── edit_profile_dialog.dart
│   ├── flashcard_view.dart
│   └── quiz_completion_dialog.dart
└── main.dart

assets/
└── images/
    └── brain_mascot.png

screenshots/
test/
pubspec.yaml
```

The project separates data models, screens, reusable widgets, and local persistence services to keep the codebase organized and easier to maintain.

---

## 🧪 Testing

Recallio includes automated unit and widget tests for key application functionality.

Run the test suite using:

```bash
flutter test
```

The reported test suite contains **17 tests**, covering areas such as:

- Flashcard creation, editing, deletion, and favorites.
- Category filtering and progress tracking.
- User profile settings and rank calculations.
- Flashcard rendering and flip interactions.
- Study navigation and search.
- Splash screen and profile editing workflows.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed and configured.
- Dart SDK compatible with your Flutter installation.
- VS Code with the Flutter extension, or another supported Flutter IDE.
- An Android device or emulator for running the Android application.

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/Misbah-Amjad/CodeAlpha_Recallio.git
```

**2. Open the project directory**

```bash
cd CodeAlpha_Recallio
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Run the automated tests**

```bash
flutter test
```

**5. Launch the application**

Connect an Android device or start an emulator, then run:

```bash
flutter run
```

To run the app in Chrome, if your project has web support enabled:

```bash
flutter run -d chrome
```

---

## 🎓 Internship Information

- **Organization:** CodeAlpha
- **Internship:** App Development Internship
- **Task:** Task 1 — Flashcard Quiz App
- **Project:** Recallio
- **Framework:** Flutter
- **Project Type:** Mobile application development

This project helped me practice Flutter UI development, state management, local data persistence, reusable widgets, animations, application structure, and automated testing.

---

## 👩‍💻 Developer

**Misbah Amjad**  
Flutter Developer | BS Information Technology Graduate

- **GitHub:** [Misbah-Amjad](https://github.com/Misbah-Amjad)
- **LinkedIn:** [Connect with me](https://www.linkedin.com/in/misbahh-amjad/)

I'm interested in building clean, user-friendly Flutter applications and continuing to grow as a mobile app developer.

---

<p align="center">
  <strong>Recallio — Study Smart. Recall Better. 🧠</strong>
  <br/>
  Built with ❤️ using Flutter as part of my CodeAlpha internship.
</p>
