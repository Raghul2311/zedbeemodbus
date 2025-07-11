import 'dart:async';
import 'dart:io';
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
  final int registerCount = 10;
  bool isSaving = false; // loading indicator

  List<int> registerValues = [];
  List<bool> isCheckedList = List.generate(11, (_) => false);
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
    "BTU",
    "BTS",
  ];

  @override
  void initState() {
    super.initState();
    readRegisters();
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
    // only allow register 0 and 1
    if (address != 0 && address != 1) {
      showSnackBar("Only register 0 and 1 are writable", isError: true);
      return;
    }

    // register enforce 0 or 1 only....
    if (address == 0 && (value != 0 && value != 1)) {
      showSnackBar(
        "Status register only accepts 0 (Off) or 1 (On)",
        isError: true,
      );
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

      // Validate function code and echo values
      final functionCode = response[7];
      final responseAddress = (response[8] << 8) | response[9];
      final responseValue = (response[10] << 8) | response[11];

      if (functionCode == 0x06 &&
          responseAddress == address &&
          responseValue == value) {
        valueController.clear();
        setState(() {
          selectedRegister = null;
        });

        // show ON/OFF message if writing to "Status" register
        if (address == 0) {
          showSnackBar(
            value == 1 ? "Device is ON" : "Device is OFF",
            isError: false,
          );
        } else {
          showSnackBar("Successfully wrote $value to register $address");
        }
        await Future.delayed(const Duration(milliseconds: 300));
        readRegisters();
      } else {
        showSnackBar("Write failed: Invalid response", isError: true);
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
      body: Stack(
        children: [
          // Main Body Column
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(status, style: const TextStyle(fontSize: 18)),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
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
              const SizedBox(height: 150),
            ],
          ),
          // Floating Container Positioned at Bottom
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
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
                        onChanged: (val) =>
                            setState(() => selectedRegister = val),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: "Value",
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: handleWrite,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkblue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Write",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveSelectedParameters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                              "Save Parameter",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
