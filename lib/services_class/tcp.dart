// // import 'dart:async';
// // import 'dart:io';
// // import 'dart:typed_data';
// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(const MaterialApp(home: ModbusReadScreen()));
// // }

// // class ModbusReadScreen extends StatefulWidget {
// //   const ModbusReadScreen({super.key});

// //   @override
// //   State<ModbusReadScreen> createState() => _ModbusReadScreenState();
// // }

// // class _ModbusReadScreenState extends State<ModbusReadScreen> {
// //   String status = "Reading...";
// //   List<int> registerValues = [];

// //   final String ip = '192.168.0.105';
// //   final int port = 502;
// //   final int unitId = 0; // use 0 if "Ignore Unit ID" is checked
// //   final int startAddress = 0;
// //   final int registerCount = 8; // 16 x 2 = 32 bytes

// //   @override
// //   void initState() {
// //     super.initState();
// //     readRegisters();
// //   }
// //   Future<void> readRegisters() async {
// //     try {
// //       final socket = await Socket.connect(
// //         ip,
// //         port,
// //         timeout: const Duration(seconds: 5),
// //       );
// //       print("Connected to $ip:$port");

// //       final request = Uint8List.fromList([
// //         0x00, 0x01, // Transaction ID
// //         0x00, 0x00, // Protocol ID
// //         0x00, 0x06, // Length
// //         unitId, // Unit ID
// //         0x03, // Function Code: Read Holding Registers
// //         (startAddress >> 8) & 0xFF, // Start Address High
// //         startAddress & 0xFF, // Start Address Low
// //         (registerCount >> 8) & 0xFF, // Quantity High
// //         registerCount & 0xFF, // Quantity Low
// //       ]);

// //       socket.add(request);
// //       await socket.flush();

// //       final completer = Completer<List<int>>();
// //       final List<int> buffer = [];

// //       socket.listen((data) {
// //         buffer.addAll(data);
// //         if (buffer.length >= 6) {
// //           final int length = (buffer[4] << 8) | buffer[5];
// //           final int expectedLength = 6 + length;

// //           if (buffer.length >= expectedLength) {
// //             completer.complete(buffer);
// //           }
// //         }
// //       });

// //       final response = await completer.future;
// //       socket.destroy();

// //       if (response.length >= 9 + registerCount * 2) {
// //         List<int> values = [];
// //         for (int i = 0; i < registerCount; i++) {
// //           int high = response[9 + i * 2];
// //           int low = response[9 + i * 2 + 1];
// //           values.add((high << 8) | low);
// //         }
// //         setState(() {
// //           registerValues = values;
// //           status = "Read ${values.length} registers";
// //         });
// //       } else {
// //         setState(() {
// //           status = "Invalid response size";
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         status = "Connection error: $e";
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Modbus TCP Register")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             Text(status, style: const TextStyle(fontSize: 18)),
// //             const SizedBox(height: 20),
// //             Expanded(
// //               child: ListView.builder(
// //                 itemCount: registerValues.length,
// //                 itemBuilder: (context, index) {
// //                   return ListTile(
// //                     leading: Text("Register ${startAddress + index}"),
// //                     title: Text("${registerValues[index]}"),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MaterialApp(home: ModbusReadWriteScreen()));
// }

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
//   final int registerCount = 4;

//   final TextEditingController valueController = TextEditingController();
//   int? selectedRegister;

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
//                 // Dropdown for Register 0 or 1
//                 DropdownButton<int>(
//                   value: selectedRegister,
//                   hint: const Text("Select Register"),
//                   items: const [
//                     DropdownMenuItem(value: 0, child: Text("Register 0")),
//                     DropdownMenuItem(value: 1, child: Text("Register 1")),
//                   ],
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() => selectedRegister = value);
//                     }
//                   },
//                 ),
//                 const SizedBox(width: 10),
//                 // Value input
//                 Expanded(
//                   child: TextField(
//                     controller: valueController,
//                     decoration: const InputDecoration(labelText: "Value"),
//                     keyboardType: TextInputType.number,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 // Write Button
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
