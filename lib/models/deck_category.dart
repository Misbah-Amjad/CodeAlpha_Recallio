import 'package:flutter/material.dart';

class DeckCategory {
  final String name;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const DeckCategory({
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static const List<DeckCategory> defaultCategories = [
    DeckCategory(
      name: 'All Decks',
      icon: Icons.layers_rounded,
      primaryColor: Color(0xFF6366F1), // Indigo
      secondaryColor: Color(0xFF8B5CF6),
    ),
    DeckCategory(
      name: 'Computer Science',
      icon: Icons.code_rounded,
      primaryColor: Color(0xFF0EA5E9), // Sky Blue
      secondaryColor: Color(0xFF2563EB),
    ),
    DeckCategory(
      name: 'Science & Biology',
      icon: Icons.biotech_rounded,
      primaryColor: Color(0xFF10B981), // Emerald
      secondaryColor: Color(0xFF059669),
    ),
    DeckCategory(
      name: 'Languages & Vocab',
      icon: Icons.translate_rounded,
      primaryColor: Color(0xFFF59E0B), // Amber
      secondaryColor: Color(0xFFD97706),
    ),
    DeckCategory(
      name: 'World Capitals',
      icon: Icons.public_rounded,
      primaryColor: Color(0xFFEC4899), // Pink
      secondaryColor: Color(0xFFBE185D),
    ),
    DeckCategory(
      name: 'History & Trivia',
      icon: Icons.history_edu_rounded,
      primaryColor: Color(0xFF8B5CF6), // Purple
      secondaryColor: Color(0xFF6D28D9),
    ),
    DeckCategory(
      name: 'Custom',
      icon: Icons.bookmark_added_rounded,
      primaryColor: Color(0xFF14B8A6), // Teal
      secondaryColor: Color(0xFF0D9488),
    ),
  ];

  static DeckCategory getCategory(String name) {
    return defaultCategories.firstWhere(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
      orElse: () => DeckCategory(
        name: name,
        icon: Icons.category_rounded,
        primaryColor: const Color(0xFF6366F1),
        secondaryColor: const Color(0xFF8B5CF6),
      ),
    );
  }
}
