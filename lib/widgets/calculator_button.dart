import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculatorButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onTap;
  final bool isOperator;
  final bool isSecondary;
  final bool isActive;
  final int flex;
  final bool forceCircle;

  const CalculatorButton({
    super.key,
    this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 32,
    this.fontWeight = FontWeight.w500,
    required this.onTap,
    this.isOperator = false,
    this.isSecondary = false,
    this.isActive = false,
    this.flex = 1,
    this.forceCircle = true,
  }) : assert(text != null || icon != null, 'Text or Icon must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color buttonColor;
    Color contentColor;

    if (isActive) {
      buttonColor = Colors.white;
      contentColor = colorScheme.primary;
    } else if (isOperator) {
      buttonColor = colorScheme.primary;
      contentColor = Colors.white;
    } else if (isSecondary) {
      buttonColor = colorScheme.tertiary;
      contentColor = isDark
          ? Colors.white70
          : colorScheme.onSurface;
    } else {
      buttonColor = colorScheme.surface;
      contentColor = colorScheme.onSurface;
    }

    buttonColor = backgroundColor ?? buttonColor;
    contentColor = textColor ?? contentColor;

    Widget buttonMaterial = Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(28),
      elevation: isOperator ? 6 : (isDark ? 0 : 2),
      shadowColor: isOperator
          ? colorScheme.primary.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        splashColor: contentColor.withValues(alpha: 0.2),
        highlightColor: contentColor.withValues(alpha: 0.1),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  size: fontSize,
                  color: contentColor,
                )
              : Transform.translate(
                  offset: Offset(0, isOperator ? -1.0 : 0.0),
                  child: Text(
                    text!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      height: 1.0,
                    ),
                  ),
                ),
        ),
      ),
    );

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: forceCircle
            ? AspectRatio(
                aspectRatio: flex.toDouble(),
                child: buttonMaterial,
              )
            : buttonMaterial,
      ),
    );
  }
}
