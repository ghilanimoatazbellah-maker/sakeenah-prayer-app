import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'adhkar/screens/adhkar_screen.dart';
import 'home/screens/home_screen.dart';
import 'qibla/screens/qibla_screen.dart';
import 'settings/screens/settings_screen.dart';

/// Root Shell — Container holding the Navigation Bar and switching between
/// the 4 primary app tabs (Home, Adhkar, Qibla, Settings).
/// Each tab has its OWN Navigator so that pushes within a tab keep
/// the bottom nav bar visible. Adapts to Light and Midnight Dark modes.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _selectedIndex = 0;

  // One GlobalKey<NavigatorState> per tab so each tab owns its own stack
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _rootScreens = const [
    HomeScreen(),
    AdhkarScreen(),
    QiblaScreen(),
    SettingsScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = _navigatorKeys[_selectedIndex].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else {
          // Exit the app if nothing to pop on the root tab
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(
            _rootScreens.length,
            (i) => Navigator(
              key: _navigatorKeys[i],
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (_) => _rootScreens[i],
                settings: settings,
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColorsDark.surface : AppColors.surface,
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppColorsDark.outlineVariant
                    : AppColors.surfaceContainerHighest,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primary)
                    .withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'الرئيسية',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: Icons.auto_stories_outlined,
                    selectedIcon: Icons.auto_stories_rounded,
                    label: 'الأذكار',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.explore_outlined,
                    selectedIcon: Icons.explore_rounded,
                    label: 'القبلة',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    label: 'الإعدادات',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    final activeColor = isDark ? AppColorsDark.secondary : AppColors.primary;
    final inactiveColor =
        isDark ? AppColorsDark.onSurfaceVariant : AppColors.onSurfaceVariant;
    final activeBg = isDark
        ? AppColorsDark.primaryContainer.withValues(alpha: 0.4)
        : AppColors.secondaryFixedDim.withValues(alpha: 0.2);

    return InkWell(
      onTap: () {
        if (_selectedIndex == index) {
          // Tap same tab → pop to root of that tab's navigator
          _navigatorKeys[index].currentState?.popUntil((r) => r.isFirst);
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      borderRadius: BorderRadius.circular(AppRadius.base),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? activeBg : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
