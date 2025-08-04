import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/modbus_services.dart';

class ProviderServices extends ChangeNotifier {
  final ModbusServices _modbusService = ModbusServices(ip: "192.168.0.105");

  final List<ParameterModel> _parameters = [];
  List<int> _latestValues = [];
  Timer? _autoRefreshTimer; // auto refresh 5 seconds
  bool _isWriting = false; // boolean for pasuse refresh....

  List<ParameterModel> get parameters => _parameters;
  List<int> get latestValues => _latestValues;

  // add parameter function
  void addParameters(List<int> indexes, List<Map<String, dynamic>> allParams) {
    // _parameters.clear();
    for (var i in indexes) {
      _parameters.add(
        ParameterModel(
          text: allParams[i]["name"]!,
          dx: 50, // Default X position
          dy: 100 + _parameters.length * 60, // Default Y position
          registerIndex: i,
        ),
      );
    }
    notifyListeners();
  }

  // remove parameter function...........
  void removeParameter(int registerIndex) {
    _parameters.removeWhere((param) => param.registerIndex == registerIndex);
    notifyListeners();
  }

  // remove parameter by index.......
  void removeParameterByIndex(int index) {
    if (index >= 0 && index < _parameters.length) {
      _parameters.removeAt(index);
      notifyListeners();
    }
  }

  // update the parmeter position funciton........
  void updatePosition(int index, double dx, double dy) {
    if (index >= 0 && index < _parameters.length) {
      final item = _parameters[index];
      _parameters[index] = ParameterModel(
        text: item.text,
        dx: dx,
        dy: dy,
        registerIndex: item.registerIndex,
        value: item.value,
      );
      notifyListeners();
    }
  }

  // fetch the registers for parameter function...........
  Future<void> fetchRegisters() async {
    if (_isWriting) return;
    try {
      _latestValues = await _modbusService.readRegisters(0, 43);
      for (var param in _parameters) {
        if (param.registerIndex != null &&
            param.registerIndex! < _latestValues.length) {
          param.value = _latestValues[param.registerIndex!].toString();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching registers: $e");
    }
  }

  // write parameter by register
  Future<void> writeRegister(int address, int value) async {
    _isWriting = true;
    stopAutoRefresh();
    try {
      await _modbusService.writeRegister(address, value);
      await Future.delayed(const Duration(milliseconds: 100));
      await fetchRegisters();
    } finally {
      _isWriting = false;
      startAutoRefresh();
    }
  }

  // refresh every 5 second .........
  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchRegisters();
    });
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  // selection of parmeters ........
  bool isParameterSelected(int registerIndex) {
    return _parameters.any((param) => param.registerIndex == registerIndex);
  }

  // clear all the parmeter
  void clearParameters() {
    _parameters.clear();
    notifyListeners();
  }
}
