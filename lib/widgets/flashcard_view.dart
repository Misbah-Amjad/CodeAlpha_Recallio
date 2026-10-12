import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/deck_category.dart';

class FlashcardView extends StatefulWidget {
  final Flashcard card;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isFlipped;
  final VoidCallback onFlip;

  const FlashcardView({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.onFlip,
    this.onFavoriteToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubicEmphasized),
    );

    if (widget.isFlipped) {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant FlashcardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.card.id != oldWidget.card.id) {
      _showHint = false;
    }
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(CardDifficulty diff) {
    switch (diff) {
      case CardDifficulty.easy:
        return const Color(0xFF10B981);
      case CardDifficulty.medium:
        return const Color(0xFFF59E0B);
      case CardDifficulty.hard:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = DeckCategory.getCategory(widget.card.category);
    final diffColor = _getDifficultyColor(widget.card.difficulty);

    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFront = angle < (math.pi / 2);

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: isFront
                ? _buildCardSide(
                    context: context,
                    isFront: true,
                    category: category,
                    diffColor: diffColor,
                    isDark: isDark,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCardSide(
                      context: context,
                      isFront: false,
                      category: category,
                      diffColor: diffColor,
                      isDark: isDark,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide({
    required BuildContext context,
    required bool isFront,
    required DeckCategory category,
    required Color diffColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final cardBgColor = isDark
        ? const Color(0xFF1E2433)
        : Colors.white;
    final borderColor = isDark
        ? (isFront ? category.primaryColor.withValues(alpha: 0.3) : const Color(0xFF10B981).withValues(alpha: 0.4))
        : (isFront ? category.primaryColor.withValues(alpha: 0.2) : const Color(0xFF10B981).withValues(alpha: 0.3));

    return Container(
      constraints: const BoxConstraints(minHeight: 320),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isFront
                ? category.primaryColor.withValues(alpha: isDark ? 0.18 : 0.12)
                : const Color(0xFF10B981).withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Decorative background pattern glow
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isFront ? category.primaryColor : const Color(0xFF10B981))
                      .withValues(alpha: isDark ? 0.12 : 0.07),
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isFront ? category.secondaryColor : const Color(0xFF059669))
                      .withValues(alpha: isDark ? 0.08 : 0.05),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Header with Category, Difficulty & Action Icons
                  _buildHeader(
                    context: context,
                    isFront: isFront,
                    category: category,
                    diffColor: diffColor,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 22),

                  // Middle Content (Question or Answer)
                  Center(
                    child: isFront
                        ? _buildQuestionContent(theme, isDark)
                        : _buildAnswerContent(theme, isDark),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Action Button / Prompt
                  _buildBottomButton(
                    context: context,
                    isFront: isFront,
                    category: category,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required bool isFront,
    required DeckCategory category,
    required Color diffColor,
    required bool isDark,
  }) {
    return Row(
      children: [
        // Category Pill
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  category.primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  category.secondaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: category.primaryColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 13,
                  color: category.primaryColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    widget.card.category,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : category.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 6),

        // Difficulty Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: diffColor.withValues(alpha: 0.4)),
          ),
          child: Text(
            widget.card.difficulty.name.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: diffColor,
              letterSpacing: 0.4,
            ),
          ),
        ),

        const SizedBox(width: 6),

        // Favorite Heart Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onFavoriteToggle,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  widget.card.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey<bool>(widget.card.isFavorite),
                  color: widget.card.isFavorite
                      ? const Color(0xFFEF4444)
                      : (isDark ? Colors.white38 : Colors.black38),
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // More options (Edit / Delete)
        if (widget.onEdit != null || widget.onDelete != null)
          PopupMenuButton<String>(
            tooltip: 'Card Options',
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? Colors.white54 : Colors.black45,
              size: 18,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'edit' && widget.onEdit != null) {
                widget.onEdit!();
              } else if (value == 'delete' && widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            itemBuilder: (context) => [
              if (widget.onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6366F1)),
                      SizedBox(width: 10),
                      Text('Edit Card'),
                    ],
                  ),
                ),
              if (widget.onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                      SizedBox(width: 10),
                      Text('Delete Card', style: TextStyle(color: Color(0xFFEF4444))),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuestionContent(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Question Label Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'QUESTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // The Question Text
        Text(
          widget.card.question,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.4,
            fontSize: 18,
            color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
          ),
        ),

        if (widget.card.hint != null && widget.card.hint!.isNotEmpty) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _showHint = !_showHint;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _showHint
                    ? const Color(0xFFFEF3C7).withValues(alpha: isDark ? 0.15 : 0.7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showHint ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      _showHint ? 'Hint: ${widget.card.hint}' : 'Need a hint?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _showHint
                            ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309))
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerContent(ThemeData theme, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Answer Label Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 6),
              Text(
                'ANSWER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // The Answer Text
        Text(
          widget.card.answer,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.45,
            fontSize: 16,
            color: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton({
    required BuildContext context,
    required bool isFront,
    required DeckCategory category,
    required bool isDark,
  }) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: widget.onFlip,
        style: ElevatedButton.styleFrom(
          backgroundColor: isFront
              ? category.primaryColor
              : const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: (isFront ? category.primaryColor : const Color(0xFF10B981)).withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          isFront ? Icons.visibility_rounded : Icons.flip_to_front_rounded,
          size: 16,
        ),
        label: Text(
          isFront ? 'Show Answer' : 'Hide Answer',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
