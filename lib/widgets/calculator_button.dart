import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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
    
    final currentAppTheme = Provider.of<ThemeProvider>(context).currentTheme;
    final isNothing = currentAppTheme == AppTheme.nothing || currentAppTheme == AppTheme.nothingLight;

    Color buttonColor;
    Color contentColor;

    if (isActive) {
      buttonColor = colorScheme.onPrimary;
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
              ? (isNothing && icon == Icons.backspace_outlined
                  ? Text(
                      'DEL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: contentColor,
                        fontSize: fontSize * 0.8,
                        fontWeight: fontWeight,
                        height: 1.0,
                      ),
                    )
                  : Icon(
                      icon,
                      size: fontSize,
                      color: contentColor,
                    ))
              : (isNothing && (text == '×' || text == '÷'))
                  ? Transform.translate(
                      offset: Offset(0, text == '×' ? 2.0 : 0.0),
                      child: text == '×' 
                          ? _buildDotMatrixMultiply(contentColor, fontSize)
                          : _buildDotMatrixDivide(contentColor, fontSize),
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

  Widget _buildDotMatrixDivide(Color color, double size) {
    final dotSize = size * 0.085;
    return SizedBox(
      width: size * 0.6,
      height: size * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: dotSize, height: dotSize, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(height: dotSize * 1.8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => Padding(
              padding: EdgeInsets.symmetric(horizontal: dotSize * 0.2),
              child: Container(width: dotSize, height: dotSize, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            )),
          ),
          SizedBox(height: dotSize * 1.8),
          Container(width: dotSize, height: dotSize, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildDotMatrixMultiply(Color color, double size) {
    final dotSize = size * 0.085;
    return SizedBox(
      width: size * 0.6,
      height: size * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMultiplyRow(color, dotSize, [true, false, false, false, true]),
          _buildMultiplyRow(color, dotSize, [false, true, false, true, false]),
          _buildMultiplyRow(color, dotSize, [false, false, true, false, false]),
          _buildMultiplyRow(color, dotSize, [false, true, false, true, false]),
          _buildMultiplyRow(color, dotSize, [true, false, false, false, true]),
        ],
      ),
    );
  }

  Widget _buildMultiplyRow(Color color, double dotSize, List<bool> dots) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots.map((isOn) => Padding(
        padding: EdgeInsets.all(dotSize * 0.15),
        child: Container(
          width: dotSize, 
          height: dotSize, 
          decoration: BoxDecoration(color: isOn ? color : Colors.transparent, shape: BoxShape.circle)
        ),
      )).toList(),
    );
  }
}
