import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'create_confession_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;
  const MainNavigationShell({super.key, this.initialTab = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  // Lists of screens corresponding to bottom nav
  final List<Widget> _tabs = [
    const HomeScreen(),
    const ExploreScreen(),
    const SavedScreen(),
    const ProfileScreen(),
  ];

  void _navigateToCreate() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => const CreateConfessionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final begin = const Offset(0.0, 1.0);
          final end = Offset.zero;
          final curve = Curves.easeOutQuart;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      
      // Floating Action Button in the center (Slightly raised, 5px rounded square)
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: FloatingActionButton(
          onPressed: _navigateToCreate,
          elevation: 4.0,
          backgroundColor: AppColors.pureBlack,
          foregroundColor: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Strict 5px
          ),
          child: const Icon(Icons.add, size: 24),
        ),
      ),

      // Custom Bottom App Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          height: 64.0,
          color: AppColors.cardBg,
          elevation: 0,
          padding: EdgeInsets.zero,
          notchMargin: 8.0,
          shape: const CircularNotchedRectangle(), // Allows the float button to nest beautifully
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left side tabs
              _buildNavButton(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavButton(Icons.search, Icons.search, 'Explore', 1),
              
              const SizedBox(width: 48), // Gap for central Floating Button
              
              // Right side tabs
              _buildNavButton(Icons.bookmark_outline, Icons.bookmark, 'Saved', 2),
              _buildNavButton(Icons.person_outline, Icons.person, 'Diary', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
    IconData outlineIcon,
    IconData filledIcon,
    String label,
    int tabIndex,
  ) {
    final isSelected = _currentIndex == tabIndex;
    final color = isSelected ? AppColors.pureBlack : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _currentIndex = tabIndex;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
