import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/flashcard.dart';

class FlashcardService extends ChangeNotifier {
  static const String _storageKey = 'codealpha_flashcards_data_v2';
  static const String _firstRunKey = 'codealpha_has_initialized_v2';
  final _uuid = const Uuid();

  List<Flashcard> _cards = [];
  bool _isLoading = true;

  List<Flashcard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;

  FlashcardService() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final hasInitialized = prefs.getBool(_firstRunKey) ?? false;

    if (!hasInitialized) {
      _cards = _getDefaultStarterCards();
      await _saveCardsToPrefs();
      await prefs.setBool(_firstRunKey, true);
    } else {
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List<dynamic> decoded = json.decode(jsonString);
          _cards = decoded.map((item) => Flashcard.fromMap(item as Map<String, dynamic>)).toList();
          if (_cards.isEmpty) {
            _cards = _getDefaultStarterCards();
            await _saveCardsToPrefs();
          }
        } catch (e) {
          debugPrint('Error parsing stored flashcards: $e');
          _cards = _getDefaultStarterCards();
        }
      } else {
        _cards = _getDefaultStarterCards();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  List<String> get categories {
    final set = <String>{'All Decks'};
    for (var card in _cards) {
      set.add(card.category);
    }
    return set.toList();
  }

  List<Flashcard> getCardsByCategory(String category) {
    if (category == 'All Decks' || category.isEmpty) {
      return _cards;
    }
    return _cards.where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<Flashcard> get favoriteCards => _cards.where((c) => c.isFavorite).toList();

  Future<void> addCard({
    required String question,
    required String answer,
    String category = 'General',
    CardDifficulty difficulty = CardDifficulty.medium,
    String? hint,
  }) async {
    final newCard = Flashcard(
      id: _uuid.v4(),
      question: question.trim(),
      answer: answer.trim(),
      category: category.trim().isEmpty ? 'General' : category.trim(),
      difficulty: difficulty,
      hint: hint?.trim().isNotEmpty == true ? hint!.trim() : null,
      createdAt: DateTime.now(),
    );

    _cards.insert(0, newCard);
    await _saveCardsToPrefs();
    notifyListeners();
  }

  Future<void> updateCard(Flashcard updatedCard) async {
    final index = _cards.indexWhere((c) => c.id == updatedCard.id);
    if (index != -1) {
      _cards[index] = updatedCard;
      await _saveCardsToPrefs();
      notifyListeners();
    }
  }

  Future<void> deleteCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
    await _saveCardsToPrefs();
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _cards.indexWhere((c) => c.id == id);
    if (index != -1) {
      _cards[index] = _cards[index].copyWith(
        isFavorite: !_cards[index].isFavorite,
      );
      await _saveCardsToPrefs();
      notifyListeners();
    }
  }

  Future<void> recordCardResult(String id, bool isCorrect) async {
    final index = _cards.indexWhere((c) => c.id == id);
    if (index != -1) {
      final card = _cards[index];
      _cards[index] = card.copyWith(
        timesReviewed: card.timesReviewed + 1,
        timesCorrect: card.timesCorrect + (isCorrect ? 1 : 0),
      );
      await _saveCardsToPrefs();
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    _cards = _getDefaultStarterCards();
    await _saveCardsToPrefs();
    notifyListeners();
  }

  Future<void> clearAllCards() async {
    _cards.clear();
    await _saveCardsToPrefs();
    notifyListeners();
  }

  Future<void> _saveCardsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = _cards.map((c) => c.toMap()).toList();
      await prefs.setString(_storageKey, json.encode(listMap));
    } catch (e) {
      debugPrint('Failed to save cards to storage: $e');
    }
  }

  // Analytics Stats
  int get totalCards => _cards.length;
  int get totalReviews => _cards.fold(0, (sum, c) => sum + c.timesReviewed);
  int get totalCorrect => _cards.fold(0, (sum, c) => sum + c.timesCorrect);
  double get overallAccuracy =>
      totalReviews == 0 ? 0.0 : (totalCorrect / totalReviews) * 100;
  int get masteredCount => _cards.where((c) => c.timesReviewed >= 3 && c.masteryRate >= 0.8).length;

  List<Flashcard> _getDefaultStarterCards() {
    return [
      // ================= COMPUTER SCIENCE (10 Cards) =================
      Flashcard(
        id: 'cs_1',
        question: 'What is the time complexity of searching in a Balanced Binary Search Tree (AVL/Red-Black)?',
        answer: 'O(log n) on average and worst-case, because the tree maintains balanced height proportional to log(n).',
        category: 'Computer Science',
        difficulty: CardDifficulty.medium,
        hint: 'Think of halving the search space at each comparison.',
        isFavorite: true,
      ),
      Flashcard(
        id: 'cs_2',
        question: 'What is the primary difference between a Stack and a Queue?',
        answer: 'A Stack follows LIFO (Last In, First Out), whereas a Queue follows FIFO (First In, First Out).',
        category: 'Computer Science',
        difficulty: CardDifficulty.easy,
        hint: 'Stack of plates vs. people in a ticket line.',
      ),
      Flashcard(
        id: 'cs_3',
        question: 'What does the "SOLID" acronym stand for in Software Architecture?',
        answer: 'S: Single Responsibility\nO: Open/Closed\nL: Liskov Substitution\nI: Interface Segregation\nD: Dependency Inversion',
        category: 'Computer Science',
        difficulty: CardDifficulty.hard,
        hint: '5 core object-oriented software design principles.',
      ),
      Flashcard(
        id: 'cs_4',
        question: 'What is the difference between a Process and a Thread?',
        answer: 'A Process is an independent executing program with isolated memory space. A Thread is a lightweight execution unit sharing memory with other threads in the same process.',
        category: 'Computer Science',
        difficulty: CardDifficulty.medium,
        hint: 'One has private memory space, the other shares memory.',
      ),
      Flashcard(
        id: 'cs_5',
        question: 'What is the primary function of Virtual Memory in Operating Systems?',
        answer: 'It maps virtual addresses to physical RAM and secondary storage (paging), allowing programs to run as if they have large contiguous memory even if physical RAM is limited.',
        category: 'Computer Science',
        difficulty: CardDifficulty.medium,
        hint: 'Paging and swap memory mechanism.',
      ),
      Flashcard(
        id: 'cs_6',
        question: 'What is the key difference between TCP and UDP protocols?',
        answer: 'TCP is connection-oriented with guaranteed, ordered delivery (3-way handshake & ACKs). UDP is connectionless and faster with no delivery guarantees (ideal for streaming & gaming).',
        category: 'Computer Science',
        difficulty: CardDifficulty.medium,
        hint: 'Reliable vs. fast packet streaming.',
      ),
      Flashcard(
        id: 'cs_7',
        question: 'What is Polymorphism in Object-Oriented Programming?',
        answer: 'The ability of different classes to provide different underlying implementations for the same interface or method name (e.g. method overriding and overloading).',
        category: 'Computer Science',
        difficulty: CardDifficulty.easy,
        hint: 'Greek for "many forms".',
        isFavorite: true,
      ),
      Flashcard(
        id: 'cs_8',
        question: 'What is a Database Deadlock?',
        answer: 'A condition where two or more transactions are permanently blocked because each holds a lock on a resource the other needs.',
        category: 'Computer Science',
        difficulty: CardDifficulty.hard,
        hint: 'Circular wait on locked tables/rows.',
      ),
      Flashcard(
        id: 'cs_9',
        question: 'What is the worst-case time complexity of QuickSort?',
        answer: 'O(n²), which occurs when the selected pivot is always the smallest or largest element (e.g., sorted array with naive pivot).',
        category: 'Computer Science',
        difficulty: CardDifficulty.medium,
        hint: 'Happens with poor pivot selection.',
      ),
      Flashcard(
        id: 'cs_10',
        question: 'What is DNS (Domain Name System)?',
        answer: 'The internet\'s naming service that translates human-readable domain names (e.g., google.com) into numerical IP addresses (e.g., 142.250.190.46).',
        category: 'Computer Science',
        difficulty: CardDifficulty.easy,
        hint: 'Phonebook of the internet.',
      ),

      // ================= SCIENCE & BIOLOGY (10 Cards) =================
      Flashcard(
        id: 'sci_1',
        question: 'What organelle is known as the "Powerhouse of the Cell"?',
        answer: 'Mitochondria! They generate most of the chemical energy needed for cellular biochemical reactions via ATP synthesis.',
        category: 'Science & Biology',
        difficulty: CardDifficulty.easy,
        hint: 'Synthesizes ATP.',
        isFavorite: true,
      ),
      Flashcard(
        id: 'sci_2',
        question: 'What is the speed of light in a vacuum?',
        answer: 'Approximately 299,792,458 meters per second (~300,000 km/s or 186,282 miles/s).',
        category: 'Science & Biology',
        difficulty: CardDifficulty.medium,
        hint: 'Represented by "c" in E = mc².',
      ),
      Flashcard(
        id: 'sci_3',
        question: 'What is the chemical formula for Water and what bonds hold it together?',
        answer: 'H₂O (two Hydrogen atoms and one Oxygen atom), held together by polar covalent bonds.',
        category: 'Science & Biology',
        difficulty: CardDifficulty.easy,
        hint: 'Universal solvent.',
      ),
      Flashcard(
        id: 'sci_4',
        question: 'Which planet in our Solar System has the most confirmed moons?',
        answer: 'Saturn, with 146 officially recognized moons (surpassing Jupiter\'s 95).',
        category: 'Science & Biology',
        difficulty: CardDifficulty.medium,
        hint: 'Famous for its prominent icy rings.',
      ),
      Flashcard(
        id: 'sci_5',
        question: 'What is the process by which green plants produce glucose using sunlight?',
        answer: 'Photosynthesis! 6CO₂ + 6H₂O + Light → C₆H₁₂O₆ + 6O₂ (using chlorophyll).',
        category: 'Science & Biology',
        difficulty: CardDifficulty.easy,
        hint: 'Converts sunlight and carbon dioxide to sugar.',
      ),
      Flashcard(
        id: 'sci_6',
        question: 'What is the hardest known natural mineral on Earth?',
        answer: 'Diamond, which scores a maximum 10 on the Mohs scale of mineral hardness.',
        category: 'Science & Biology',
        difficulty: CardDifficulty.easy,
        hint: 'Crystalline carbon allotrope.',
      ),
      Flashcard(
        id: 'sci_7',
        question: 'Which part of the human brain controls balance and motor coordination?',
        answer: 'The Cerebellum (located at the back base of the brain).',
        category: 'Science & Biology',
        difficulty: CardDifficulty.medium,
        hint: 'Latin for "little brain".',
      ),
      Flashcard(
        id: 'sci_8',
        question: 'State Newton\'s Third Law of Motion.',
        answer: 'For every action, there is an equal and opposite reaction.',
        category: 'Science & Biology',
        difficulty: CardDifficulty.easy,
        hint: 'Action and reaction.',
      ),
      Flashcard(
        id: 'sci_9',
        question: 'Which human blood type is considered the Universal Red Blood Cell Donor?',
        answer: 'O-negative (O-), because its red blood cells lack A, B, and Rh surface antigens.',
        category: 'Science & Biology',
        difficulty: CardDifficulty.medium,
        hint: 'Type O with negative Rh factor.',
        isFavorite: true,
      ),
      Flashcard(
        id: 'sci_10',
        question: 'What gas makes up the largest percentage of Earth\'s atmosphere?',
        answer: 'Nitrogen gas (N₂), making up approximately 78% of dry air, followed by Oxygen (~21%).',
        category: 'Science & Biology',
        difficulty: CardDifficulty.medium,
        hint: 'Not Oxygen!',
      ),

      // ================= LANGUAGES & VOCAB (10 Cards) =================
      Flashcard(
        id: 'lang_1',
        question: 'How do you say "Thank you very much" in Spanish?',
        answer: '"Muchas gracias" (pronounced: MOO-chas GRAH-syas).',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.easy,
        hint: 'Starts with "Muchas..."',
        isFavorite: true,
      ),
      Flashcard(
        id: 'lang_2',
        question: 'What is the meaning of the German compound word "Schadenfreude"?',
        answer: 'Pleasure or joy derived by someone from another person\'s misfortune or embarrassment.',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.medium,
        hint: 'Damage/harm (Schaden) + Joy (Freude).',
      ),
      Flashcard(
        id: 'lang_3',
        question: 'What does the famous Latin phrase "Carpe Diem" mean?',
        answer: '"Seize the day" — an aphorism urging people to make the most of the present moment.',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.easy,
        hint: 'Live in the moment.',
      ),
      Flashcard(
        id: 'lang_4',
        question: 'What does the French phrase "Déjà vu" literally translate to?',
        answer: '"Already seen" — describing the psychological feeling of having previously experienced the current situation.',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.easy,
        hint: 'Already seen.',
      ),
      Flashcard(
        id: 'lang_5',
        question: 'What is an "Oxymoron" in literary terms?',
        answer: 'A figure of speech in which two contradictory terms appear together (e.g., "deafening silence", "bittersweet", "virtual reality").',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.medium,
        hint: 'Self-contradictory combination of words.',
      ),
      Flashcard(
        id: 'lang_6',
        question: 'How do you say "Good morning" politely in Japanese?',
        answer: '"Ohayou gozaimasu" (おはようございます).',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.easy,
        hint: 'Ohayou...',
      ),
      Flashcard(
        id: 'lang_7',
        question: 'What is the definition of the adjective "Ephemeral"?',
        answer: 'Lasting for a very short time; fleeting, transitory, or momentary (e.g., "ephemeral beauty").',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.hard,
        hint: 'Short-lived.',
      ),
      Flashcard(
        id: 'lang_8',
        question: 'What does the Italian culinary phrase "Al Dente" mean?',
        answer: '"To the tooth" — describing pasta or vegetables cooked to be firm to the bite.',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.easy,
        hint: 'Related to "dental / teeth".',
      ),
      Flashcard(
        id: 'lang_9',
        question: 'What is the difference between "Affect" and "Effect"?',
        answer: '"Affect" is predominantly a verb meaning to impact or produce a change in. "Effect" is predominantly a noun meaning the result or outcome.',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.medium,
        hint: 'Action (Verb) vs. End-result (Noun).',
      ),
      Flashcard(
        id: 'lang_10',
        question: 'What does the word "Ubiquitous" mean?',
        answer: 'Present, appearing, or found everywhere simultaneously (e.g., "smartphones are ubiquitous in modern life").',
        category: 'Languages & Vocab',
        difficulty: CardDifficulty.medium,
        hint: 'Omnipresent.',
      ),

      // ================= WORLD CAPITALS (10 Cards) =================
      Flashcard(
        id: 'cap_1',
        question: 'What is the capital city of Australia?',
        answer: 'Canberra (a purpose-built planned city situated between Sydney and Melbourne).',
        category: 'World Capitals',
        difficulty: CardDifficulty.medium,
        hint: 'Often confused with Sydney or Melbourne.',
        isFavorite: true,
      ),
      Flashcard(
        id: 'cap_2',
        question: 'What is the capital city of Japan?',
        answer: 'Tokyo (formerly known as Edo, the world\'s most populous metropolitan area).',
        category: 'World Capitals',
        difficulty: CardDifficulty.easy,
        hint: 'Largest metro city in the world.',
      ),
      Flashcard(
        id: 'cap_3',
        question: 'What is the capital city of Canada?',
        answer: 'Ottawa (located in the province of Ontario on the border with Quebec).',
        category: 'World Capitals',
        difficulty: CardDifficulty.medium,
        hint: 'Not Toronto, Montreal, or Vancouver.',
      ),
      Flashcard(
        id: 'cap_4',
        question: 'What is the capital city of Brazil?',
        answer: 'Brasília (a planned federal capital inaugurated in 1960 to move the capital inland from Rio de Janeiro).',
        category: 'World Capitals',
        difficulty: CardDifficulty.medium,
        hint: 'Not Rio de Janeiro or São Paulo.',
      ),
      Flashcard(
        id: 'cap_5',
        question: 'What is the capital city of Egypt?',
        answer: 'Cairo (located on the Nile River, near the Great Pyramids of Giza).',
        category: 'World Capitals',
        difficulty: CardDifficulty.easy,
        hint: 'City of a Thousand Minarets.',
      ),
      Flashcard(
        id: 'cap_6',
        question: 'What is the capital city of Turkey?',
        answer: 'Ankara (declared the capital in 1923 by Mustafa Kemal Atatürk).',
        category: 'World Capitals',
        difficulty: CardDifficulty.medium,
        hint: 'Not Istanbul!',
      ),
      Flashcard(
        id: 'cap_7',
        question: 'What is the capital city of South Korea?',
        answer: 'Seoul (located on the Han River).',
        category: 'World Capitals',
        difficulty: CardDifficulty.easy,
        hint: 'Home to the Gyeongbokgung Palace.',
      ),
      Flashcard(
        id: 'cap_8',
        question: 'What is the capital city of Argentina?',
        answer: 'Buenos Aires (located on the western shore of the Río de la Plata estuary).',
        category: 'World Capitals',
        difficulty: CardDifficulty.easy,
        hint: 'Birthplace of the Tango.',
      ),
      Flashcard(
        id: 'cap_9',
        question: 'What is the capital city of Norway?',
        answer: 'Oslo (known for its green spaces, Viking Ship Museum, and fjord setting).',
        category: 'World Capitals',
        difficulty: CardDifficulty.medium,
        hint: 'Scandinavian capital.',
      ),
      Flashcard(
        id: 'cap_10',
        question: 'What is the de facto federal capital of Switzerland?',
        answer: 'Bern (Switzerland has no single constitutionally designated capital; Bern serves as the Federal City).',
        category: 'World Capitals',
        difficulty: CardDifficulty.hard,
        hint: 'Not Zurich or Geneva.',
      ),

      // ================= HISTORY & TRIVIA (10 Cards) =================
      Flashcard(
        id: 'hist_1',
        question: 'In which year did the Apollo 11 mission land humans on the Moon?',
        answer: '1969 (July 20, 1969 — Neil Armstrong and Buzz Aldrin landed the lunar module Eagle).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.easy,
        hint: '"One small step for man..."',
        isFavorite: true,
      ),
      Flashcard(
        id: 'hist_2',
        question: 'Who painted the "Mona Lisa" and the "Last Supper"?',
        answer: 'Leonardo da Vinci (the Italian High Renaissance master and polymath).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.easy,
        hint: 'Italian Renaissance polymath.',
      ),
      Flashcard(
        id: 'hist_3',
        question: 'In which year did World War II officially end?',
        answer: '1945 (Victory in Europe in May 1945, followed by the surrender of Japan in September 1945).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.easy,
        hint: 'Mid-1940s.',
      ),
      Flashcard(
        id: 'hist_4',
        question: 'Which ancient civilization constructed the citadel of Machu Picchu in Peru?',
        answer: 'The Inca Empire (built around 1450 CE under Emperor Pachacuti).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.medium,
        hint: 'Andean South American empire.',
      ),
      Flashcard(
        id: 'hist_5',
        question: 'What was the name of the first artificial satellite launched into orbit in 1957?',
        answer: 'Sputnik 1 (launched by the Soviet Union on October 4, 1957, igniting the Space Race).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.medium,
        hint: 'Russian for "fellow traveler / satellite".',
      ),
      Flashcard(
        id: 'hist_6',
        question: 'Who wrote the famous romantic tragedy "Romeo and Juliet"?',
        answer: 'William Shakespeare (written early in his career, around 1595).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.easy,
        hint: 'The Bard of Avon.',
      ),
      Flashcard(
        id: 'hist_7',
        question: 'Which historic charter signed in 1215 established that everyone, including the King, was subject to the law?',
        answer: 'The Magna Carta (The Great Charter, signed by King John of England at Runnymede).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.medium,
        hint: 'Latin for "Great Charter".',
      ),
      Flashcard(
        id: 'hist_8',
        question: 'What was the ancient network of Eurasian trade routes connecting East Asia with the Mediterranean called?',
        answer: 'The Silk Road (established during the Han Dynasty around 130 BCE).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.easy,
        hint: 'Named after the lucrative textile exported from China.',
      ),
      Flashcard(
        id: 'hist_9',
        question: 'Who served as the first President of the United States?',
        answer: 'George Washington (served from 1789 to 1797).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.easy,
        hint: 'Commander of the Continental Army.',
      ),
      Flashcard(
        id: 'hist_10',
        question: 'Which of the Seven Wonders of the Ancient World is the only one still standing today?',
        answer: 'The Great Pyramid of Giza (built around 2560 BCE as a tomb for Pharaoh Khufu).',
        category: 'History & Trivia',
        difficulty: CardDifficulty.medium,
        hint: 'Located on the Giza plateau in Egypt.',
      ),
    ];
  }
}
