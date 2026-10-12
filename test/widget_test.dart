import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codealpha_flashcard_quiz_app/models/flashcard.dart';
import 'package:codealpha_flashcard_quiz_app/screens/manage_cards_screen.dart';
import 'package:codealpha_flashcard_quiz_app/screens/splash_screen.dart';
import 'package:codealpha_flashcard_quiz_app/screens/study_quiz_screen.dart';
import 'package:codealpha_flashcard_quiz_app/services/flashcard_service.dart';
import 'package:codealpha_flashcard_quiz_app/widgets/flashcard_view.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('FlashcardView displays question on front and flips to show answer', (WidgetTester tester) async {
    bool isFlipped = false;
    final testCard = Flashcard(
      id: '1',
      question: 'What is the speed of light?',
      answer: '299,792,458 m/s',
      category: 'Science & Biology',
      difficulty: CardDifficulty.easy,
      hint: 'Symbol c in physics',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return FlashcardView(
                card: testCard,
                isFlipped: isFlipped,
                onFlip: () {
                  setState(() {
                    isFlipped = !isFlipped;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial state: Front of card
    expect(find.text('What is the speed of light?'), findsOneWidget);
    expect(find.text('Show Answer'), findsOneWidget);

    // Tap Show Answer
    await tester.tap(find.text('Show Answer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Flipped state: Answer visible
    expect(find.text('299,792,458 m/s'), findsOneWidget);
    expect(find.text('Hide Answer'), findsOneWidget);
  });

  testWidgets('StudyQuizScreen renders flashcard and navigates next/previous', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();

    await tester.pumpWidget(
      MaterialApp(
        home: StudyQuizScreen(flashcardService: flashcardService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // Verify study mode elements
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('Show Answer'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);

    // Tap Next
    await tester.tap(find.text('Next'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Card 2 of 50'), findsOneWidget);

    // Tap Previous
    await tester.tap(find.text('Previous'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Card 1 of 50'), findsOneWidget);
  });

  testWidgets('ManageCardsScreen lists cards and filters with search', (WidgetTester tester) async {
    final flashcardService = FlashcardService();
    await flashcardService.init();

    await tester.pumpWidget(
      MaterialApp(
        home: ManageCardsScreen(flashcardService: flashcardService),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Manage Flashcards'), findsOneWidget);
    expect(find.text('Add Flashcard'), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'speed of light');
    await tester.pump(const Duration(milliseconds: 400));

    // Should find the speed of light card
    expect(find.text('What is the speed of light in a vacuum?'), findsOneWidget);
  });

  testWidgets('SplashScreen displays mascot, Recallio title, tagline, and calls onComplete', (WidgetTester tester) async {
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          onComplete: () {
            completed = true;
          },
        ),
      ),
    );

    // Initial check: Mascot, app name, and tagline are visible
    expect(find.text('Recallio'), findsOneWidget);
    expect(find.text('Study Smart. Recall Better.'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Advance time past the 2.8s splash duration
    await tester.pump(const Duration(milliseconds: 3000));
    expect(completed, isTrue);
  });
}

