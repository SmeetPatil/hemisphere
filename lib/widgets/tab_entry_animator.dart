import 'package:flutter/material.dart';
import '../../screens/home_screen.dart';

class TabEntryAnimator extends StatefulWidget {
  final int tabIndex;
  final Widget child;
  final double delayMs;

  const TabEntryAnimator({
    super.key,
    required this.tabIndex,
    required this.child,
    this.delayMs = 0.0,
  });

  @override
  State<TabEntryAnimator> createState() => _TabEntryAnimatorState();
}

class _TabEntryAnimatorState extends State<TabEntryAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    HomeScreen.currentTabNotifier.addListener(_onTabChange);
    // Play initially if this is the active tab.
    if (HomeScreen.currentTabNotifier.value == widget.tabIndex) {
      _triggerAnimation();
    }
  }

  void _onTabChange() {
    if (HomeScreen.currentTabNotifier.value == widget.tabIndex) {
      _triggerAnimation();
    } else {
      _controller.reset();
    }
  }

  void _triggerAnimation() {
    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs.toInt()), () {
        if (mounted && HomeScreen.currentTabNotifier.value == widget.tabIndex) {
          _controller.forward(from: 0.0);
        }
      });
    } else {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    HomeScreen.currentTabNotifier.removeListener(_onTabChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
