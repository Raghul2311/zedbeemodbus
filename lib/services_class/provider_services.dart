import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/modbus_services.dart';

class ProviderServices extends ChangeNotifier {
  final ModbusServices _modbusService = ModbusServices(ip: "192.168.0.105");
  final List<ParameterModel> _parameters = [];
  List<int> _latestValues = [];
  Timer? _autoRefreshTimer;
  bool _isWriting = false;
  bool _isSwitchLoading = false;

  bool get isSwitchLoading => _isSwitchLoading;
  List<ParameterModel> get parameters => _parameters;
  List<int> get latestValues => _latestValues;

  /// All parameter names + units
  final List<Map<String, String>> allParameters = [
    {"name": "Status", "unit": ""},
    {"name": "Frequency", "unit": "Hz"},
    {"name": "Auto/Manual", "unit": ""},
    {"name": "Flowrate", "unit": "m³/h"},
    {"name": "Water Pressure", "unit": "bar"},
    {"name": "Duct Pressure", "unit": "bar"},
    {"name": "Running Hours 1", "unit": "hr"},
    {"name": "Running Hours 2", "unit": "hr"},
    {"name": "BTU 1", "unit": "kWh"},
    {"name": "BTU 2", "unit": "kWh"},
    {"name": "Water In", "unit": "°C"},
    {"name": "Water Out", "unit": "°C"},
    {"name": "Supply Temp", "unit": "°C"},
    {"name": "Return Temp", "unit": "°C"},
    {"name": "Stop Condition", "unit": ""},
    {"name": "Fire Status", "unit": ""},
    {"name": "Trip Status", "unit": ""},
    {"name": "Filter Status", "unit": ""},
    {"name": "NONC Status", "unit": ""},
    {"name": "Run Status", "unit": ""},
    {"name": "Auto/Manual Status", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Water Value", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Voltage", "unit": "V"},
    {"name": "Current", "unit": "A"},
    {"name": "Power", "unit": "kW"},
    {"name": "Delta T Avg", "unit": "°C"},
    {"name": "Set Temperature", "unit": "°C"},
    {"name": "Min Frequency", "unit": "Hz"},
    {"name": "Max Frequency", "unit": "Hz"},
    {"name": "VAV Number", "unit": ""},
    {"name": "PID Constant", "unit": ""},
    {"name": "Ductset Pressure", "unit": "bar"},
    {"name": "Max FlowRate", "unit": "m³/h"},
    {"name": "Min FlowRate", "unit": "m³/h"},
    {"name": "Pressure Constant", "unit": ""},
    {"name": "Inlet Threshold", "unit": ""},
    {"name": "Actuator Direction", "unit": ""},
    {"name": "Actuator Type", "unit": ""},
    {"name": "Min Act Position", "unit": ""},
    {"name": "Ramp Up Sel", "unit": ""},
    {"name": "Water Delta T", "unit": ""},
    {"name": "Pressure Temp Sel", "unit": "°C"},
    {"name": "N/A", "unit": ""},
    {"name": "Flowmeter Type", "unit": ""},
    {"name": "7 Span", "unit": ""},
    {"name": "6 Span", "unit": ""},
    {"name": "Min Set Temp", "unit": "°C"},
    {"name": "Max Set Temp", "unit": "°C"},
    {"name": "1", "unit": ""},
    {"name": "9600", "unit": ""},
    {"name": "0", "unit": ""},
    {"name": "1", "unit": ""},
    {"name": "Schedule ON/OFF", "unit": ""},
    {"name": "Schedule ON Time", "unit": ""},
    {"name": "Schedule OFF Time", "unit": ""},
    {"name": "Poll Time", "unit": ""},
  ];

  /// Float-type parameters
  final List<String> floatValueNames = [
    "Frequency",
    "Water In",
    "Water Out",
    "Supply Temp",
    "Return Temp",
    "Delta T Avg",
    "Set Temperature",
    "Min Frequency",
    "Max Frequency",
    "Max FlowRate",
    "Min FlowRate",
    "Pressure Constant",
    "Inlet Threshold",
    "Pressure Temp Sel",
    "Min Set Temp",
    "Max Set Temp",
  ];

  /// Get unit by index
  String getUnit(int index) {
    if (index < allParameters.length) {
      return allParameters[index]["unit"] ?? "";
    }
    return "";
  }

  /// Format values based on parameter name + append units
  String getFormattedValue(String name, int rawValue) {
    String value;
    if (name == "Status" ||
        name == "Fire Status" ||
        name == "Schedule ON/OFF") {
      value = rawValue == 1 ? "ON" : "OFF";
    } else if (name == "Auto/Manual Status") {
      value = rawValue == 0
          ? "OFF"
          : rawValue == 1
          ? "AUTO"
          : rawValue == 2
          ? "MANUAL"
          : "--";
    } else if (name == "Actuator Direction") {
      value = rawValue == 0
          ? "Forward"
          : rawValue == 1
          ? "Reverse"
          : "--";
    } else if (floatValueNames.contains(name)) {
      value = (rawValue / 100).toStringAsFixed(2);
    } else {
      value = rawValue.toString();
    }

    // Append unit if available(matches the parameter with units)
    final param = allParameters.firstWhere(
      (p) => p["name"] == name,
      orElse: () => {"unit": ""},
    );
    final unit = param["unit"] ?? "";
    return unit.isNotEmpty ? "$value $unit" : value;
  }

  /// Add parameters (avoids duplicates)
  void addParameters(List<int> indexes, List<Map<String, String>> allParams) {
    for (var i in indexes) {
      if (!_parameters.any((param) => param.registerIndex == i)) {
        _parameters.add(
          ParameterModel(
            text: allParams[i]["name"]!,
            dx: 50,
            dy: 100 + _parameters.length * 60,
            registerIndex: i,
          ),
        );
      }
    }
    notifyListeners();
  }

  // remove parameters function ...
  void removeParameter(int registerIndex) {
    _parameters.removeWhere((param) => param.registerIndex == registerIndex);
    notifyListeners();
  }

  // remove parameter by index ...
  void removeParameterByIndex(int index) {
    if (index >= 0 && index < _parameters.length) {
      _parameters.removeAt(index);
      notifyListeners();
    }
  }

  // update parameter position ..
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

  // get the parameters ...
  Future<void> fetchRegisters() async {
    if (_isWriting) return;
    try {
      _latestValues = await _modbusService.readRegisters(0, 59);
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

  // write parameter by registers ...
  Future<void> writeRegister(int address, int value) async {
    _isWriting = true;
    stopAutoRefresh(); // auto refresh
    try {
      await _modbusService.writeRegister(address, value);
      await Future.delayed(const Duration(milliseconds: 100));
      await fetchRegisters();
    } finally {
      _isWriting = false;
      startAutoRefresh();
    }
  }

  // toggle switch loading ...
  void setswitchLoading(bool loading) {
    _isSwitchLoading = loading;
    notifyListeners();
  }

  // write register by instant ....
  Future<void> writeRegisterInstant(int address, int value) async {
    setswitchLoading(true);
    try {
      await _modbusService.writeRegister(address, value);
    } catch (e) {
      debugPrint("Instant write error: $e");
    } finally {
      setswitchLoading(false);
    }
  }

  // Auto refresh function
  void startAutoRefresh() {
    if (_autoRefreshTimer?.isActive ?? false) return;
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchRegisters(),
    );
  }

  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
  }

  // parameter selection ...
  bool isParameterSelected(int registerIndex) {
    return _parameters.any((param) => param.registerIndex == registerIndex);
  }

  // clear all parameters ...
  void clearParameters() {
    _parameters.clear();
    notifyListeners();
  }
}
