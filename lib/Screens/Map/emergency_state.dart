import 'package:flutter/material.dart';

class EmergencyStatusProvider extends ChangeNotifier {
  bool _isEmergency = false;

  bool get  isEmergency =>  _isEmergency;

  void setEmergencyStatus(bool value) {
    _isEmergency = value;
    notifyListeners();
  }
}
