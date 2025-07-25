import 'package:flutter/material.dart';

class TodayButton extends StatefulWidget {
  final String direction;
  final VoidCallback onPress;
  final bool visible;

  const TodayButton({
    super.key,
    required this.direction,
    required this.onPress,
    required this.visible,
  });

  @override
  State<TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<TodayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    if (widget.visible) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TodayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: FloatingActionButton.small(
            onPressed: widget.onPress,
            backgroundColor: const Color(0xFF3a3a3a),
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 4,
            child: Icon(
              widget.direction == 'up' 
                ? Icons.keyboard_arrow_up_rounded 
                : Icons.keyboard_arrow_down_rounded,
              size: 28,
            ),
          ),
        );
      },
    );
  }
}