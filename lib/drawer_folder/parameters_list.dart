// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:zedbeemodbus/drawer_folder/setting_page.dart';
// import 'package:zedbeemodbus/fields/colors.dart';
// import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
// import 'package:zedbeemodbus/services_class/provider_services.dart';

// class ParametersList extends StatefulWidget {
//   const ParametersList({super.key});

//   @override
//   State<ParametersList> createState() => _ParametersListState();
// }

// class _ParametersListState extends State<ParametersList> {
//   final String ip = '192.168.0.105';
//   final int port = 502;
//   final int unitId = 0;
//   final int startAddress = 0;
//   final int registerCount = 20;
//   bool isSaving = false; // loading indicator

//   List<int> registerValues = [];
//   List<bool> isCheckedList = List.generate(20, (_) => false);
//   final TextEditingController valueController = TextEditingController();
//   int? selectedRegister;
//   String status = "Reading...";

//   final List<int> allowedRegisterIndexes = [
//     0,
//     1,
//     2,
//     3,
//     4,
//     6,
//     7,
//     8,
//     9,
//     10,
//     11,
//     12,
//     13,
//     14,
//     16,
//     17,
//     19,
//     20,
//     29,
//   ];

//   final List<String> parameterLabels = [
//     "Status",
//     "Frequency",
//     "Auto/Manual",
//     "Flow Rate",
//     "Watter Pressure",
//     "Duct Pressure",
//     "Running Hours",
//     "Running",
//     "BTU",
//     "BTU",
//     "Water In",
//     "Water Out",
//     "Supply Temperature",
//     "Return Temperature",
//     "Trip Status",
//     "Filter Status",
//     "Run Status",
//     "Auto Manual Status",
//     "Set Temperature",
//   ];

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
//           if (buffer.length >= 6 + length) {
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
//         showSnackBar("Invalid response", isError: true);
//       }
//     } catch (e) {
//       showSnackBar("Connection failed: $e", isError: true);
//     }
//   }

//   void showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : AppColors.green,
//       ),
//     );
//   }

//   void saveSelectedParameters() async {
//     final provider = Provider.of<ProviderServices>(context, listen: false);

//     if (provider.parameters.isEmpty) {
//       showSnackBar("No parameters selected", isError: true);
//       Future.delayed(const Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SettingPage()),
//         );
//       });
//       return;
//     }

//     setState(() => isSaving = true);

//     try {
//       await SharedPrefHelper.saveParameters(provider.parameters);
//       await SharedPrefHelper.saveCheckedIndexes(
//         provider.parameters.map((e) => e.registerIndex ?? 0).toList(),
//       );

//       showSnackBar("Parameters saved!");
//       Navigator.pop(context);
//     } catch (e) {
//       showSnackBar("Error saving parameters: $e", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() => isSaving = false);
//       }
//     }
//   }

//   Future<void> writeRegister(int address, int value) async {
//     // only allow register 0 and 1
//     if (address != 0 && address != 1) {
//       showSnackBar("Only register 0 and 1 are writable", isError: true);
//       return;
//     }

//     // register enforce 0 or 1 only....
//     if (address == 0 && (value != 0 && value != 1)) {
//       showSnackBar(
//         "Status register only accepts 0 (Off) or 1 (On)",
//         isError: true,
//       );
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

//       // Validate function code and echo values
//       final functionCode = response[7];
//       final responseAddress = (response[8] << 8) | response[9];
//       final responseValue = (response[10] << 8) | response[11];

//       if (functionCode == 0x06 &&
//           responseAddress == address &&
//           responseValue == value) {
//         valueController.clear();
//         setState(() {
//           selectedRegister = null;
//         });

//         // show ON/OFF message if writing to "Status" register
//         if (address == 0) {
//           showSnackBar(
//             value == 1 ? "Device is ON" : "Device is OFF",
//             isError: false,
//           );
//         } else {
//           showSnackBar("Successfully wrote $value to register $address");
//         }
//         await Future.delayed(const Duration(milliseconds: 300));
//         readRegisters();
//       } else {
//         showSnackBar("Write failed: Invalid response", isError: true);
//       }
//     } catch (e) {
//       showSnackBar("Write error: $e", isError: true);
//     }
//   }

//   void handleWrite() {
//     final valueText = valueController.text.trim();

//     if (selectedRegister == null) {
//       showSnackBar("Select a register", isError: true);
//       return;
//     }
//     if (valueText.isEmpty) {
//       showSnackBar("Enter a value", isError: true);
//       return;
//     }

//     final value = int.tryParse(valueText);
//     if (value == null) {
//       showSnackBar("Invalid number", isError: true);
//       return;
//     }

//     writeRegister(selectedRegister!, value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProviderServices>(context);
//     final List<int> filteredIndexes = List.generate(
//       parameterLabels.length,
//       (i) => i,
//     ).where((i) => allowedRegisterIndexes.contains(i)).toList();
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "Modbus Parameter",
//           style: TextStyle(fontSize: 18, color: Colors.white),
//         ),
//       ),
//       body: Stack(
//         children: [
//           // Main Body Column
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(status, style: const TextStyle(fontSize: 18)),
//               ),
//               const Divider(),
//               Expanded(
//                 child: ListView.builder(
//                   scrollDirection: Axis.vertical,
//                   shrinkWrap: true,
//                   itemCount: filteredIndexes.length,
//                   itemBuilder: (context, index) {
//                     final actualIndex = filteredIndexes[index];
//                     return CheckboxListTile(
//                       checkColor: Colors.white,
//                       activeColor: AppColors.darkblue,
//                       value: isCheckedList[actualIndex],
//                       title: Text(parameterLabels[actualIndex]),
//                       subtitle: Text(
//                         index < registerValues.length
//                             ? "Register $actualIndex → ${registerValues[actualIndex]}"
//                             : "Register $actualIndex → --",
//                       ),
//                       onChanged: (bool? checked) {
//                         setState(() {
//                           isCheckedList[actualIndex] = checked ?? false;
//                           if (checked!) {
//                             provider.addParameter(
//                               parameterLabels[actualIndex],
//                               index: actualIndex,
//                             );
//                           } else {
//                             provider.removeParameter(index);
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 150),
//             ],
//           ),
//           // Floating Container Positioned at Bottom
//           Positioned(
//             left: 10,
//             right: 10,
//             bottom: 10,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 8,
//                     offset: Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       DropdownButton<int>(
//                         value: selectedRegister,
//                         hint: const Text("Select Register"),
//                         items: isCheckedList
//                             .asMap()
//                             .entries
//                             .where(
//                               (e) =>
//                                   e.value &&
//                                   (e.key == 0 || e.key == 1) &&
//                                   e.key < registerValues.length,
//                             )
//                             .map(
//                               (e) => DropdownMenuItem(
//                                 value: e.key,
//                                 child: Text(
//                                   "Register ${e.key} → ${registerValues[e.key]}",
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: (val) =>
//                             setState(() => selectedRegister = val),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: TextField(
//                           controller: valueController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                           decoration: InputDecoration(
//                             labelText: "Value",
//                             isDense: true,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 8,
//                             ),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: handleWrite,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.darkblue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         child: const Text(
//                           "Write",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),

//                   // Save Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 44,
//                     child: ElevatedButton(
//                       onPressed: isSaving ? null : saveSelectedParameters,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: isSaving
//                           ? const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2.5,
//                               ),
//                             )
//                           : const Text(
//                               "Save Parameter",
//                               style: TextStyle(color: Colors.white),
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:zedbeemodbus/drawer_folder/setting_page.dart';
// import 'package:zedbeemodbus/fields/colors.dart';
// import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
// import 'package:zedbeemodbus/services_class/provider_services.dart';

// class ParametersList extends StatefulWidget {
//   const ParametersList({super.key});

//   @override
//   State<ParametersList> createState() => _ParametersListState();
// }

// class _ParametersListState extends State<ParametersList> {
//   final String ip = '192.168.0.105';
//   final int port = 502;
//   final int unitId = 0;
//   final int startAddress = 0;
//   final int registerCount = 30; // make sure this covers your allowed indexes
//   bool isSaving = false;

//   List<int> registerValues = [];
//   List<bool> isCheckedList = List.generate(30, (_) => false);
//   final TextEditingController valueController = TextEditingController();
//   int? selectedRegister;
//   String status = "Reading...";

//   final List<int> allowedRegisterIndexes = [
//     0, 1, 2, 3, 4, 6, 7, 8, 9, 10,
//     11, 12, 13, 14, 16, 17, 19, 20, 29,
//   ];

//   final List<String> parameterLabels = [
//     "Status",
//     "Frequency",
//     "Auto/Manual",
//     "Flow Rate",
//     "Watter Pressure",
//     "Unused5",
//     "Duct Pressure",
//     "Running Hours",
//     "Running",
//     "BTU1",
//     "BTU2",
//     "Water In",
//     "Water Out",
//     "Supply Temperature",
//     "Return Temperature",
//     "Unused15",
//     "Trip Status",
//     "Filter Status",
//     "Run Status",
//     "Auto Manual Status",
//     "Unused21",
//     "Unused22",
//     "Unused23",
//     "Unused24",
//     "Unused25",
//     "Unused26",
//     "Unused27",
//     "Unused28",
//     "Set Temperature",
//     "Unused30",
//   ];

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
//         0x00, 0x01,
//         0x00, 0x00,
//         0x00, 0x06,
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
//           if (buffer.length >= 6 + length) {
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
//         showSnackBar("Invalid response", isError: true);
//       }
//     } catch (e) {
//       showSnackBar("Connection failed: $e", isError: true);
//     }
//   }

//   void showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : AppColors.green,
//       ),
//     );
//   }

//   void saveSelectedParameters() async {
//     final provider = Provider.of<ProviderServices>(context, listen: false);

//     if (provider.parameters.isEmpty) {
//       showSnackBar("No parameters selected", isError: true);
//       Future.delayed(const Duration(seconds: 3), () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SettingPage()),
//         );
//       });
//       return;
//     }

//     setState(() => isSaving = true);

//     try {
//       await SharedPrefHelper.saveParameters(provider.parameters);
//       await SharedPrefHelper.saveCheckedIndexes(
//         provider.parameters.map((e) => e.registerIndex ?? 0).toList(),
//       );

//       showSnackBar("Parameters saved!");
//       Navigator.pop(context);
//     } catch (e) {
//       showSnackBar("Error saving parameters: $e", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() => isSaving = false);
//       }
//     }
//   }

//   Future<void> writeRegister(int address, int value) async {
//     if (address != 0 && address != 1) {
//       showSnackBar("Only register 0 and 1 are writable", isError: true);
//       return;
//     }

//     if (address == 0 && (value != 0 && value != 1)) {
//       showSnackBar("Status register only accepts 0 or 1", isError: true);
//       return;
//     }

//     try {
//       final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));

//       final request = Uint8List.fromList([
//         0x00, 0x02,
//         0x00, 0x00,
//         0x00, 0x06,
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

//       final functionCode = response[7];
//       final responseAddress = (response[8] << 8) | response[9];
//       final responseValue = (response[10] << 8) | response[11];

//       if (functionCode == 0x06 && responseAddress == address && responseValue == value) {
//         valueController.clear();
//         setState(() => selectedRegister = null);

//         showSnackBar(
//           address == 0
//               ? (value == 1 ? "Device is ON" : "Device is OFF")
//               : "Successfully wrote $value to register $address",
//         );
//         await Future.delayed(const Duration(milliseconds: 300));
//         readRegisters();
//       } else {
//         showSnackBar("Write failed: Invalid response", isError: true);
//       }
//     } catch (e) {
//       showSnackBar("Write error: $e", isError: true);
//     }
//   }

//   void handleWrite() {
//     final valueText = valueController.text.trim();
//     if (selectedRegister == null) {
//       showSnackBar("Select a register", isError: true);
//       return;
//     }
//     if (valueText.isEmpty) {
//       showSnackBar("Enter a value", isError: true);
//       return;
//     }

//     final value = int.tryParse(valueText);
//     if (value == null) {
//       showSnackBar("Invalid number", isError: true);
//       return;
//     }

//     writeRegister(selectedRegister!, value);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ProviderServices>(context);

//     final List<int> filteredIndexes = List.generate(
//       parameterLabels.length,
//       (i) => i,
//     ).where((i) => allowedRegisterIndexes.contains(i)).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Modbus Parameter", style: TextStyle(fontSize: 18, color: Colors.white)),
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(status, style: const TextStyle(fontSize: 18)),
//               ),
//               const Divider(),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: filteredIndexes.length,
//                   itemBuilder: (context, index) {
//                     final actualIndex = filteredIndexes[index];
//                     final valueText = (actualIndex - startAddress) < registerValues.length
//                         ? "${registerValues[actualIndex - startAddress]}"
//                         : "--";

//                     return CheckboxListTile(
//                       checkColor: Colors.white,
//                       activeColor: AppColors.darkblue,
//                       value: isCheckedList[actualIndex],
//                       title: Text(parameterLabels[actualIndex]),
//                       subtitle: Text("Register $actualIndex → $valueText"),
//                       onChanged: (checked) {
//                         setState(() {
//                           isCheckedList[actualIndex] = checked ?? false;
//                           if (checked!) {
//                             provider.addParameter(parameterLabels[actualIndex], index: actualIndex);
//                           } else {
//                             provider.removeParameter(actualIndex);
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 150),
//             ],
//           ),
//           Positioned(
//             left: 10,
//             right: 10,
//             bottom: 10,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3))],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       DropdownButton<int>(
//                         value: selectedRegister,
//                         hint: const Text("Select Register"),
//                         items: isCheckedList.asMap().entries
//                             .where((e) =>
//                                 e.value && (e.key == 0 || e.key == 1) && (e.key - startAddress) < registerValues.length)
//                             .map((e) {
//                           final val = registerValues[e.key - startAddress];
//                           return DropdownMenuItem(
//                             value: e.key,
//                             child: Text("Register ${e.key} → $val"),
//                           );
//                         }).toList(),
//                         onChanged: (val) => setState(() => selectedRegister = val),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: TextField(
//                           controller: valueController,
//                           keyboardType: TextInputType.number,
//                           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                           decoration: const InputDecoration(
//                             labelText: "Value",
//                             isDense: true,
//                             contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: handleWrite,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.darkblue,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                         ),
//                         child: const Text("Write", style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 44,
//                     child: ElevatedButton(
//                       onPressed: isSaving ? null : saveSelectedParameters,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.green,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                       child: isSaving
//                           ? const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
//                             )
//                           : const Text("Save Parameter", style: TextStyle(color: Colors.white)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/drawer_folder/setting_page.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
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
  final int registerCount = 42;
  bool isSaving = false; // loading indicator

  List<int> registerValues = [];
  List<bool> isCheckedList = List.generate(42, (_) => false);
  final TextEditingController valueController = TextEditingController();
  int? selectedRegister;
  String status = "Reading...";

  final List<int> allowedRegisterIndexes = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
  ];

  final List<String> parameterLabels = [
    "Status", // 00000
    "Frequency", // 00001
    "Auto Manual", // 00002
    "Flowrate", // 00003
    "Water Pressure", // 00004
    "Running hours (trip)", // 00005
    "Running hours (filter)", // 00006
    "BTU (-5584)", // 00007
    "BTU (13)", // 00008
    "Set Temp", // 00009
    "Water In", // 00010
    "Water Out", // 00011
    "Supply Temperature", // 00012
    "Return Temperature", // 00013
    "Stop Condition", // 00014
    "Fire Status", // 00015
    "Trip Status", // 00016
    "Filter Status", // 00017
    "NONC Status", // 00018
    "Run Status", // 00019
    "Auto/Manual Status", // 00020
    "N/A", // 00021
    "N/A", // 00022
    "Water Value", // 00023
    "N/A", // 00024
    "Voltage", // 00025
    "Current", // 00026
    "Power", // 00027
    "Delta TAverage", // 00028
    "Set Temperature", // 00029
    "Minimum Frequency", // 00030
    "Maximum Frequency", // 00031
    "VAV Number", // 00032
    "PID Constant", // 00033
    "Ductset Pressure", // 00034
    "Minimum FlowRate", // 00035
    "Maximum FlowRate", // 00036
    "Pressure Constant", // 00037
    "Inlet Threshold", // 00038
    "Actuator Direction", // 00039
    "Actuator Type", // 00040
    "Minimum Act Position", // 00041
    "Ramp Up Sel", // 00042
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
    final List<int> filteredIndexes = List.generate(
      parameterLabels.length,
      (i) => i,
    ).where((i) => allowedRegisterIndexes.contains(i)).toList();
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
                  itemCount: filteredIndexes.length,
                  itemBuilder: (context, index) {
                    final actualIndex = filteredIndexes[index];
                    return CheckboxListTile(
                      checkColor: Colors.white,
                      activeColor: AppColors.darkblue,
                      value: isCheckedList[actualIndex],
                      title: Text(parameterLabels[actualIndex]),
                      subtitle: Text(
                        actualIndex < registerValues.length
                            ? "Register $actualIndex → ${registerValues[actualIndex]}"
                            : "Register $actualIndex → --",
                      ),
                      onChanged: (bool? checked) {
                        setState(() {
                          isCheckedList[actualIndex] = checked ?? false;
                          if (checked!) {
                            provider.addParameter(
                              parameterLabels[actualIndex],
                              index: actualIndex,
                            );
                          } else {
                            provider.removeParameter(
                              actualIndex,
                            ); // Now works because it matches registerIndex
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
