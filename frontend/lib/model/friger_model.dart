import 'package:flutter/foundation.dart';

class FridgeModel extends ChangeNotifier {
  Map<String, dynamic>? _currentFridge;

  Map<String, dynamic>? get currentFridge => _currentFridge;

  void setFridge(Map<String, dynamic>? fridge) {
    _currentFridge = fridge;
    notifyListeners();
  }
}
