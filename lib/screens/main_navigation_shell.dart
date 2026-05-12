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
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuart;
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
      
      // Custom Bottom App Bar (Clean, Symmetrical, flat layout)
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavButton(Icons.search, Icons.search, 'Explore', 1),
              
              // Clean, simple central Add/Record Trigger
              _buildCreateButton(),
              
              _buildNavButton(Icons.bookmark_outline, Icons.bookmark, 'Saved', 2),
              _buildNavButton(Icons.person_outline, Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  // Simple Add/Record item (matches standard button spacing)
  Widget _buildCreateButton() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToCreate,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              'Add',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 10,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
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
