import 'package:flutter/material.dart';

class CalculatorProvider extends ChangeNotifier {
  String _input = '0';
  String _operation = '0';
  double num1 = 0;
  double num2 = 0;
  double result = 0;
  bool _isResultDisplayed = false;

  String get input => _input;
  String get operation => _operation;
  double get getNum1 => num1;
  bool get isResultDisplayed => _isResultDisplayed;

  String formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toString();
  }

  void buttonPress(String value) {
    switch (value) {
      case 'AC':
        _clearAll();
        break;
      case 'C':
        _clear();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _handleOperator(value);
        break;
      case 'del':
        _delete();
        break;
      case '.':
        _addDecimal();
        break;
      case '%':
        _percentage();
        break;
      case '=':
        _calculate();
        break;
      default:
        _addNumber(value);
    }
    notifyListeners();
  }

  void _clearAll() {
    _input = '0';
    _operation = '0';
    num1 = 0;
    num2 = 0;
    _isResultDisplayed = false;
  }

  void _clear() {
    _input = '0';
  }

  void _handleOperator(String value) {
    if (_input == 'Error') {
      num1 = 0;
      _input = '0';
      _isResultDisplayed = false;
    }

    if (_operation != '0' && !_isResultDisplayed) {
      num2 = double.tryParse(_input) ?? 0;
      switch (_operation) {
        case '+':
          num1 += num2;
          break;
        case '-':
          num1 -= num2;
          break;
        case '×':
          num1 *= num2;
          break;
        case '÷':
          if (num2 != 0) {
            num1 /= num2;
          } else {
            _input = 'Error';
            _operation = '0';
            _isResultDisplayed = true;
            return;
          }
          break;
      }
    } else if (!_isResultDisplayed) {
      num1 = double.tryParse(_input) ?? 0;
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
      if (_input.isEmpty || _input == '-') {
        _input = '0';
      }
    }
  }

  void _addDecimal() {
    if (_isResultDisplayed || _input == 'Error') {
      _input = '0.';
      _isResultDisplayed = false;
      return;
    }

    if (!_input.contains('.')) {
      _input += '.';
    }
  }

  void _percentage() {
    if (_input == 'Error') {
      _input = '0';
      _isResultDisplayed = false;
      return;
    }

    double number = double.tryParse(_input) ?? 0;
    _input = (number / 100).toString();
    _isResultDisplayed = true;
  }

  void _calculate() {
    if (_operation.contains('=')) {
      return;
    }

    if (_operation != '0') {
      num2 = double.tryParse(_input) ?? 0;
      switch (_operation) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '×':
          result = num1 * num2;
          break;
        case '÷':
          if (num2 != 0) {
            result = num1 / num2;
          } else {
            _input = 'Error';
            _operation = '0';
            _isResultDisplayed = true;
            return;
          }
          break;
      }

      String formattedResult = result
          .toStringAsFixed(10)
          .replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
      String formattedNum1 = formatNumber(num1);
      String formattedNum2 = formatNumber(num2);

      _operation = '$formattedNum1$_operation$formattedNum2=';
      _input = formattedResult;
    } else {
      result = double.tryParse(_input) ?? 0;
    }

    num1 = result;
    num2 = 0;
    _isResultDisplayed = true;
  }

  void _addNumber(String value) {
    if (_input.length >= 9 && !_isResultDisplayed && !_input.contains('.')) {
      return;
    }

    if (_isResultDisplayed || _input == '0') {
      _input = value;
    } else {
      _input += value;
    }

    _isResultDisplayed = false;

    if (_operation.contains('=')) {
      _operation = '0';
    }
  }
}
