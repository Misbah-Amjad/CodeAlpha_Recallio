import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/manage_cards_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/study_quiz_screen.dart';
import 'services/flashcard_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlashcardQuizApp());
}

class FlashcardQuizApp extends StatefulWidget {
  const FlashcardQuizApp({super.key});

  @override
  State<FlashcardQuizApp> createState() => _FlashcardQuizAppState();
}

class _FlashcardQuizAppState extends State<FlashcardQuizApp> {
  final FlashcardService _flashcardService = FlashcardService();
  final ThemeService _themeService = ThemeService();
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _flashcardService.addListener(_onServiceChange);
    _themeService.addListener(_onServiceChange);
  }

  void _onServiceChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _flashcardService.removeListener(_onServiceChange);
    _themeService.removeListener(_onServiceChange);
    _flashcardService.dispose();
    _themeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Light Theme Definition
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B4A6),
        brightness: Brightness.light,
        primary: const Color(0xFF00B4A6),
        secondary: const Color(0xFF1A2E5A),
        surface: const Color(0xFFF8FAFC),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        foregroundColor: Color(0xFF0F172A),
        elevation: 0,
        centerTitle: false,
      ),
    );

    // Dark Theme Definition
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B4A6),
        brightness: Brightness.dark,
        primary: const Color(0xFF00B4A6),
        secondary: const Color(0xFF1A2E5A),
        surface: const Color(0xFF1E2433),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
      ),
    );

    return MaterialApp(
      title: 'Recallio',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeService.themeMode,
      home: _showSplash
          ? SplashScreen(
              onComplete: () {
                if (mounted) {
                  setState(() {
                    _showSplash = false;
                  });
                }
              },
            )
          : (_flashcardService.isLoading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00B4A6)),
                  ),
                )
              : MainNavigationScaffold(
                  flashcardService: _flashcardService,
                  themeService: _themeService,
                )),
    );
  }
}

class MainNavigationScaffold extends StatefulWidget {
  final FlashcardService flashcardService;
  final ThemeService themeService;

  const MainNavigationScaffold({
    super.key,
    required this.flashcardService,
    required this.themeService,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      StudyQuizScreen(
        flashcardService: widget.flashcardService,
        onNavigateToManage: () {
          setState(() {
            _selectedTabIndex = 1;
          });
        },
      ),
      ManageCardsScreen(flashcardService: widget.flashcardService),
      StatsScreen(
        flashcardService: widget.flashcardService,
        themeService: widget.themeService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedTabIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2433) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: NavigationBar(
              height: 60,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _selectedTabIndex,
              indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.18),
              onDestinationSelected: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.style_outlined),
                  selectedIcon: Icon(
                    Icons.style_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Study & Quiz',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_customize_outlined),
                  selectedIcon: Icon(
                    Icons.dashboard_customize_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Manage Cards',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(
                    Icons.insights_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  label: 'Analytics',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
