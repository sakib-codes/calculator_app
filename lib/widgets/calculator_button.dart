import 'package:flutter/material.dart';

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
  }) : assert(text != null || icon != null, 'Text or Icon must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      contentColor = theme.brightness == Brightness.dark
          ? Colors.white70
          : colorScheme.onSurface;
    } else {
      buttonColor = colorScheme.surface;
      contentColor = colorScheme.onSurface;
    }

    buttonColor = backgroundColor ?? buttonColor;
    contentColor = textColor ?? contentColor;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Material(
            color: buttonColor,
            borderRadius: BorderRadius.circular(24),
            elevation: isOperator ? 4 : 2,
            shadowColor: isOperator
                ? colorScheme.primary.withValues(alpha: 0.4)
                : Colors.black12,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onTap,
              splashColor: contentColor.withValues(alpha: 0.2),
              highlightColor: contentColor.withValues(alpha: 0.1),
              child: Center(
                child: icon != null
                    ? Icon(
                        icon,
                        size: 32,
                        color: contentColor,
                      )
                    : Transform.translate(
                        offset: Offset(0, isOperator ? -4.0 : (text == '.' ? 2.0 : 0.0)),
                        child: Text(
                          text!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: contentColor,
                            fontSize: fontSize,
                            fontWeight: fontWeight,
                            height: 1.0, // Keeping 1.0 consistent
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
