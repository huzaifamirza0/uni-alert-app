import 'package:flutter/material.dart';

class EmergencyIdProvider extends ChangeNotifier {
  late int _emergencyId;

  int get emergencyId => _emergencyId;

  void setEmergencyId(int id) {
    _emergencyId = id;
    notifyListeners();
  }
}
