import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/modbus_services.dart';

class ProviderServices extends ChangeNotifier {
  final ModbusServices _modbusService = ModbusServices(ip: "192.168.0.105");

  final List<ParameterModel> _parameters = [];
  List<int> _latestValues = [];
  Timer? _autoRefreshTimer;

  List<ParameterModel> get parameters => _parameters;
  List<int> get latestValues => _latestValues;

  void addParameter(String name, {required int index}) {
    if (!_parameters.any((param) => param.registerIndex == index)) {
      _parameters.add(
        ParameterModel(
          text: name,
          dx: 50,
          dy: 100 + _parameters.length * 60,
          registerIndex: index,
        ),
      );
      notifyListeners();
    }
  }

  void removeParameter(int registerIndex) {
    _parameters.removeWhere((param) => param.registerIndex == registerIndex);
    notifyListeners();
  }

  void removeParameterByIndex(int index) {
    if (index >= 0 && index < _parameters.length) {
      _parameters.removeAt(index);
      notifyListeners();
    }
  }

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

  Future<void> fetchRegisters() async {
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

  Future<void> writeRegister(int address, int value) async {
    await _modbusService.writeRegister(address, value);
    await fetchRegisters();
  }

  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchRegisters();
    });
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  bool isParameterSelected(int registerIndex) {
    return _parameters.any((param) => param.registerIndex == registerIndex);
  }

  void clearParameters() {
    _parameters.clear();
    notifyListeners();
  }
}
