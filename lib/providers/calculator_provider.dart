// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

enum CalculatorMode { standard, programmer, scientific, age }
enum BaseMode { hex, dec, oct, bin }

class CalculatorProvider extends ChangeNotifier {
  String _input = '0';
  String _operation = '0';
  Decimal num1 = Decimal.zero;
  Decimal num2 = Decimal.zero;
  Decimal result = Decimal.zero;
  bool _isResultDisplayed = false;
  final List<String> _history = [];
  CalculatorMode _mode = CalculatorMode.standard;
  BaseMode _baseMode = BaseMode.dec;
  bool _isDegrees = true; // Scientific mode angle
  bool _isInvMode = false; // Scientific mode inverse functions

  String get input => _input;
  String get operation => _operation;
  Decimal get getNum1 => num1;
  bool get isResultDisplayed => _isResultDisplayed;
  List<String> get history => _history;
  CalculatorMode get mode => _mode;
  BaseMode get baseMode => _baseMode;
  bool get isDegrees => _isDegrees;
  bool get isInvMode => _isInvMode;

  void setMode(CalculatorMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      _baseMode = BaseMode.dec;
      _clearAll();
      notifyListeners();
    }
  }

  void toggleAngleMode() {
    _isDegrees = !_isDegrees;
    notifyListeners();
  }

  void toggleInvMode() {
    _isInvMode = !_isInvMode;
    notifyListeners();
  }

  void setBaseMode(BaseMode newBase) {
    if (_input == 'Error') return;
    
    int decValue = 0;
    try {
      if (_baseMode == BaseMode.hex) { decValue = int.parse(_input, radix: 16); }
      else if (_baseMode == BaseMode.oct) { decValue = int.parse(_input, radix: 8); }
      else if (_baseMode == BaseMode.bin) { decValue = int.parse(_input, radix: 2); }
      else { decValue = int.parse(_input); }
    } catch (_) { }

    _baseMode = newBase;
    
    if (_baseMode == BaseMode.hex) { _input = decValue.toRadixString(16).toUpperCase(); }
    else if (_baseMode == BaseMode.oct) { _input = decValue.toRadixString(8); }
    else if (_baseMode == BaseMode.bin) { _input = decValue.toRadixString(2); }
    else { _input = decValue.toString(); }
    
    notifyListeners();
  }


  Decimal _parseInput(String input) {
    if (_mode == CalculatorMode.programmer) {
      int decValue = 0;
      try {
        if (_baseMode == BaseMode.hex) { decValue = int.parse(input, radix: 16); }
        else if (_baseMode == BaseMode.oct) { decValue = int.parse(input, radix: 8); }
        else if (_baseMode == BaseMode.bin) { decValue = int.parse(input, radix: 2); }
        else { decValue = int.parse(input); }
      } catch (_) { }
      return Decimal.parse(decValue.toString());
    }
    return Decimal.tryParse(input) ?? Decimal.zero;
  }

  String formatNumber(Decimal number) {
    if (_mode == CalculatorMode.programmer) {
      int val = number.toDouble().toInt();
      if (_baseMode == BaseMode.hex) return val.toRadixString(16).toUpperCase();
      if (_baseMode == BaseMode.oct) return val.toRadixString(8);
      if (_baseMode == BaseMode.bin) return val.toRadixString(2);
      return val.toString();
    }
    return number.toString();
  }

  void buttonPress(String value) {
    if (_mode == CalculatorMode.scientific) {
      _handleScientificPress(value);
      notifyListeners();
      return;
    }

    if (value == 'AC' || (value == 'C' && _mode != CalculatorMode.programmer)) {
      _clear();
      if (value == 'AC') _clearAll();
    } else if (value == 'del') {
      _delete();
    } else if (value == '%') {
      _percentage();
    } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
      _handleOperator(value);
    } else if (value == '=') {
      _calculate();
    } else if (value == '.') {
      if (_mode != CalculatorMode.programmer) _addDecimal();
    } else {
      _addNumber(value);
    }
    notifyListeners();
  }

  void _handleScientificPress(String value) {
    if (value == 'AC') {
      _clearAll();
      return;
    }
    if (value == 'C') {
      _input = '0';
      _isResultDisplayed = false;
      return;
    }
    
    if (value == 'del') {
      if (_isResultDisplayed || _input == 'Error') {
        _input = '0';
        _isResultDisplayed = false;
        return;
      }
      if (_input.isNotEmpty && _input != '0') {
        _input = _input.substring(0, _input.length - 1);
        if (_input.isEmpty) _input = '0';
      }
      return;
    }

    if (value == '=') {
      _evaluateScientific();
      return;
    }

    if (_isResultDisplayed || _input == 'Error' || _input == '0') {
      // If result is displayed and user types operator, append to result
      if (_isResultDisplayed && ['+', '-', '×', '÷', '^', 'x²'].contains(value)) {
        _isResultDisplayed = false;
      } else {
        _input = '';
        _isResultDisplayed = false;
      }
    }

    switch (value) {
      case 'sin': _input += 'sin('; break;
      case 'cos': _input += 'cos('; break;
      case 'tan': _input += 'tan('; break;
      case 'asin': _input += 'arcsin('; break;
      case 'acos': _input += 'arccos('; break;
      case 'atan': _input += 'arctan('; break;
      case 'abs': _input += 'abs('; break;
      case 'sgn': _input += 'sgn('; break;
      case 'ceil': _input += 'ceil('; break;
      case 'floor': _input += 'floor('; break;
      case 'ln': _input += 'ln('; break;
      case 'log': _input += 'log('; break;
      case 'sqrt': _input += 'sqrt('; break;
      case 'x²': _input += '^2'; break;
      case '1/x': _input += '1/('; break;
      case '!': _input += '!'; break;
      case '%': _input += '%'; break;
      case 'π': _input += 'pi'; break;
      case 'e': _input += 'e'; break;
      case '(': _input += '('; break;
      case ')': _input += ')'; break;
      case '×': _input += '×'; break;
      case '÷': _input += '÷'; break;
      case 'inv': toggleInvMode(); return; // state toggle
      default: _input += value;
    }
  }

  void _evaluateScientific() {
    if (_input.isEmpty || _input == 'Error') return;

    try {
      String expressionToParse = _input.replaceAll('×', '*').replaceAll('÷', '/');
      
      // Auto-close open parentheses
      int openBraces = expressionToParse.split('(').length - 1;
      int closeBraces = expressionToParse.split(')').length - 1;
      if (openBraces > closeBraces) {
        expressionToParse += ')' * (openBraces - closeBraces);
      }
      
      if (_isDegrees) {
        expressionToParse = _applyDegreeConversion(expressionToParse);
      }
      
      Parser p = Parser();
      Expression exp = p.parse(expressionToParse);
      
      ContextModel cm = ContextModel();
      cm.bindVariable(Variable('pi'), Number(math.pi));
      cm.bindVariable(Variable('e'), Number(math.e));
      
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      
      // Clean up small floating point errors
      if (eval.abs() < 1e-10) eval = 0.0;
      
      String resultStr = eval.toString();
      if (resultStr.endsWith('.0')) {
        resultStr = resultStr.substring(0, resultStr.length - 2);
      }
      
      _history.insert(0, '$_input = $resultStr');
      _input = resultStr;
      _isResultDisplayed = true;
      
    } catch (e) {
      _input = 'Error';
      _isResultDisplayed = true;
    }
  }

  void _clearAll() {
    _input = '0';
    _operation = '0';
    num1 = Decimal.zero;
    num2 = Decimal.zero;
    _isResultDisplayed = false;
  }

  void _clear() {
    _input = '0';
  }

  void _handleOperator(String value) {
    if (_input == 'Error') {
      num1 = Decimal.zero;
      _input = '0';
      _isResultDisplayed = false;
    }

    if (_operation != '0' && !_isResultDisplayed) {
      num2 = _parseInput(_input);
      switch (_operation) {
        case '+': num1 += num2; break;
        case '-': num1 -= num2; break;
        case '×': num1 *= num2; break;
        case '÷':
          if (num2 != Decimal.zero) {
            num1 = (num1 / num2).toDecimal(scaleOnInfinitePrecision: 10);
          } else {
            _input = 'Error'; _operation = '0'; _isResultDisplayed = true; return;
          }
          break;
      }
    } else if (!_isResultDisplayed) {
      num1 = _parseInput(_input);
    }

    _input = '0';
    _operation = value;
    _isResultDisplayed = false;
  }

  void _delete() {
    if (_isResultDisplayed || _input == 'Error') {
      _input = '0';
      _isResultDisplayed = false;
      return;
    }

    if (_input.isNotEmpty && _input != '0') {
      _input = _input.substring(0, _input.length - 1);
      if (_input.isEmpty || _input == '-') _input = '0';
    }
  }

  void _addDecimal() {
    if (_isResultDisplayed || _input == 'Error') {
      _input = '0.';
      _isResultDisplayed = false;
      return;
    }

    if (!_input.contains('.')) _input += '.';
  }

  void _percentage() {
    if (_input == 'Error') {
      _input = '0';
      _isResultDisplayed = false;
      return;
    }

    Decimal number = _parseInput(_input);
    _input = (number / Decimal.parse('100')).toDecimal(scaleOnInfinitePrecision: 10).toString();
    _isResultDisplayed = true;
  }

  void _calculate() {
    if (_operation.contains('=')) return;

    if (_operation != '0') {
      num2 = _parseInput(_input);
      switch (_operation) {
        case '+': result = num1 + num2; break;
        case '-': result = num1 - num2; break;
        case '×': result = num1 * num2; break;
        case '÷':
          if (num2 != Decimal.zero) {
            result = (num1 / num2).toDecimal(scaleOnInfinitePrecision: 10);
          } else {
            _input = 'Error'; _operation = '0'; _isResultDisplayed = true; return;
          }
          break;
      }

      String formattedResult = formatNumber(result);
      String formattedNum1 = formatNumber(num1);
      String formattedNum2 = formatNumber(num2);

      String calculation = '$formattedNum1 $_operation $formattedNum2 = $formattedResult';
      _history.insert(0, calculation);

      _operation = '$formattedNum1$_operation$formattedNum2=';
      _input = formattedResult;
    } else {
      result = _parseInput(_input);
    }

    num1 = result;
    num2 = Decimal.zero;
    _isResultDisplayed = true;
  }

  void loadHistory(String calculation) {
    List<String> parts = calculation.split(' = ');
    if (parts.length == 2) {
      _input = parts[1];
      _operation = '0';
      _isResultDisplayed = true;
      num1 = _parseInput(_input);
      num2 = Decimal.zero;
      notifyListeners();
    }
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void _addNumber(String value) {
    if (_input.length >= 15 && !_isResultDisplayed && !_input.contains('.')) return;

    if (_isResultDisplayed || _input == '0') {
      _input = value;
    } else {
      _input += value;
    }

    _isResultDisplayed = false;
    if (_operation.contains('=')) _operation = '0';
  }

  /// Finds the matching closing parenthesis for the opening '(' at [startIndex].
  /// Returns the index of the matching ')' or -1 if not found.
  int _findMatchingParen(String str, int startIndex) {
    int depth = 0;
    for (int i = startIndex; i < str.length; i++) {
      if (str[i] == '(') depth++;
      if (str[i] == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }

  /// Wraps trig function arguments with degree-to-radian conversion.
  /// Handles nested parentheses correctly.
  String _applyDegreeConversion(String expr) {
    // Process sin, cos, tan -> wrap argument with (pi/180)*
    for (final func in ['sin', 'cos', 'tan']) {
      String result = '';
      int i = 0;
      while (i < expr.length) {
        // Check if we're at a trig function (not arcsin/arccos/arctan)
        if (expr.startsWith(func, i) && 
            (i == 0 || !RegExp(r'[a-zA-Z]').hasMatch(expr[i - 1])) &&
            !expr.startsWith('arc$func', i > 2 ? i - 3 : 0)) {
          int parenStart = i + func.length;
          if (parenStart < expr.length && expr[parenStart] == '(') {
            int parenEnd = _findMatchingParen(expr, parenStart);
            if (parenEnd != -1) {
              String arg = expr.substring(parenStart + 1, parenEnd);
              result += '$func((pi/180)*($arg))';
              i = parenEnd + 1;
              continue;
            }
          }
        }
        result += expr[i];
        i++;
      }
      expr = result;
    }

    // Process arcsin, arccos, arctan -> wrap result with (180/pi)*
    for (final func in ['arcsin', 'arccos', 'arctan']) {
      String result = '';
      int i = 0;
      while (i < expr.length) {
        if (expr.startsWith(func, i) &&
            (i == 0 || !RegExp(r'[a-zA-Z]').hasMatch(expr[i - 1]))) {
          int parenStart = i + func.length;
          if (parenStart < expr.length && expr[parenStart] == '(') {
            int parenEnd = _findMatchingParen(expr, parenStart);
            if (parenEnd != -1) {
              String arg = expr.substring(parenStart + 1, parenEnd);
              result += '((180/pi)*$func($arg))';
              i = parenEnd + 1;
              continue;
            }
          }
        }
        result += expr[i];
        i++;
      }
      expr = result;
    }

    return expr;
  }
}
