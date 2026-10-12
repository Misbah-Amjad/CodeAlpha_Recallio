import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codealpha_flashcard_quiz_app/models/flashcard.dart';
import 'package:codealpha_flashcard_quiz_app/services/flashcard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlashcardService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default starter cards on first run', () async {
      final service = FlashcardService();
      await service.init();

      expect(service.cards.isNotEmpty, true);
      expect(service.cards.length, greaterThanOrEqualTo(5));
      expect(service.categories.contains('Computer Science'), true);
      expect(service.categories.contains('Science & Biology'), true);
    });

    test('Can add a new flashcard', () async {
      final service = FlashcardService();
      await service.init();
      final initialCount = service.cards.length;

      await service.addCard(
        question: 'What is Dart?',
        answer: 'An OOP, client-optimized language by Google.',
        category: 'Programming',
        difficulty: CardDifficulty.easy,
        hint: 'Used by Flutter',
      );

      expect(service.cards.length, initialCount + 1);
      final newCard = service.cards.first;
      expect(newCard.question, 'What is Dart?');
      expect(newCard.answer, 'An OOP, client-optimized language by Google.');
      expect(newCard.category, 'Programming');
      expect(newCard.hint, 'Used by Flutter');
    });

    test('Can update an existing flashcard', () async {
      final service = FlashcardService();
      await service.init();
      final firstCard = service.cards.first;

      final updated = firstCard.copyWith(question: 'Updated Question?');
      await service.updateCard(updated);

      final found = service.cards.firstWhere((c) => c.id == firstCard.id);
      expect(found.question, 'Updated Question?');
    });

    test('Can delete a flashcard', () async {
      final service = FlashcardService();
      await service.init();
      final firstCard = service.cards.first;
      final initialCount = service.cards.length;

      await service.deleteCard(firstCard.id);

      expect(service.cards.length, initialCount - 1);
      expect(service.cards.any((c) => c.id == firstCard.id), false);
    });

    test('Can toggle favorite status', () async {
      final service = FlashcardService();
      await service.init();
      final firstCard = service.cards.first;
      final initialFav = firstCard.isFavorite;

      await service.toggleFavorite(firstCard.id);
      expect(service.cards.firstWhere((c) => c.id == firstCard.id).isFavorite, !initialFav);

      await service.toggleFavorite(firstCard.id);
      expect(service.cards.firstWhere((c) => c.id == firstCard.id).isFavorite, initialFav);
    });

    test('Correctly tracks quiz results and accuracy', () async {
      final service = FlashcardService();
      await service.init();
      final firstCard = service.cards.first;

      await service.recordCardResult(firstCard.id, true);
      await service.recordCardResult(firstCard.id, true);
      await service.recordCardResult(firstCard.id, false);

      final found = service.cards.firstWhere((c) => c.id == firstCard.id);
      expect(found.timesReviewed, 3);
      expect(found.timesCorrect, 2);
      expect(service.totalReviews, 3);
      expect(service.totalCorrect, 2);
      expect(service.overallAccuracy.toStringAsFixed(1), '66.7');
    });

    test('Can filter cards by category', () async {
      final service = FlashcardService();
      await service.init();

      final csCards = service.getCardsByCategory('Computer Science');
      expect(csCards.every((c) => c.category.toLowerCase() == 'computer science'), true);

      final allCards = service.getCardsByCategory('All Decks');
      expect(allCards.length, service.cards.length);
    });

    test('Can reset cards to defaults', () async {
      final service = FlashcardService();
      await service.init();

      await service.clearAllCards();
      expect(service.cards.isEmpty, true);

      await service.resetToDefaults();
      expect(service.cards.isNotEmpty, true);
    });
  });
}
