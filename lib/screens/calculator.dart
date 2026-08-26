import 'package:flutter/material.dart';
import '../widgets/quick_converter.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/calculator_button.dart';
import 'time_calculator_view.dart';

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    final isNothing = themeProvider.currentTheme == AppTheme.nothing || themeProvider.currentTheme == AppTheme.nothingLight;

    return Scaffold(
      drawer: AppDrawer(
        onQuickConverterTap: () => _showQuickConverter(context, provider),
      ),
      // Removed AppBar to avoid status bar overlap. Nav buttons are now manually placed in the body's SafeArea.
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          // Don't intercept keys when in age/time mode — let TextFields handle input
          if (provider.mode == CalculatorMode.age) {
            return KeyEventResult.ignored;
          }
          if (event is KeyDownEvent) {
            bool handled = false;
            final char = event.character;
            final key = event.logicalKey;

            if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || char == '=') {
              provider.buttonPress('=');
              handled = true;
            } else if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
              provider.buttonPress('del');
              handled = true;
            } else if (key == LogicalKeyboardKey.escape) {
              provider.buttonPress('AC');
              handled = true;
            } else if (char == '*' || key == LogicalKeyboardKey.asterisk || key == LogicalKeyboardKey.numpadMultiply) {
              provider.buttonPress('×');
              handled = true;
            } else if (char == '/' || key == LogicalKeyboardKey.slash || key == LogicalKeyboardKey.numpadDivide) {
              provider.buttonPress('÷');
              handled = true;
            } else if (char == '-' || key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
              provider.buttonPress('-');
              handled = true;
            } else if (char == '+' || key == LogicalKeyboardKey.add || key == LogicalKeyboardKey.numpadAdd) {
              provider.buttonPress('+');
              handled = true;
            } else if (char == '.' || key == LogicalKeyboardKey.period || key == LogicalKeyboardKey.numpadDecimal) {
              provider.buttonPress('.');
              handled = true;
            } else if (char == '%') {
              provider.buttonPress('%');
              handled = true;
            } else if (char != null && RegExp(r'^[0-9a-fA-F]$').hasMatch(char)) {
              if (_isValidDigit(char.toUpperCase(), provider.baseMode)) {
                provider.buttonPress(char.toUpperCase());
                handled = true;
              }
            }
            if (handled) return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar inside SafeArea to prevent status bar overlap
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0, 
                  vertical: isPortrait ? 8.0 : 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: isNothing ? const Text('MENU', style: TextStyle(fontSize: 16)) : const Icon(Icons.sort),
                        color: colorScheme.onSurface,
                        iconSize: isPortrait ? 24.0 : 20.0,
                        constraints: isPortrait ? null : const BoxConstraints(minHeight: 36, minWidth: 36),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    IconButton(
                      icon: isNothing ? const Text('HIST', style: TextStyle(fontSize: 16)) : const Icon(Icons.history_rounded),
                      color: colorScheme.onSurface,
                      iconSize: isPortrait ? 24.0 : 20.0,
                      constraints: isPortrait ? null : const BoxConstraints(minHeight: 36, minWidth: 36),
                      onPressed: () {
                        _showHistory(context, provider);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.mode == CalculatorMode.age
                    ? const TimeCalculatorView()
                    : Column(
                        children: [
                          Expanded(
                            flex: isPortrait 
                                ? (provider.mode == CalculatorMode.scientific ? 18 : 25) 
                                : (provider.mode == CalculatorMode.programmer ? 32 : 20),
                            child: _buildDisplayArea(context, provider),
                          ),
                          _buildDivider(context, isPortrait),
                          Expanded(
                            flex: isPortrait 
                                ? (provider.mode == CalculatorMode.scientific ? 82 : 75) 
                                : (provider.mode == CalculatorMode.programmer ? 68 : 80),
                            child: _buildButtonGrid(context, provider, isPortrait),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context, bool isPortrait) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Divider(
          height: 2,
          thickness: 2,
          color: colorScheme.tertiary.withValues(alpha: 0.3)),
    );
  }

  Widget _buildDisplayArea(BuildContext context, CalculatorProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isNothing = themeProvider.currentTheme == AppTheme.nothing || themeProvider.currentTheme == AppTheme.nothingLight;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          provider.buttonPress('del');
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
          provider.buttonPress('AC');
        }
      },
      child: Container(
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.only(left: 30, right: 30, bottom: 0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (provider.mode == CalculatorMode.standard)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    provider.operation != '0'
                        ? provider.operation.contains('=')
                            ? provider.operation
                            : '${provider.formatNumber(provider.getNum1)} ${isNothing ? provider.operation.replaceAll('×', '*').replaceAll('÷', '/') : provider.operation}'
                        : '',
                    style: TextStyle(
                      fontSize: 32,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: (Provider.of<ThemeProvider>(context).currentTheme == AppTheme.nothing || Provider.of<ThemeProvider>(context).currentTheme == AppTheme.nothingLight) ? FontWeight.w400 : FontWeight.w400,
                    ),
                  ),
                ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  provider.input,
                  style: TextStyle(
                    fontSize: 64,
                    color: colorScheme.onSurface,
                    fontWeight: (Provider.of<ThemeProvider>(context).currentTheme == AppTheme.nothing || Provider.of<ThemeProvider>(context).currentTheme == AppTheme.nothingLight) ? FontWeight.w400 : FontWeight.w300,
                    height: 1.0,
                  ),
                ),
              ),
              if (provider.mode == CalculatorMode.programmer)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBaseRow(context, provider, 'HEX', BaseMode.hex),
                        const SizedBox(width: 8),
                        _buildBaseRow(context, provider, 'DEC', BaseMode.dec),
                        const SizedBox(width: 8),
                        _buildBaseRow(context, provider, 'OCT', BaseMode.oct),
                        const SizedBox(width: 8),
                        _buildBaseRow(context, provider, 'BIN', BaseMode.bin),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonGrid(BuildContext context, CalculatorProvider provider, bool isPortrait) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (provider.mode == CalculatorMode.standard) ...[
            if (isPortrait) ...[
              buildRow(context, provider, ['AC', 'C', '%', '÷'], forceCircle: true),
              buildRow(context, provider, ['1', '2', '3', '×'], forceCircle: true),
              buildRow(context, provider, ['4', '5', '6', '-'], forceCircle: true),
              buildRow(context, provider, ['7', '8', '9', '+'], forceCircle: true),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CalculatorButton(
                      onTap: () => provider.buttonPress('.'),
                      text: '.',
                      forceCircle: true,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('0'),
                      text: '0',
                      forceCircle: true,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('del'),
                      icon: Icons.backspace_outlined,
                      fontSize: 24,
                      forceCircle: true,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('='),
                      text: '=',
                      fontSize: 34,
                      isOperator: true,
                      forceCircle: true,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Landscape Standard Grid (3 rows x 7 columns)
              buildRow(context, provider, ['AC', 'C', '%', '7', '8', '9', '÷'], forceCircle: false),
              buildRow(context, provider, ['(', ')', '.', '4', '5', '6', '×'], forceCircle: false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CalculatorButton(onTap: () => provider.buttonPress('del'), icon: Icons.backspace_outlined, fontSize: 18, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('+'), text: '+', fontSize: 26, isOperator: true, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('-'), text: '-', fontSize: 26, isOperator: true, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('1'), text: '1', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('2'), text: '2', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('3'), text: '3', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('='), text: '=', fontSize: 26, isOperator: true, forceCircle: false),
                  ],
                ),
              ),
            ],
          ] else if (provider.mode == CalculatorMode.scientific) ...[
            if (isPortrait) ...[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CalculatorButton(
                      onTap: () => provider.toggleAngleMode(),
                      text: provider.isDegrees ? 'DEG' : 'RAD',
                      fontSize: 16,
                      isSecondary: true,
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.toggleInvMode(),
                      text: 'inv',
                      fontSize: 16,
                      isSecondary: true,
                      isActive: provider.isInvMode,
                      forceCircle: false,
                    ),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'asin' : 'sin', displayLabel: provider.isInvMode ? 'sin⁻¹' : 'sin', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'acos' : 'cos', displayLabel: provider.isInvMode ? 'cos⁻¹' : 'cos', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'atan' : 'tan', displayLabel: provider.isInvMode ? 'tan⁻¹' : 'tan', forceCircle: false),
                  ],
                ),
              ),
              buildRow(context, provider, ['ln', 'log', 'sqrt', '^', '!'], forceCircle: false),
              buildRow(context, provider, ['π', 'e', '(', ')', 'x²'], forceCircle: false),
              buildRow(context, provider, ['AC', 'C', '%', '÷'], forceCircle: false),
              buildRow(context, provider, ['1', '2', '3', '×'], forceCircle: false),
              buildRow(context, provider, ['4', '5', '6', '-'], forceCircle: false),
              buildRow(context, provider, ['7', '8', '9', '+'], forceCircle: false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CalculatorButton(
                      onTap: () => provider.buttonPress('.'),
                      text: '.',
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('0'),
                      text: '0',
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('del'),
                      icon: Icons.backspace_outlined,
                      fontSize: 24,
                      forceCircle: false,
                    ),
                    CalculatorButton(
                      onTap: () => provider.buttonPress('='),
                      text: '=',
                      fontSize: 34,
                      isOperator: true,
                      forceCircle: false,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Landscape Scientific Grid
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgBtn(context, provider, 'DEG', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'asin' : 'sin', displayLabel: provider.isInvMode ? 'sin⁻¹' : 'sin', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'acos' : 'cos', displayLabel: provider.isInvMode ? 'cos⁻¹' : 'cos', forceCircle: false),
                    _buildProgBtn(context, provider, provider.isInvMode ? 'atan' : 'tan', displayLabel: provider.isInvMode ? 'tan⁻¹' : 'tan', forceCircle: false),
                    _buildProgBtn(context, provider, 'AC', forceCircle: false),
                    _buildProgBtn(context, provider, 'C', forceCircle: false),
                    _buildProgBtn(context, provider, '%', forceCircle: false),
                    _buildProgBtn(context, provider, '÷', forceCircle: false),
                  ],
                ),
              ),
              buildRow(context, provider, ['ln', 'log', 'sqrt', '^', '7', '8', '9', '×'], forceCircle: false),
              buildRow(context, provider, ['π', 'e', '(', ')', '4', '5', '6', '-'], forceCircle: false),
              buildRow(context, provider, ['x²', '1/x', '!', 'inv', '1', '2', '3', '+'], forceCircle: false),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgBtn(context, provider, 'abs', flex: 1, forceCircle: false),
                    _buildProgBtn(context, provider, 'sgn', flex: 1, forceCircle: false),
                    _buildProgBtn(context, provider, 'ceil', flex: 1, forceCircle: false),
                    _buildProgBtn(context, provider, 'floor', flex: 1, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('0'), text: '0', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('.'), text: '.', fontSize: 21, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('del'), icon: Icons.backspace_outlined, fontSize: 18, forceCircle: false),
                    CalculatorButton(onTap: () => provider.buttonPress('='), text: '=', fontSize: 26, isOperator: true, forceCircle: false),
                  ],
                ),
              ),
            ],
          ] else ...[
            if (isPortrait) ...[
              buildRow(context, provider, ['D', 'E', 'F', 'AC'], forceCircle: true),
              buildRow(context, provider, ['A', 'B', 'C', 'del'], forceCircle: true),
              buildRow(context, provider, ['7', '8', '9', '÷'], forceCircle: true),
              buildRow(context, provider, ['4', '5', '6', '×'], forceCircle: true),
              buildRow(context, provider, ['1', '2', '3', '-'], forceCircle: true),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgBtn(context, provider, '0', forceCircle: false),
                    _buildProgBtn(context, provider, '.', forceCircle: false),
                    _buildProgBtn(context, provider, '=', forceCircle: false),
                    _buildProgBtn(context, provider, '+', forceCircle: false),
                  ],
                ),
              ),
            ] else ...[
              // Landscape Programmer Grid (3 rows x 8 columns)
              buildRow(context, provider, ['E', 'F', '÷', '×', '7', '8', '9', 'AC'], forceCircle: false),
              buildRow(context, provider, ['C', 'D', '+', '-', '4', '5', '6', 'del'], forceCircle: false),
              buildRow(context, provider, ['A', 'B', '=', '.', '1', '2', '3', '0'], forceCircle: false),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildProgBtn(BuildContext context, CalculatorProvider provider, String label, {int flex = 1, bool forceCircle = true, String? displayLabel}) {
    bool isOperator = ['÷', '×', '-', '+', '='].contains(label);
    bool isValid = _isValidDigit(label, provider.baseMode) || provider.mode == CalculatorMode.scientific;

    double fontSize = 28;
    if (isOperator) fontSize = 34;
    if (['sin', 'cos', 'tan', 'log', 'sqrt', 'ln', 'inv', 'abs', 'sgn', 'ceil', 'floor'].contains(label)) fontSize = 20;
    if (label == 'DEG' || label == 'RAD') fontSize = 18;
    if (['(', ')', 'π', 'e', '^', 'x²', '1/x', '!'].contains(label)) fontSize = 24;

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      fontSize *= 0.75;
      if (provider.mode == CalculatorMode.scientific) {
        fontSize *= 0.85;
      }
    }

    if (label == 'DEG') {
      return CalculatorButton(
        flex: flex,
        onTap: () => provider.toggleAngleMode(),
        text: provider.isDegrees ? 'DEG' : 'RAD',
        fontSize: fontSize,
        isSecondary: true,
        forceCircle: forceCircle,
      );
    }

    if (label == 'inv') {
      return CalculatorButton(
        flex: flex,
        onTap: () => provider.toggleInvMode(),
        text: 'inv',
        fontSize: fontSize,
        isSecondary: true,
        isActive: provider.isInvMode,
        forceCircle: forceCircle,
      );
    }

    final isSecondary = ['AC', 'C', '%'].contains(label) || ['sin', 'cos', 'tan', 'asin', 'acos', 'atan', 
    'ln', 'log', 'sqrt', 'abs', 'sgn', 'ceil', 'floor',
    'x²', '1/x', '!', 'π', 'e', '(', ')', '^'].contains(label);

    Color? textColor;
    if (isSecondary) {
      if (['AC', 'C', '%'].contains(label)) {
        textColor = Colors.orangeAccent;
      } else {
        textColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
      }
    }
    if (!isValid) {
      textColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    }

    return CalculatorButton(
      flex: flex,
      onTap: isValid ? () => provider.buttonPress(label) : () {},
      text: displayLabel ?? label,
      fontSize: fontSize,
      isOperator: isOperator,
      isSecondary: isSecondary,
      textColor: textColor,
      forceCircle: forceCircle,
    );
  }

  Widget buildRow(
      BuildContext context, CalculatorProvider provider, List<String> labels, {bool forceCircle = true}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (index) {
          final label = labels[index];
          final isOperator = ['÷', '×', '-', '+', '='].contains(label);
          final isSecondary = ['AC', '%'].contains(label) || (label == 'C' && provider.mode != CalculatorMode.programmer);
          
          final isScientificFunc = ['sin', 'cos', 'tan', 'asin', 'acos', 'atan', 
              'ln', 'log', 'sqrt', 'abs', 'sgn', 'ceil', 'floor',
              'x²', '1/x', '!', 'π', 'e', '(', ')', '^'].contains(label);

          double fontSize = 28;
          if (isOperator) fontSize = 34;
          if (label == 'AC' || label == 'del' || (label == 'C' && provider.mode != CalculatorMode.programmer)) fontSize = 24;
          if (['sin', 'cos', 'tan', 'log', 'sqrt', 'ln', 'inv', 'abs', 'sgn', 'ceil', 'floor'].contains(label)) fontSize = 20;
          if (label == 'DEG' || label == 'RAD') fontSize = 18;
          if (['(', ')', 'π', 'e', '^', 'x²', '1/x', '!'].contains(label)) fontSize = 24;

          if (MediaQuery.of(context).orientation == Orientation.landscape) {
            fontSize *= 0.75;
            if (provider.mode == CalculatorMode.scientific) {
              fontSize *= 0.85;
            }
          }

          bool isActive = false;
          if (isOperator &&
              provider.operation == label &&
              provider.input == '0') {
            isActive = true;
          }
          if (label == 'inv' && provider.isInvMode) {
            isActive = true;
          }

          if (label == 'DEG') {
            return CalculatorButton(
              onTap: () => provider.toggleAngleMode(),
              text: provider.isDegrees ? 'DEG' : 'RAD',
              fontSize: fontSize,
              isSecondary: true,
              forceCircle: forceCircle,
            );
          }

          if (label == 'inv') {
            return CalculatorButton(
              onTap: () => provider.toggleInvMode(),
              text: 'inv',
              fontSize: fontSize,
              isSecondary: true,
              isActive: provider.isInvMode,
              forceCircle: forceCircle,
            );
          }

          Color? textColor;
          if (isSecondary) {
            textColor = Colors.orangeAccent;
          } else if (isScientificFunc) {
            textColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
          }

          bool isValid = _isValidDigit(label, provider.baseMode) || provider.mode == CalculatorMode.standard || provider.mode == CalculatorMode.scientific;
          if (!isValid) {
            // Updated alpha from 0.2 to 0.35 for better disabled contrast
            textColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
          }

          String? displayLabel = label;
          if (label == 'asin') displayLabel = 'sin⁻¹';
          if (label == 'acos') displayLabel = 'cos⁻¹';
          if (label == 'atan') displayLabel = 'tan⁻¹';
          if (label == 'del') displayLabel = null;

          return CalculatorButton(
            onTap: isValid ? () => provider.buttonPress(label) : () {},
            text: displayLabel,
            icon: label == 'del' ? Icons.backspace_outlined : null,
            fontSize: fontSize,
            isOperator: isOperator,
            isSecondary: isSecondary || isScientificFunc,
            isActive: isActive,
            textColor: textColor,
            forceCircle: forceCircle,
          );
        }),
      ),
    );
  }

  bool _isValidDigit(String label, BaseMode mode) {
    if (['AC', 'del', '=', '+', '-', '×', '÷'].contains(label)) return true;
    if (mode == BaseMode.hex) return RegExp(r'^[0-9A-F]$').hasMatch(label);
    if (mode == BaseMode.dec) return RegExp(r'^[0-9]$').hasMatch(label);
    if (mode == BaseMode.oct) return RegExp(r'^[0-7]$').hasMatch(label);
    if (mode == BaseMode.bin) return RegExp(r'^[0-1]$').hasMatch(label);
    return false;
  }

  Widget _buildBaseRow(BuildContext context, CalculatorProvider provider, String label, BaseMode mode) {
    bool isSelected = provider.baseMode == mode;
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () => provider.setBaseMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }



  void _showHistory(BuildContext context, CalculatorProvider provider) {
    final isNothing = Provider.of<ThemeProvider>(context, listen: false).currentTheme == AppTheme.nothing || Provider.of<ThemeProvider>(context, listen: false).currentTheme == AppTheme.nothingLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return GestureDetector(
                onTap: () {}, // Prevent taps on the sheet itself from bubbling up
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 4),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 16.0, top: 4.0, bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            provider.clearHistory();
                            Navigator.pop(context);
                          },
                          icon: isNothing ? const Text('CLR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)) : const Icon(Icons.delete_sweep_rounded, size: 20),
                          label: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.05),
                  ),
                  if (provider.history.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.history.length,
                              itemBuilder: (context, index) {
                              final calculation = provider.history[index];
                              final parts = calculation.split('=');
                              final expression = parts[0].trim();
                              final resultValue = parts.length > 1 ? parts[1].trim() : '';
                              final resultText = resultValue;
                              
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shadowColor: Colors.black.withValues(alpha: 0.1),
                                  color: Theme.of(context).colorScheme.surface,
                                  surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.05),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  child: Row(
                                    children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: isNothing ? const Text('COPY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)) : const Icon(Icons.content_copy_rounded, size: 18),
                                          tooltip: 'Copy result',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.surface,
                                            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                            minimumSize: const Size(40, 40),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            if (resultValue.isNotEmpty) {
                                              Clipboard.setData(ClipboardData(text: resultValue));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Result copied to clipboard'),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: isNothing ? const Text('USE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)) : const Icon(Icons.keyboard_return_rounded, size: 18),
                                          tooltip: 'Insert into calculator',
                                          style: IconButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.surface,
                                            foregroundColor: Theme.of(context).colorScheme.primary,
                                            minimumSize: const Size(40, 40),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            provider.loadHistory(calculation);
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            expression,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          if (resultText.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              resultText,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                ),
                              );
                            },
                          ),
                  ), // Close Padding
                ], // Close children list
              ), // Close ListView
            ), // Close Container
          ); // Close inner GestureDetector
        }, // Close DraggableScrollableSheet builder
        ), // Close DraggableScrollableSheet
        ); // Close outer GestureDetector
      }, // Close showModalBottomSheet builder
    ); // Close showModalBottomSheet
  }

  void _showQuickConverter(BuildContext context, CalculatorProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickConverterScreen(
          initialValue: provider.input.isEmpty || provider.input == 'Error' ? '0' : provider.input,
        ),
      ),
    );
  }
}