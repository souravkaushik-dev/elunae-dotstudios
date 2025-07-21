import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/material.dart';

void showCustomBottomSheet(BuildContext context, Widget content) {
  final size = MediaQuery.sizeOf(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final backgroundGradientColors = isDark
      ? [
    Colors.white.withOpacity(0.05),
    Colors.white.withOpacity(0.02),
  ]
      : [
    Colors.white.withOpacity(0.3),
    Colors.white.withOpacity(0.15),
  ];

  final borderGradientColors = [
    Colors.white.withOpacity(0.25),
    Colors.white.withOpacity(0.08),
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (context) {
      final viewInsets = MediaQuery.of(context).viewInsets;

      return Padding(
        padding: viewInsets, // handles keyboard
        child: SafeArea(
          child: GlassmorphicContainer(
            width: double.infinity,
            borderRadius: 20,
            blur: 30,
            border: 1,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: backgroundGradientColors,
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: borderGradientColors,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 400,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Drag handle
                  Padding(
                    padding: EdgeInsets.only(top: size.height * 0.01, bottom: 12),
                    child: Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
