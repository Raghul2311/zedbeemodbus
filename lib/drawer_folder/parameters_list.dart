import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/drawer_folder/setting_page.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';

class ParametersList extends StatefulWidget {
  const ParametersList({super.key});

  @override
  State<ParametersList> createState() => _ParametersListState();
}

class _ParametersListState extends State<ParametersList> {
  final String ip = '192.168.0.105';
  final int port = 502;
  final int unitId = 0;
  final int startAddress = 0;
  final int registerCount = 8;
  bool isSaving = false; // loading indicator

  List<int> registerValues = [];
  List<bool> isCheckedList = List.generate(8, (_) => false);
  final TextEditingController valueController = TextEditingController();
  int? selectedRegister;
  String status = "Reading...";

  final List<String> parameterLabels = [
    "Status",
    "Speed",
    "Temperature",
    "Humidity",
    "Pressure",
    "Flow Rate",
    "Setpoint",
    "Error Code",
  ];

  @override
  void initState() {
    super.initState();
    readRegisters();
    // Removed default selection
  }

  Future<void> readRegisters() async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      final request = Uint8List.fromList([
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x06,
        unitId,
        0x03,
        (startAddress >> 8) & 0xFF,
        startAddress & 0xFF,
        (registerCount >> 8) & 0xFF,
        registerCount & 0xFF,
      ]);

      socket.add(request);
      await socket.flush();

      final completer = Completer<List<int>>();
      final List<int> buffer = [];

      socket.listen((data) {
        buffer.addAll(data);
        if (buffer.length >= 6) {
          final int length = (buffer[4] << 8) | buffer[5];
          if (buffer.length >= 6 + length) {
            completer.complete(buffer);
          }
        }
      });

      final response = await completer.future;
      socket.destroy();

      if (response.length >= 9 + registerCount * 2) {
        List<int> values = [];
        for (int i = 0; i < registerCount; i++) {
          int high = response[9 + i * 2];
          int low = response[9 + i * 2 + 1];
          values.add((high << 8) | low);
        }
        setState(() {
          registerValues = values;
          status = "Read ${values.length} registers";
        });
      } else {
        showSnackBar("Invalid response", isError: true);
      }
    } catch (e) {
      showSnackBar("Connection failed: $e", isError: true);
    }
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.green,
      ),
    );
  }

  void saveSelectedParameters() async {
    final provider = Provider.of<ProviderServices>(context, listen: false);

    if (provider.parameters.isEmpty) {
      showSnackBar("No parameters selected", isError: true);
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingPage()),
        );
      });
      return;
    }

    setState(() => isSaving = true);

    try {
      await SharedPrefHelper.saveParameters(provider.parameters);
      await SharedPrefHelper.saveCheckedIndexes(
        provider.parameters.map((e) => e.registerIndex ?? 0).toList(),
      );

      showSnackBar("Parameters saved!");
      Navigator.pop(context);
    } catch (e) {
      showSnackBar("Error saving parameters: $e", isError: true);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  Future<void> writeRegister(int address, int value) async {
    if (address != 0 && address != 1) {
      showSnackBar("Only register 0 and 1 are writable", isError: true);
      return;
    }

    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );

      final request = Uint8List.fromList([
        0x00,
        0x02,
        0x00,
        0x00,
        0x00,
        0x06,
        unitId,
        0x06,
        (address >> 8) & 0xFF,
        address & 0xFF,
        (value >> 8) & 0xFF,
        value & 0xFF,
      ]);

      socket.add(request);
      await socket.flush();

      final completer = Completer<List<int>>();
      final List<int> buffer = [];

      socket.listen((data) {
        buffer.addAll(data);
        if (buffer.length >= 12) {
          completer.complete(buffer);
        }
      });

      final response = await completer.future;
      socket.destroy();

      if (response[7] == 0x06) {
        showSnackBar("Wrote $value to register $address");
        valueController.clear();
        setState(() => selectedRegister = null);
        readRegisters();
      } else {
        showSnackBar("Write failed", isError: true);
      }
    } catch (e) {
      showSnackBar("Write error: $e", isError: true);
    }
  }

  void handleWrite() {
    final valueText = valueController.text.trim();

    if (selectedRegister == null) {
      showSnackBar("Select a register", isError: true);
      return;
    }
    if (valueText.isEmpty) {
      showSnackBar("Enter a value", isError: true);
      return;
    }

    final value = int.tryParse(valueText);
    if (value == null) {
      showSnackBar("Invalid number", isError: true);
      return;
    }

    writeRegister(selectedRegister!, value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modbus Parameter",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(status, style: const TextStyle(fontSize: 18)),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: parameterLabels.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  checkColor: Colors.white,
                  activeColor: AppColors.darkblue,
                  value: isCheckedList[index],
                  title: Text(parameterLabels[index]),
                  subtitle: Text(
                    index < registerValues.length
                        ? "Register $index → ${registerValues[index]}"
                        : "Register $index → --",
                  ),
                  onChanged: (bool? checked) {
                    setState(() {
                      isCheckedList[index] = checked ?? false;
                      if (checked!) {
                        provider.addParameter(
                          parameterLabels[index],
                          index: index,
                        );
                      } else {
                        provider.removeParameter(index);
                      }
                    });
                  },
                );
              },
            ),
          ),
          const Divider(),

          // Write Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                DropdownButton<int>(
                  value: selectedRegister,
                  hint: const Text("Select Register"),
                  items: isCheckedList
                      .asMap()
                      .entries
                      .where(
                        (e) =>
                            e.value &&
                            (e.key == 0 || e.key == 1) &&
                            e.key < registerValues.length,
                      )
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            "Register ${e.key} → ${registerValues[e.key]}",
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedRegister = val),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkblue),
                      ),
                      labelText: "Value",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  width: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkblue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: handleWrite,
                    child: const Text(
                      "Write",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SpacerWidget.size16,
          // Save Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveSelectedParameters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),

              child: isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Save Parameter',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),

          SpacerWidget.size64,
        ],
      ),
    );
  }
}
