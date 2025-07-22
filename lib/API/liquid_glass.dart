import 'package:flutter/material.dart';

class LiquidGlassSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const LiquidGlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<LiquidGlassSwitch> createState() => _LiquidGlassSwitchState();
}

class _LiquidGlassSwitchState extends State<LiquidGlassSwitch>
    with SingleTickerProviderStateMixin {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  void _toggle() {
    setState(() => isOn = !isOn);
    widget.onChanged(isOn);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != isOn) {
      setState(() => isOn = widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        width: 64,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(36), // Fully rounded
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 0.7,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isOn ? 0.9 : 1.0,
                  end: isOn ? 1.0 : 0.9,
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutExpo,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: 32, // <-- Increased from 26 to 32
                  height: 26,
                  decoration: BoxDecoration(
                    color: isOn
                        ? accent.withOpacity(0.28)
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18), // Still rounded rectangle
                    border: Border.all(
                      color: isOn
                          ? accent.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                      width: 0.6,
                    ),
                    boxShadow: [
                      if (isOn)
                        BoxShadow(
                          color: accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
