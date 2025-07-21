import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

void showToast(
    BuildContext context,
    String text, {
      Duration duration = const Duration(seconds: 3),
    }) {
  final overlay = Overlay.of(context);
  final theme = Theme.of(context);
  final baseColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 90,
      left: 24,
      right: 24,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 48,
        blur: 20,
        borderRadius: 14,
        alignment: Alignment.center,
        border: 0,
        linearGradient: LinearGradient(
          colors: [
            baseColor.withOpacity(0.08),
            baseColor.withOpacity(0.03),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.05),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.inverseSurface,
              fontFamily: 'thin',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
  Timer(duration, overlayEntry.remove);
}


void showToastWithButton(
  BuildContext context,
  String text,
  String buttonName,
  VoidCallback onPressedToast, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      content: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
      ),
      action: SnackBarAction(
        label: buttonName,
        textColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => onPressedToast(),
      ),
      duration: duration,
    ),
  );
}
