import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const HoverCard({super.key, required this.child, required this.onTap});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scaled(_isHovered ? 1.05 : 1.0),
          child: widget.child,
        ),
      ),
    );
  }
}
