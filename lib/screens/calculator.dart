import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calculator_button.dart';

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<CalculatorProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        provider.operation != '0'
                            ? provider.operation.contains('=')
                                ? provider.operation
                                : '${provider.formatNumber(provider.getNum1)} ${provider.operation}'
                            : '',
                        style: TextStyle(
                          fontSize: 48,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        provider.input,
                        style: TextStyle(
                          fontSize: 96,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w300,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Divider(
                  thickness: 2,
                  color: colorScheme.tertiary.withValues(alpha: 0.3)),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    buildRow(context, provider, ['AC', 'C', '%', '÷']),
                    buildRow(context, provider, ['1', '2', '3', '×']),
                    buildRow(context, provider, ['4', '5', '6', '-']),
                    buildRow(context, provider, ['7', '8', '9', '+']),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CalculatorButton(
                            onTap: () => provider.buttonPress('.'),
                            text: '.',
                          ),
                          CalculatorButton(
                            onTap: () => provider.buttonPress('0'),
                            text: '0',
                          ),
                          CalculatorButton(
                            onTap: () => provider.buttonPress('del'),
                            icon: Icons.backspace_outlined,
                          ),
                          CalculatorButton(
                            onTap: () => provider.buttonPress('='),
                            text: '=',
                            fontSize: 40,
                            isOperator: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildRow(
      BuildContext context, CalculatorProvider provider, List<String> labels) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(labels.length, (index) {
          final label = labels[index];
          final isOperator = ['÷', '×', '-', '+'].contains(label);
          final isSecondary = ['AC', 'C', '%'].contains(label);

          double fontSize = 32;
          if (isOperator) fontSize = 40;
          if (label == 'AC' || label == 'C') fontSize = 28;

          bool isActive = false;
          if (isOperator &&
              provider.operation == label &&
              provider.input == '0') {
            isActive = true;
          }

          Color? textColor;
          if (isSecondary) {
            textColor = Colors.orangeAccent;
          }

          return CalculatorButton(
            onTap: () => provider.buttonPress(label),
            text: label,
            fontSize: fontSize,
            isOperator: isOperator,
            isSecondary: isSecondary,
            isActive: isActive,
            textColor: textColor,
          );
        }),
      ),
    );
  }
}

