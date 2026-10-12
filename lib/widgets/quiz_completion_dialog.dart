import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class QuizCompletionDialog extends StatefulWidget {
  final int totalCards;
  final int correctCount;
  final int incorrectCount;
  final VoidCallback onRestart;
  final VoidCallback? onReviewIncorrect;

  const QuizCompletionDialog({
    super.key,
    required this.totalCards,
    required this.correctCount,
    required this.incorrectCount,
    required this.onRestart,
    this.onReviewIncorrect,
  });

  static Future<void> show({
    required BuildContext context,
    required int totalCards,
    required int correctCount,
    required int incorrectCount,
    required VoidCallback onRestart,
    VoidCallback? onReviewIncorrect,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizCompletionDialog(
        totalCards: totalCards,
        correctCount: correctCount,
        incorrectCount: incorrectCount,
        onRestart: onRestart,
        onReviewIncorrect: onReviewIncorrect,
      ),
    );
  }

  @override
  State<QuizCompletionDialog> createState() => _QuizCompletionDialogState();
}

class _QuizCompletionDialogState extends State<QuizCompletionDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    final percentage = widget.totalCards == 0 ? 0 : (widget.correctCount / widget.totalCards) * 100;
    if (percentage >= 60) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = widget.totalCards == 0 ? 0 : ((widget.correctCount / widget.totalCards) * 100).round();

    String title;
    String subtitle;
    IconData headerIcon;
    Color headerColor;

    if (percentage >= 90) {
      title = 'Mastery Achieved! 🏆';
      subtitle = 'Incredible job! You have conquered this deck.';
      headerIcon = Icons.military_tech_rounded;
      headerColor = const Color(0xFF10B981);
    } else if (percentage >= 70) {
      title = 'Great Performance! ⭐';
      subtitle = 'You have a solid understanding of these cards.';
      headerIcon = Icons.stars_rounded;
      headerColor = const Color(0xFF6366F1);
    } else if (percentage >= 50) {
      title = 'Good Effort! 📚';
      subtitle = 'A bit more practice and you will master it completely.';
      headerIcon = Icons.auto_awesome_rounded;
      headerColor = const Color(0xFFF59E0B);
    } else {
      title = 'Keep Practicing! 💪';
      subtitle = 'Repetition is the key to long-term memory mastery.';
      headerIcon = Icons.psychology_rounded;
      headerColor = const Color(0xFFEC4899);
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon Badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [headerColor, headerColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: headerColor.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(headerIcon, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 18),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),

                // Score Stat Grid
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Score', '$percentage%', headerColor),
                      Container(width: 1, height: 36, color: isDark ? Colors.white12 : Colors.black12),
                      _buildStatColumn('Correct', '${widget.correctCount}', const Color(0xFF10B981)),
                      Container(width: 1, height: 36, color: isDark ? Colors.white12 : Colors.black12),
                      _buildStatColumn('Incorrect', '${widget.incorrectCount}', const Color(0xFFEF4444)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.incorrectCount > 0 && widget.onReviewIncorrect != null) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onReviewIncorrect!();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.replay_rounded, size: 20),
                        label: const Text(
                          'Review Missed Cards Only',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onRestart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: const Text(
                        'Restart Entire Deck',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Back to Overview',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Confetti Emitter
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Color(0xFF6366F1),
            Color(0xFF10B981),
            Color(0xFFF59E0B),
            Color(0xFFEC4899),
            Color(0xFF3B82F6),
          ],
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
