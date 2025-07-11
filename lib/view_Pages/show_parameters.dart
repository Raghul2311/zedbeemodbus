// import 'package:flutter/material.dart';
// import 'package:newpro/fields/shared_pref_helper.dart';
// import 'package:newpro/model_folder/parameters_model.dart';

// class ParameterSelectionPage extends StatefulWidget {
//   const ParameterSelectionPage({super.key});

//   @override
//   State<ParameterSelectionPage> createState() => _ParameterSelectionPageState();
// }

// class _ParameterSelectionPageState extends State<ParameterSelectionPage> {
//   final List<String> parameters = [
//     'Flow meter',
//     'Water Temperature',
//     'BTU',
//     'Power',
//     'Voltage',
//     'Current',
//   ];

//   List<String> selectedParameters = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadSelectedParameters();
//   }

//   Future<void> _loadSelectedParameters() async {
//     final saved = await SharedPrefHelper.getParameters();
//     setState(() {
//       selectedParameters = saved.map((e) => e.text).toList();
//     });
//   }

//   void _onSave() {
//     final parameterModels = selectedParameters
//         .map((text) => ParameterModel(text: text, dx: 50, dy: 100))
//         .toList();

//     SharedPrefHelper.saveParameters(parameterModels);
//     Navigator.pop(context, true); // indicate success
//   }

//   void _onCancel() {
//     Navigator.pop(context, false); // discard changes
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Select Parameters",
//           style: TextStyle(
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: parameters.length,
//               itemBuilder: (context, index) {
//                 final item = parameters[index];
//                 final isChecked = selectedParameters.contains(item);
//                 return CheckboxListTile(
//                   title: Text(item),
//                   value: isChecked,
//                   onChanged: (bool? selected) {
//                     setState(() {
//                       if (selected!) {
//                         selectedParameters.add(item);
//                       } else {
//                         selectedParameters.remove(item);
//                       }
//                     });
//                   },
//                 );
//               },
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(onPressed: _onCancel, child: const Text("Cancel")),
//               ElevatedButton(onPressed: _onSave, child: const Text("Save")),
//               const SizedBox(width: 16),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// class ModbusReadWriteScreen extends StatefulWidget {
//   const ModbusReadWriteScreen({super.key});

//   @override
//   State<ModbusReadWriteScreen> createState() => _ModbusReadWriteScreenState();
// }

// class _ModbusReadWriteScreenState extends State<ModbusReadWriteScreen> {
//   String status = "Reading...";
//   List<int> registerValues = [];

//   final String ip = '192.168.0.105';
//   final int port = 502;
//   final int unitId = 0;
//   final int startAddress = 0;
//   final int registerCount = 8;

//   final TextEditingController valueController = TextEditingController();
//   int? selectedRegister; // null means nothing selected

//   @override
//   void initState() {
//     super.initState();
//     readRegisters();
//   }

//   Future<void> readRegisters() async {
//     try {
//       final socket = await Socket.connect(
//         ip,
//         port,
//         timeout: const Duration(seconds: 5),
//       );

//       final request = Uint8List.fromList([
//         0x00,
//         0x01,
//         0x00,
//         0x00,
//         0x00,
//         0x06,
//         unitId,
//         0x03,
//         (startAddress >> 8) & 0xFF,
//         startAddress & 0xFF,
//         (registerCount >> 8) & 0xFF,
//         registerCount & 0xFF,
//       ]);

//       socket.add(request);
//       await socket.flush();

//       final completer = Completer<List<int>>();
//       final List<int> buffer = [];

//       socket.listen((data) {
//         buffer.addAll(data);
//         if (buffer.length >= 6) {
//           final int length = (buffer[4] << 8) | buffer[5];
//           final int expectedLength = 6 + length;
//           if (buffer.length >= expectedLength) {
//             completer.complete(buffer);
//           }
//         }
//       });

//       final response = await completer.future;
//       socket.destroy();

//       if (response.length >= 9 + registerCount * 2) {
//         List<int> values = [];
//         for (int i = 0; i < registerCount; i++) {
//           int high = response[9 + i * 2];
//           int low = response[9 + i * 2 + 1];
//           values.add((high << 8) | low);
//         }
//         setState(() {
//           registerValues = values;
//           status = "Read ${values.length} registers";
//         });
//       } else {
//         showSnackBar("Invalid response size", isError: true);
//       }
//     } catch (e) {
//       showSnackBar("Connection error: $e", isError: true);
//     }
//   }

//   Future<void> writeRegister(int address, int value) async {
//     if (address != 0 && address != 1) {
//       showSnackBar("Only register 0 and 1 are writable", isError: true);
//       return;
//     }

//     try {
//       final socket = await Socket.connect(
//         ip,
//         port,
//         timeout: const Duration(seconds: 5),
//       );

//       final request = Uint8List.fromList([
//         0x00,
//         0x02,
//         0x00,
//         0x00,
//         0x00,
//         0x06,
//         unitId,
//         0x06,
//         (address >> 8) & 0xFF,
//         address & 0xFF,
//         (value >> 8) & 0xFF,
//         value & 0xFF,
//       ]);

//       socket.add(request);
//       await socket.flush();

//       final completer = Completer<List<int>>();
//       final List<int> buffer = [];

//       socket.listen((data) {
//         buffer.addAll(data);
//         if (buffer.length >= 12) {
//           completer.complete(buffer);
//         }
//       });

//       final response = await completer.future;
//       socket.destroy();

//       if (response[7] == 0x06) {
//         setState(() {
//           status = "Wrote $value to register $address";
//           valueController.clear();
//           selectedRegister = null;
//         });

//         showSnackBar("Successfully wrote $value to register $address");
//         readRegisters(); // refresh data
//       } else {
//         showSnackBar("Write failed (unexpected response)", isError: true);
//       }
//     } catch (e) {
//       showSnackBar("Write error: $e", isError: true);
//     }
//   }

//   void handleWrite() {
//     final valueText = valueController.text.trim();
//     if (selectedRegister == null) {
//       showSnackBar("Please select a register", isError: true);
//       return;
//     }
//     if (valueText.isEmpty) {
//       showSnackBar("Please enter a value", isError: true);
//       return;
//     }

//     final value = int.tryParse(valueText);
//     if (value == null) {
//       showSnackBar("Invalid value format", isError: true);
//       return;
//     }

//     writeRegister(selectedRegister!, value);
//   }

//   void showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Modbus TCP Read/Write")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(status, style: const TextStyle(fontSize: 18)),
//             const SizedBox(height: 20),

//             Expanded(
//               child: ListView.builder(
//                 itemCount: registerValues.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     leading: Text("Reg ${startAddress + index}"),
//                     title: Text("${registerValues[index]}"),
//                   );
//                 },
//               ),
//             ),

//             const Divider(),
//             Row(
//               children: [
//                 DropdownButton<int>(
//                   value: selectedRegister,
//                   hint: const Text("Select Register"),
//                   items: const [
//                     DropdownMenuItem(value: 0, child: Text("Register 0")),
//                     DropdownMenuItem(value: 1, child: Text("Register 1")),
//                   ],
//                   onChanged: (value) {
//                     setState(() => selectedRegister = value);
//                   },
//                 ),
//                 const SizedBox(width: 10),

//                 Expanded(
//                   child: TextField(
//                     controller: valueController,
//                     decoration: const InputDecoration(labelText: "Value"),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 10),

//                 ElevatedButton(
//                   onPressed: handleWrite,
//                   child: const Text("Write"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';

void main() {
  runApp(const MaterialApp(home: ModbusReadWriteScreen()));
}

class ModbusReadWriteScreen extends StatefulWidget {
  const ModbusReadWriteScreen({super.key});

  @override
  State<ModbusReadWriteScreen> createState() => _ModbusReadWriteScreenState();
}

class _ModbusReadWriteScreenState extends State<ModbusReadWriteScreen> {
  String status = "Reading...";
  List<int> registerValues = [];

  final String ip = '192.168.0.105';
  final int port = 502;
  final int unitId = 0;
  final int startAddress = 0;
  final int registerCount = 4;

  final TextEditingController valueController = TextEditingController();
  int? selectedRegister;

  // Labels and checkbox state
  final List<String> parameterLabels = [
    "Status",
    "Frequency",
    "Auto/Manual",
    "Flowrate",
    "Water Pressure",
    "Running Hours",
    "Running Hours",
    "BTU",
    "BTU",
    "Water In"
    "Water Out"
    "Supply Temperature"
    "Return Temperature"
    "Trip Status"
    "Filter Status"
    "Run Status"
    "Auto Manual Status"
    "Set Temperature"
  ];
  List<bool> isCheckedList = List.generate(8, (_) => false);

  @override
  void initState() {
    super.initState();
    readRegisters();
    loadCheckedIndexes();
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
          status = "Total ${values.length} registers";
        });
      } else {
        showSnackBar("Invalid response size", isError: true);
      }
    } catch (e) {
      showSnackBar("Connection error: $e", isError: true);
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
        showSnackBar("Successfully wrote $value to register $address");
        valueController.clear();
        setState(() => selectedRegister = null);
        readRegisters();
      } else {
        showSnackBar("Write failed (unexpected response)", isError: true);
      }
    } catch (e) {
      showSnackBar("Write error: $e", isError: true);
    }
  }

  void handleWrite() {
    final valueText = valueController.text.trim();
    if (selectedRegister == null) {
      showSnackBar("Please select a register", isError: true);
      return;
    }
    if (valueText.isEmpty) {
      showSnackBar("Please enter a value", isError: true);
      return;
    }

    final value = int.tryParse(valueText);
    if (value == null) {
      showSnackBar("Invalid value format", isError: true);
      return;
    }

    writeRegister(selectedRegister!, value);
  }

  void cancelSelection() {
    valueController.clear();
    setState(() => selectedRegister = null);
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void saveSelectedParameters() async {
    List<ParameterModel> selectedParams = [];

    for (int i = 0; i < isCheckedList.length; i++) {
      if (isCheckedList[i]) {
        selectedParams.add(
          ParameterModel(
            text: parameterLabels[i],
            dx: 0,
            dy: 0,
            registerIndex: i,
          ),
        );
      }
    }

    if (selectedParams.isEmpty) {
      showSnackBar("No parameters selected to save", isError: true);
      return;
    }

    await SharedPrefHelper.saveParameters(selectedParams);
    showSnackBar("Selected parameters saved!");
  }

  void loadCheckedIndexes() async {
    List<int> checkedIndexes = await SharedPrefHelper.getCheckedIndexes();
    setState(() {
      for (int i = 0; i < isCheckedList.length; i++) {
        isCheckedList[i] = checkedIndexes.contains(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modbus TCP Read/Write")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Parameter list with checkboxes
            Expanded(
              child: ListView.builder(
                itemCount: registerValues.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: isCheckedList[index],
                    onChanged: (bool? checked) async {
                      setState(() => isCheckedList[index] = checked ?? false);
                      // save the selected parameter
                      List<int> checkedIndexes = [];
                      for (int i = 0; i < isCheckedList.length; i++) {
                        if (isCheckedList[i]) checkedIndexes.add(i);
                      }
                      await SharedPrefHelper.saveCheckedIndexes(checkedIndexes);
                    },
                    title: Text(parameterLabels[index]),
                    subtitle: Text(
                      "Register ${startAddress + index} → ${registerValues[index]}",
                    ),
                    secondary: const Icon(Icons.memory),
                  );
                },
              ),
            ),

            const Divider(),

            Row(
              children: [
                DropdownButton<int>(
                  value: selectedRegister,
                  hint: const Text("Select Register"),
                  items: isCheckedList
                      .asMap()
                      .entries
                      .where((entry) => entry.value)
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text("Register ${entry.key}"),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedRegister = value);
                  },
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: valueController,
                    decoration: const InputDecoration(labelText: "Value"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: handleWrite,
                  child: const Text("Write"),
                ),
                const SizedBox(width: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: cancelSelection,
                  child: const Text("Cancel"),
                ),
                ElevatedButton.icon(
                  onPressed: saveSelectedParameters,
                  icon: const Icon(Icons.save),
                  label: const Text("Save Selected Parameters"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
