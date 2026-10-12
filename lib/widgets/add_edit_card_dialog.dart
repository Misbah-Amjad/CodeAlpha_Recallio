import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../models/deck_category.dart';

class AddEditCardDialog extends StatefulWidget {
  final Flashcard? initialCard;
  final List<String> existingCategories;
  final Function(String question, String answer, String category, CardDifficulty difficulty, String? hint) onSave;

  const AddEditCardDialog({
    super.key,
    this.initialCard,
    required this.existingCategories,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    Flashcard? card,
    required List<String> existingCategories,
    required Function(String question, String answer, String category, CardDifficulty difficulty, String? hint) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddEditCardDialog(
        initialCard: card,
        existingCategories: existingCategories,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddEditCardDialog> createState() => _AddEditCardDialogState();
}

class _AddEditCardDialogState extends State<AddEditCardDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _hintController;
  late TextEditingController _customCategoryController;

  late String _selectedCategory;
  late CardDifficulty _selectedDifficulty;
  bool _isCustomCategory = false;

  @override
  void initState() {
    super.initState();
    final card = widget.initialCard;
    _questionController = TextEditingController(text: card?.question ?? '');
    _answerController = TextEditingController(text: card?.answer ?? '');
    _hintController = TextEditingController(text: card?.hint ?? '');
    _customCategoryController = TextEditingController();

    _selectedDifficulty = card?.difficulty ?? CardDifficulty.medium;

    final initialCat = card?.category ?? 'General';
    final categoriesList = widget.existingCategories.where((c) => c != 'All Decks').toList();

    if (categoriesList.contains(initialCat)) {
      _selectedCategory = initialCat;
      _isCustomCategory = false;
    } else if (initialCat.isNotEmpty && initialCat != 'General') {
      _selectedCategory = 'Other (Create New)';
      _isCustomCategory = true;
      _customCategoryController.text = initialCat;
    } else {
      _selectedCategory = categoriesList.isNotEmpty ? categoriesList.first : 'General';
      _isCustomCategory = false;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _hintController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      String finalCategory = _selectedCategory;
      if (_isCustomCategory || _selectedCategory == 'Other (Create New)') {
        finalCategory = _customCategoryController.text.trim();
        if (finalCategory.isEmpty) {
          finalCategory = 'General';
        }
      }

      widget.onSave(
        _questionController.text.trim(),
        _answerController.text.trim(),
        finalCategory,
        _selectedDifficulty,
        _hintController.text.trim().isEmpty ? null : _hintController.text.trim(),
      );

      Navigator.of(context).pop();
    }
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
    final isEditing = widget.initialCard != null;

    final availableCategories = widget.existingCategories
        .where((c) => c != 'All Decks')
        .toSet()
        .toList();
    if (!availableCategories.contains('General')) {
      availableCategories.add('General');
    }
    if (!availableCategories.contains('Other (Create New)')) {
      availableCategories.add('Other (Create New)');
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.add_card_rounded,
                      color: const Color(0xFF6366F1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Flashcard' : 'Create Flashcard',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Question Input
              Text(
                'Question / Prompt *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g., What is Polymorphism in OOP?',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.help_outline_rounded, color: Color(0xFF6366F1)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Answer Input
              Text(
                'Answer *',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g., The ability of an object to take many forms...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.lightbulb_rounded, color: Color(0xFF10B981)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                'Category / Deck',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: availableCategories.contains(_selectedCategory)
                    ? _selectedCategory
                    : 'Other (Create New)',
                dropdownColor: isDark ? const Color(0xFF1E2433) : Colors.white,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  prefixIcon: const Icon(Icons.folder_special_rounded, color: Color(0xFF6366F1)),
                ),
                items: availableCategories.map((cat) {
                  final deckCat = DeckCategory.getCategory(cat);
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(deckCat.icon, size: 18, color: deckCat.primaryColor),
                        const SizedBox(width: 8),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      _isCustomCategory = val == 'Other (Create New)';
                    });
                  }
                },
              ),

              if (_isCustomCategory || _selectedCategory == 'Other (Create New)') ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(
                    hintText: 'Enter new category name (e.g. History)',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                    ),
                    prefixIcon: const Icon(Icons.create_new_folder_rounded, color: Color(0xFF8B5CF6)),
                  ),
                  validator: (value) {
                    if (_isCustomCategory && (value == null || value.trim().isEmpty)) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Difficulty Level
              Text(
                'Difficulty Level',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: CardDifficulty.values.map((diff) {
                  final isSelected = _selectedDifficulty == diff;
                  final color = _getDifficultyColor(diff);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            diff.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : color,
                            ),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: color,
                        backgroundColor: isDark ? const Color(0xFF131722) : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? color : (isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedDifficulty = diff;
                            });
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Optional Hint
              Text(
                'Hint (Optional)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _hintController,
                decoration: InputDecoration(
                  hintText: 'A helpful clue to remember the answer...',
                  filled: true,
                  fillColor: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                  ),
                  prefixIcon: const Icon(Icons.tips_and_updates_outlined, color: Color(0xFFF59E0B)),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                        shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(isEditing ? Icons.save_rounded : Icons.check_rounded),
                      label: Text(
                        isEditing ? 'Save Changes' : 'Create Flashcard',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
