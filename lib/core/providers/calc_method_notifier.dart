import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the selected prayer calculation method and notifies listeners
/// whenever it changes (e.g. from SettingsScreen).
class CalcMethodNotifier extends ChangeNotifier {
  static const _key = 'calc_method';
  static const _defaultMethod = 'الهيئة العامة المصرية للمساحة (شمال أفريقيا)';

  String _selectedMethod = _defaultMethod;
  String get selectedMethod => _selectedMethod;

  CalculationParameters get params => _paramsFrom(_selectedMethod);

  CalcMethodNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedMethod = prefs.getString(_key) ?? _defaultMethod;
    notifyListeners();
  }

  Future<void> setMethod(String method) async {
    _selectedMethod = method;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, method);
  }

  static CalculationParameters _paramsFrom(String method) {
    if (method.contains('طريقة المغرب')) {
      return CalculationMethodParameters.morocco();
    } else if (method.contains('أم القرى')) {
      return CalculationMethodParameters.ummAlQura();
    } else if (method.contains('رابطة العالم الإسلامي')) {
      return CalculationMethodParameters.muslimWorldLeague();
    } else {
      // Default: Egyptian/North Africa (Algeria)
      return CalculationMethodParameters.egyptian();
    }
  }
}
