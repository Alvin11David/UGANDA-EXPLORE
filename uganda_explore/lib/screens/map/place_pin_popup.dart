import 'package:flutter/material.dart';

class HoverButtonsScreen extends StatefulWidget {
  const HoverButtonsScreen({super.key});

  @override
  State<HoverButtonsScreen> createState() => _HoverButtonsScreenState();
}

class _HoverButtonsScreenState extends State<HoverButtonsScreen>
    with SingleTickerProviderStateMixin {
  int selected = 0;
  late AnimationController _controller;
  late Animation<double> _hoverAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _hoverAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _onTap(int index) {
    if (selected != index) {
      setState(() {
        selected = index;
      });
      _controller.forward(from: 0);
    }
  }

  Widget _buildButton(String label, int index) {
    final bool isSelected = selected == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hover effect background
            AnimatedBuilder(
              animation: _hoverAnim,
              builder: (context, child) {
                if (!isSelected) return const SizedBox.shrink();
                double widthFactor = 0.5 + 0.5 * _hoverAnim.value;
                return Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1FF813),
                        borderRadius: BorderRadius.only(
                          topLeft: index == 1
                              ? const Radius.circular(30)
                              : Radius.zero,
                          topRight: index == 0
                              ? const Radius.circular(30)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Text foreground
            Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? Colors.transparent : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:
                      index == 1 ? const Radius.circular(30) : Radius.zero,
                  topRight:
                      index == 0 ? const Radius.circular(30) : Radius.zero,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1FF813),
      child: Text(
        selected == 0 ? 'Sign Up Section' : 'Sign In Section',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          // Green container touching bottom, left, right
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF1FF813),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Buttons row
                Row(
                  children: [
                    _buildButton('Sign Up', 0),
                    _buildButton('Sign In', 1),
                  ],
                ),
                // Content area
                _buildContentArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
