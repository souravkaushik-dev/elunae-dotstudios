/*🔧 Under Design · DotStudios*/

import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:elunae/utilities/common_variables.dart';

class CustomBar extends StatelessWidget {
  CustomBar(
    this.tileName,
    this.tileIcon, {
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final String tileName;
  final IconData tileIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color baseGlassColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: commonBarPadding,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 76, // Adapts to content
        borderRadius: 20,
        blur: 15,
        border: 1,
        alignment: Alignment.center,

        // Required gradients
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (backgroundColor ?? baseGlassColor).withOpacity(0.08),
            (backgroundColor ?? baseGlassColor).withOpacity(0.03),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),

        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),

        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          onLongPress: onLongPress,
          child: ListTile(
            minTileHeight: 45,
            leading: Icon(tileIcon, color: iconColor),
            title: Text(
              tileName,
              style: TextStyle(
                fontFamily: 'thin',
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}
