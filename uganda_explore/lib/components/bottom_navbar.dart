import 'dart:ui';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Set the correct selected index based on current route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == '/home') {
        setState(() => selectedIndex = 0);
      } else if (currentRoute == '/profile') {
        setState(() => selectedIndex = 1);
      }
      // Add more cases as you add more screens
    });
  }

  final List<_NavBarItem> items = const [
    _NavBarItem(icon: Icons.home, label: "Home"),
    _NavBarItem(icon: Icons.person, label: "Profile"),
    _NavBarItem(icon: Icons.settings, label: "Settings"),
    _NavBarItem(icon: Icons.map, label: "Maps"),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: 350,
            height: 61,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                // Animated green background
                AnimatedAlign(
                  alignment: _getAlignment(selectedIndex),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                  child: Container(
                    height: 48,
                    width: 90, // Fixed width for selected item
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1FF813),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(items.length, (index) {
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });

                        // Navigate to different screens based on index
                        switch (index) {
                          case 0: // Home
                            if (ModalRoute.of(context)?.settings.name !=
                                '/home') {
                              Navigator.pushReplacementNamed(context, '/home');
                            }
                            break;
                          case 1: // Profile
                            Navigator.pushReplacementNamed(context, '/profile');
                            break;
                          case 2: // Settings
                            // Add settings route when you create it
                            break;
                          case 3: // Maps
                            // Add maps route when you create it
                            break;
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                        height: 61,
                        width: isSelected
                            ? 110
                            : 60, // Selected gets 90, others shrink to 40
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              items[index].icon,
                              color: isSelected ? Colors.white : Colors.black,
                              size: 30,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(opacity: anim, child: child),
                              child: isSelected
                                  ? Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                        items[index].label,
                                        key: ValueKey(items[index].label),
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Alignment _getAlignment(int index) {
    // For 4 items: -1.0, -0.33, 0.33, 1.0
    switch (index) {
      case 0:
        return const Alignment(-1.0, 0);
      case 1:
        return const Alignment(-0.33, 0);
      case 2:
        return const Alignment(0.33, 0);
      case 3:
        return const Alignment(1.0, 0);
      default:
        return Alignment.center;
    }
  }
}

class _NavBarItem {
  final IconData icon;
  final String label;
  const _NavBarItem({required this.icon, required this.label});
}
