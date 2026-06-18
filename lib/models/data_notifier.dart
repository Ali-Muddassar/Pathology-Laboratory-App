import 'package:flutter/material.dart';

class DataNotifier {
  static VoidCallback? _onDataChanged;

  static void setListener(VoidCallback callback) {
    _onDataChanged = callback;
  }

  static void removeListener() {
    _onDataChanged = null;
  }

  static void notify() {
    _onDataChanged?.call();
  }
}
