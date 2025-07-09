import 'package:flutter/material.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';

class ProviderServices extends ChangeNotifier {
final List<ParameterModel> _parameters = [];

  List<ParameterModel> get parameters => _parameters;

  void addParameter(String name, {required int index}) {
    _parameters.add(ParameterModel(text: name, dx: 50, dy: 100 + _parameters.length * 60));
    notifyListeners();
  }

  void removeParameter(int index) {
    _parameters.removeAt(index);
    notifyListeners();
  }

  void updatePosition(int index, double dx, double dy) {
    final item = _parameters[index];
    _parameters[index] = ParameterModel(text: item.text, dx: dx, dy: dy);
    notifyListeners();
  }

  void clearParameters() {
    _parameters.clear();
    notifyListeners();
  }
}