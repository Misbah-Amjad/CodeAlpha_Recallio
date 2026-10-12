import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/flashcard_service.dart';
import '../widgets/flashcard_view.dart';
import '../widgets/deck_selector_bar.dart';
import '../widgets/add_edit_card_dialog.dart';
import '../widgets/quiz_completion_dialog.dart';

class StudyQuizScreen extends StatefulWidget {
  final FlashcardService flashcardService;
  final VoidCallback? onNavigateToManage;

  const StudyQuizScreen({
    super.key,
    required this.flashcardService,
    this.onNavigateToManage,
  });

  @override
  State<StudyQuizScreen> createState() => _StudyQuizScreenState();
}

class _StudyQuizScreenState extends State<StudyQuizScreen> {
  String _selectedCategory = 'All Decks';
  int _currentIndex = 0;
  bool _isCardFlipped = false;
  bool _isQuizMode = false;

  // Quiz Mode Tracking
  final Set<String> _correctCardIds = {};
  final Set<String> _incorrectCardIds = {};

  List<Flashcard> _workingCards = [];

  @override
  void initState() {
    super.initState();
    _refreshWorkingCards();
  }

  void _refreshWorkingCards() {
    final list = widget.flashcardService.getCardsByCategory(_selectedCategory);
    setState(() {
      _workingCards = List.from(list);
      _currentIndex = 0;
      _isCardFlipped = false;
      _correctCardIds.clear();
      _incorrectCardIds.clear();
    });
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _refreshWorkingCards();
    });
  }

  void _nextCard() {
    if (_workingCards.isEmpty) return;
    if (_currentIndex < _workingCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isCardFlipped = false;
      });
    } else {
      // Reached the end of the deck
      if (_isQuizMode) {
        _showQuizResults();
      } else {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Reached the end of this deck!'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: 'Restart',
              textColor: Colors.amber,
              onPressed: _restartDeck,
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          messenger.hideCurrentSnackBar();
        });
      }
    }
  }

  void _previousCard() {
    if (_workingCards.isEmpty) return;
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isCardFlipped = false;
      });
    }
  }

  void _shuffleDeck() {
    if (_workingCards.isEmpty) return;
    setState(() {
      _workingCards.shuffle();
      _currentIndex = 0;
      _isCardFlipped = false;
      _correctCardIds.clear();
      _incorrectCardIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shuffle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Deck shuffled!'),
          ],
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _restartDeck() {
    setState(() {
      _currentIndex = 0;
      _isCardFlipped = false;
      _correctCardIds.clear();
      _incorrectCardIds.clear();
    });
  }

  void _answerCard(bool isCorrect) {
    if (_workingCards.isEmpty) return;
    final card = _workingCards[_currentIndex];

    if (isCorrect) {
      _correctCardIds.add(card.id);
      _incorrectCardIds.remove(card.id);
    } else {
      _incorrectCardIds.add(card.id);
      _correctCardIds.remove(card.id);
    }

    widget.flashcardService.recordCardResult(card.id, isCorrect);

    if (_currentIndex < _workingCards.length - 1) {
      setState(() {
        _currentIndex++;
        _isCardFlipped = false;
      });
    } else {
      _showQuizResults();
    }
  }

  void _showQuizResults() {
    QuizCompletionDialog.show(
      context: context,
      totalCards: _workingCards.length,
      correctCount: _correctCardIds.length,
      incorrectCount: _incorrectCardIds.length,
      onRestart: _restartDeck,
      onReviewIncorrect: _incorrectCardIds.isNotEmpty
          ? () {
              final missed = _workingCards.where((c) => _incorrectCardIds.contains(c.id)).toList();
              setState(() {
                _workingCards = List.from(missed);
                _currentIndex = 0;
                _isCardFlipped = false;
                _correctCardIds.clear();
                _incorrectCardIds.clear();
              });
            }
          : null,
    );
  }

  void _addNewCard() {
    AddEditCardDialog.show(
      context: context,
      existingCategories: widget.flashcardService.categories,
      onSave: (question, answer, category, difficulty, hint) {
        widget.flashcardService.addCard(
          question: question,
          answer: answer,
          category: category,
          difficulty: difficulty,
          hint: hint,
        );
        _refreshWorkingCards();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flashcard added successfully! ✨'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  void _editCurrentCard(Flashcard card) {
    AddEditCardDialog.show(
      context: context,
      card: card,
      existingCategories: widget.flashcardService.categories,
      onSave: (question, answer, category, difficulty, hint) {
        widget.flashcardService.updateCard(
          card.copyWith(
            question: question,
            answer: answer,
            category: category,
            difficulty: difficulty,
            hint: hint,
          ),
        );
        _refreshWorkingCards();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flashcard updated! ✨'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  void _deleteCurrentCard(Flashcard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Flashcard?'),
        content: const Text('Are you sure you want to delete this card? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.flashcardService.deleteCard(card.id);
              _refreshWorkingCards();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Flashcard deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _workingCards.length;
    final currentCard = total > 0 && _currentIndex < total ? _workingCards[_currentIndex] : null;
    final progress = total == 0 ? 0.0 : (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Top Bar with Deck Categories Filter
            DeckSelectorBar(
              selectedCategory: _selectedCategory,
              onCategorySelected: _onCategorySelected,
              flashcardService: widget.flashcardService,
            ),

            const SizedBox(height: 10),

            // Progress Header and Mode Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Mode Toggle (Study vs. Quiz Mode)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2433) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeTab(
                          label: 'Study',
                          icon: Icons.menu_book_rounded,
                          isSelected: !_isQuizMode,
                          onTap: () {
                            setState(() {
                              _isQuizMode = false;
                            });
                          },
                          isDark: isDark,
                        ),
                        _buildModeTab(
                          label: 'Quiz',
                          icon: Icons.quiz_rounded,
                          isSelected: _isQuizMode,
                          onTap: () {
                            setState(() {
                              _isQuizMode = true;
                              _correctCardIds.clear();
                              _incorrectCardIds.clear();
                            });
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Quick Action Buttons (Shuffle, Restart, Add Card)
                  IconButton(
                    tooltip: 'Shuffle Cards',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.shuffle_rounded, size: 18),
                    onPressed: total > 1 ? _shuffleDeck : null,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Restart Deck',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    onPressed: total > 0 ? _restartDeck : null,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Add New Card',
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.add_rounded, color: Color(0xFF6366F1), size: 20),
                    onPressed: _addNewCard,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Progress Bar Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        total == 0 ? '0 cards' : 'Card ${_currentIndex + 1} of $total',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% Completed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDark ? const Color(0xFF1E2433) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Main Flashcard Interactive Area (Supports Swipe Gestures)
            Expanded(
              child: currentCard == null
                  ? _buildEmptyState(context, isDark)
                  : GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -200) {
                            // Swiped Left -> Next Card
                            _nextCard();
                          } else if (details.primaryVelocity! > 200) {
                            // Swiped Right -> Previous Card
                            _previousCard();
                          }
                        }
                      },
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: FlashcardView(
                            key: ValueKey(currentCard.id),
                            card: currentCard,
                            isFlipped: _isCardFlipped,
                            onFlip: () {
                              setState(() {
                                _isCardFlipped = !_isCardFlipped;
                              });
                            },
                            onFavoriteToggle: () {
                              widget.flashcardService.toggleFavorite(currentCard.id);
                              _refreshWorkingCards();
                            },
                            onEdit: () => _editCurrentCard(currentCard),
                            onDelete: () => _deleteCurrentCard(currentCard),
                          ),
                        ),
                      ),
                    ),
            ),

            // Bottom Navigation & Control Action Bar
            if (currentCard != null) ...[
              _buildBottomControls(context, isDark, total),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, bool isDark, int total) {
    if (_isQuizMode) {
      // Quiz Mode Controls: Need Review ❌ vs Got It Right ✅
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Need Review Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _answerCard(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF2D1818) : const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFFEF4444)),
                label: const Text(
                  'Need Review',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Got It Right Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _answerCard(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: const Color(0xFF10B981).withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text(
                  'Got It Right',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Standard Study Mode Controls: Previous & Next
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Previous Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _currentIndex > 0 ? _previousCard : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(
                  color: _currentIndex > 0
                      ? (isDark ? Colors.white24 : Colors.grey.shade300)
                      : (isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
              ),
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 16,
                color: _currentIndex > 0
                    ? (isDark ? Colors.white : const Color(0xFF1E293B))
                    : (isDark ? Colors.white24 : Colors.black26),
              ),
              label: Text(
                'Previous',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _currentIndex > 0
                    ? (isDark ? Colors.white : const Color(0xFF1E293B))
                    : (isDark ? Colors.white24 : Colors.black26),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Next Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _nextCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 3,
                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              label: Text(
                _currentIndex == total - 1 ? 'Finish' : 'Next',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              icon: Icon(
                _currentIndex == total - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.style_outlined,
                size: 44,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Flashcards Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategory == 'All Decks'
                  ? 'Get started by creating your very first flashcard!'
                  : 'No flashcards in "$_selectedCategory". Add one below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add First Flashcard',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
