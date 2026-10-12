import 'dart:convert';

enum CardDifficulty { easy, medium, hard }

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;
  final CardDifficulty difficulty;
  final String? hint;
  final bool isFavorite;
  final int timesReviewed;
  final int timesCorrect;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'General',
    this.difficulty = CardDifficulty.medium,
    this.hint,
    this.isFavorite = false,
    this.timesReviewed = 0,
    this.timesCorrect = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get masteryRate =>
      timesReviewed == 0 ? 0.0 : (timesCorrect / timesReviewed);

  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    CardDifficulty? difficulty,
    String? hint,
    bool? isFavorite,
    int? timesReviewed,
    int? timesCorrect,
    DateTime? createdAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      hint: hint ?? this.hint,
      isFavorite: isFavorite ?? this.isFavorite,
      timesReviewed: timesReviewed ?? this.timesReviewed,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'difficulty': difficulty.name,
      'hint': hint,
      'isFavorite': isFavorite,
      'timesReviewed': timesReviewed,
      'timesCorrect': timesCorrect,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      category: (map['category'] as String?) ?? 'General',
      difficulty: CardDifficulty.values.firstWhere(
        (e) => e.name == (map['difficulty'] as String? ?? 'medium'),
        orElse: () => CardDifficulty.medium,
      ),
      hint: map['hint'] as String?,
      isFavorite: (map['isFavorite'] as bool?) ?? false,
      timesReviewed: (map['timesReviewed'] as int?) ?? 0,
      timesCorrect: (map['timesCorrect'] as int?) ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Flashcard.fromJson(String source) =>
      Flashcard.fromMap(json.decode(source) as Map<String, dynamic>);
}
