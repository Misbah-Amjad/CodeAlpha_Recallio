import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/deck_category.dart';
import '../services/flashcard_service.dart';
import '../widgets/add_edit_card_dialog.dart';

class ManageCardsScreen extends StatefulWidget {
  final FlashcardService flashcardService;

  const ManageCardsScreen({
    super.key,
    required this.flashcardService,
  });

  @override
  State<ManageCardsScreen> createState() => _ManageCardsScreenState();
}

class _ManageCardsScreenState extends State<ManageCardsScreen> {
  String _searchQuery = '';
  String _filterCategory = 'All';
  bool _onlyFavorites = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Flashcard> _getFilteredCards() {
    return widget.flashcardService.cards.where((card) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          card.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          card.category.toLowerCase().contains(_searchQuery.toLowerCase());

      // Category filter
      final matchesCat = _filterCategory == 'All' ||
          card.category.toLowerCase() == _filterCategory.toLowerCase();

      // Favorite filter
      final matchesFav = !_onlyFavorites || card.isFavorite;

      return matchesSearch && matchesCat && matchesFav;
    }).toList();
  }

  void _openAddCardDialog() {
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
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flashcard added! ✨'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
  }

  void _openEditCardDialog(Flashcard card) {
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
        setState(() {});
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

  void _deleteCard(Flashcard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Flashcard?'),
        content: Text('Are you sure you want to delete "${card.question}"?'),
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
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Flashcard deleted'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.amber,
                    onPressed: () {
                      widget.flashcardService.addCard(
                        question: card.question,
                        answer: card.answer,
                        category: card.category,
                        difficulty: card.difficulty,
                        hint: card.hint,
                      );
                      setState(() {});
                    },
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredCards = _getFilteredCards();
    final categories = ['All', ...widget.flashcardService.categories.where((c) => c != 'All Decks')];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Manage Flashcards',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More Actions',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'reset') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Reset to Starter Decks?'),
                    content: const Text('This will reset your flashcards to the default starter collection.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          widget.flashcardService.resetToDefaults();
                          setState(() {});
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'clear') {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: const Text('Clear All Cards?'),
                    content: const Text('This will remove all flashcards. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          widget.flashcardService.clearAllCards();
                          setState(() {});
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt_rounded, color: Color(0xFF6366F1), size: 18),
                    SizedBox(width: 8),
                    Text('Reset to Default Cards'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Clear All Cards', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search questions, answers or categories...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),

                const SizedBox(height: 10),

                // Category & Favorites Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // Favorite Filter Chip
                      FilterChip(
                        selected: _onlyFavorites,
                        showCheckmark: false,
                        avatar: Icon(
                          _onlyFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 15,
                          color: const Color(0xFFEF4444),
                        ),
                        label: const Text('Favorites'),
                        selectedColor: const Color(0xFFEF4444).withValues(alpha: 0.18),
                        backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _onlyFavorites
                                ? const Color(0xFFEF4444)
                                : (isDark ? Colors.white10 : Colors.black12),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _onlyFavorites = selected;
                          });
                        },
                      ),

                      const SizedBox(width: 8),

                      // Category Filters
                      ...categories.map((cat) {
                        final isSelected = _filterCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: const Color(0xFF6366F1),
                            backgroundColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF6366F1)
                                    : (isDark ? Colors.white10 : Colors.black12),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _filterCategory = cat;
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cards Count & Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredCards.length} ${filteredCards.length == 1 ? 'card' : 'cards'}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                Text(
                  'Total in Deck: ${widget.flashcardService.cards.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Flashcard Items List
          Expanded(
            child: filteredCards.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                    itemCount: filteredCards.length,
                    itemBuilder: (context, index) {
                      final card = filteredCards[index];
                      final category = DeckCategory.getCategory(card.category);
                      final diffColor = _getDifficultyColor(card.difficulty);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2433) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row with Category, Difficulty, Favorite & Actions
                              Row(
                                children: [
                                  // Flexible Category Tag
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: category.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(category.icon, size: 12, color: category.primaryColor),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              card.category,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: category.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // Difficulty Tag
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha: isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      card.difficulty.name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: diffColor,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  // Favorite Button
                                  InkWell(
                                    onTap: () {
                                      widget.flashcardService.toggleFavorite(card.id);
                                      setState(() {});
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Icon(
                                        card.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        size: 18,
                                        color: card.isFavorite ? const Color(0xFFEF4444) : Colors.grey,
                                      ),
                                    ),
                                  ),

                                  // Edit Button
                                  InkWell(
                                    onTap: () => _openEditCardDialog(card),
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.edit_outlined, size: 18, color: Color(0xFF6366F1)),
                                    ),
                                  ),

                                  // Delete Button
                                  InkWell(
                                    onTap: () => _deleteCard(card),
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Question Title
                              Text(
                                card.question,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Answer Snippet
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF131722) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  card.answer,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                                  ),
                                ),
                              ),

                              if (card.hint != null && card.hint!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Hint: ${card.hint}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCardDialog,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Flashcard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 14),
            Text(
              'No Flashcards Found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing your search query or filter options.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
