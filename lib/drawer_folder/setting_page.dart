// // ignore_for_file: deprecated_member_use
// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:newpro/fields/colors.dart';
// import 'package:newpro/fields/shared_pref_helper.dart';
// import 'package:newpro/fields/spacer_widget.dart';
// import 'package:newpro/model_folder/parameters_model.dart';
// import 'package:newpro/view_Pages/add_ahu.dart';
// import 'package:newpro/view_Pages/show_parameters.dart';
// import 'package:newpro/widgets/app_bar.dart';
// import 'package:newpro/widgets/app_drawer.dart';

// class SettingPage extends StatefulWidget {
//   const SettingPage({super.key});

//   @override
//   State<SettingPage> createState() => _SettingPageState();
// }

// class _SettingPageState extends State<SettingPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   final List<String> equimentType = [
//     'AHU',
//     'FCU',
//     'VRF',
//     'Chiller',
//     'Cooling Tower',
//   ];
//   final List<String> equimentName = ['AHU-01', 'AHU-02', 'AHU-03', 'AHU-04'];
//   final List<String> parameters = [
//     'Flow meter',
//     'Water Temperture',
//     'BTU',
//     'Power',
//     'Voltage',
//     'Current',
//   ];
//   // track the selected items......
//   late String selectedType;
//   late String selectedName;
//   // To store the draggable items.........
//   final List<ParameterModel> draggableItems = [];

//   List<int> registerValues = [];

//   final String modbusIP = '192.168.0.105';
//   final int modbusPort = 502;
//   final int unitId = 0;
//   final int startAddress = 0;
//   final int registerCount = 16; // or match max registerIndex

//   // initialization of all function in init state.......
//   @override
//   void initState() {
//     super.initState();
//     selectedType = equimentType.first;
//     selectedName = equimentName.first;
//     loadSaved(); // save function
//     readModbusRegisters();
//   }

//   // To save draggable items
//   void save() {
//     SharedPrefHelper.saveParameters(draggableItems);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Saved')));
//   }

//   // clear all parameters (not used)
//   void clear() {
//     SharedPrefHelper.clearParameters();
//     setState(() => draggableItems.clear());
//   }

//   // remove each parameter function....
//   void _removeItem(int index) {
//     setState(() {
//       draggableItems.removeAt(index);
//     });
//   }

//   // To load the saved parameters in home screen container function
//   void loadSaved() async {
//     final items = await SharedPrefHelper.getParameters();
//     setState(() => draggableItems.addAll(items));
//   }

//   Future<void> readModbusRegisters() async {
//     try {
//       final socket = await Socket.connect(
//         modbusIP,
//         modbusPort,
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
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Modbus Read Error: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // media queryies for height and width
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
//       drawer: AppDrawer(selectedScreen: 'settings'),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SpacerWidget.size32,
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Equipment Type Dropdown
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       value: selectedType,
//                       decoration: InputDecoration(
//                         labelText: 'Equipment Type',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       icon: const Icon(Icons.arrow_drop_down),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedType = newValue!;
//                         });
//                       },
//                       items: equimentType.map<DropdownMenuItem<String>>((
//                         String value,
//                       ) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                     ),
//                   ),

//                   SpacerWidget.size16w,

//                   // Equipment Name Dropdown
//                   Expanded(
//                     child: DropdownButtonFormField<String>(
//                       isExpanded: true,
//                       value: selectedName,
//                       decoration: InputDecoration(
//                         labelText: 'Equipment Name',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                       ),
//                       icon: const Icon(Icons.arrow_drop_down),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedName = newValue!;
//                         });
//                       },
//                       items: equimentName.map<DropdownMenuItem<String>>((
//                         String value,
//                       ) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                     ),
//                   ),

//                   SpacerWidget.size16w,

//                   // Add AHU Button
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddAhuFieldScreen(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       height: 50,
//                       width: 150,
//                       decoration: BoxDecoration(
//                         color: AppColors.green,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.add_box_rounded, color: Colors.white),
//                           SpacerWidget.size8w,
//                           Text(
//                             "Add AHU",
//                             style: GoogleFonts.openSans(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SpacerWidget.size8w,
//                   // Save Button
//                   InkWell(
//                     onTap: () {
//                       save();
//                     },
//                     child: Container(
//                       height: 50,
//                       width: 130,
//                       decoration: BoxDecoration(
//                         color: AppColors.darkblue,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.save, color: Colors.white),
//                           SpacerWidget.size8w,
//                           Text(
//                             "Save",
//                             style: GoogleFonts.openSans(
//                               fontSize: 16,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SpacerWidget.size8w,
//                   // Add Parameter Button
//                   GestureDetector(
//                     onTap: () async {
//                       final updated = await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ModbusReadWriteScreen(),
//                         ),
//                       );
//                       if (updated == true) {
//                         setState(() {
//                           draggableItems.clear(); // clear old
//                         });
//                         loadSaved(); // load updated parameters
//                       }
//                     },
//                     child: Container(
//                       height: 50,
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: AppColors.orange,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.list_alt_rounded,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             "Add Parameter",
//                             style: GoogleFonts.openSans(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SpacerWidget.size64,
//             Center(
//               child: Container(
//                 height: screenHeight * 0.55,
//                 width: screenWidth * 0.60,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Stack(
//                   children: [
//                     // Static image inside container
//                     Center(
//                       child: Image.asset(
//                         "images/ahuimage.png",
//                         height: 300,
//                         width: 600,
//                         fit: BoxFit.fill,
//                       ),
//                     ),
//                     // Draggable parameters
//                     ...draggableItems.asMap().entries.map((e) {
//                       final index = e.key;
//                       final item = e.value;
//                       final value =
//                           (item.registerIndex != null &&
//                               item.registerIndex! < registerValues.length)
//                           ? registerValues[item.registerIndex!].toString()
//                           : "N/A";
//                       return Positioned(
//                         left: item.dx,
//                         top: item.dy,
//                         child: GestureDetector(
//                           onPanUpdate: (details) {
//                             setState(() {
//                               draggableItems[index] = ParameterModel(
//                                 text: item.text,
//                                 dx: (item.dx + details.delta.dx).clamp(
//                                   0.0,
//                                   700,
//                                 ),
//                                 dy: (item.dy + details.delta.dy).clamp(
//                                   0.0,
//                                   350,
//                                 ),
//                                 registerIndex: item.registerIndex,
//                               );
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.orange.withOpacity(0.8),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   "${item.text}: $value",
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.black,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SpacerWidget.size8w,
//                                 GestureDetector(
//                                   onTap: () => _removeItem(index),
//                                   child: const Icon(
//                                     Icons.close,
//                                     size: 20,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/drawer_folder/parameters_list.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/shared_pref_helper.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/view_Pages/add_ahu.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> equimentType = [
    'AHU',
    'FCU',
    'VRF',
    'Chiller',
    'Cooling Tower',
  ];
  final List<String> equimentName = ['AHU-01', 'AHU-02', 'AHU-03', 'AHU-04'];
  final List<String> parameters = [
    'Flow meter',
    'Water Temperture',
    'BTU',
    'Power',
    'Voltage',
  ];
  // track the selected items......
  late String selectedType;
  late String selectedName;
  // To store the draggable items.........
  final List<ParameterModel> draggableItems = [];

  // initialization of all function in init state.......
  @override
  void initState() {
    super.initState();
    selectedType = equimentType.first;
    selectedName = equimentName.first;
    loadSaved(); // save function
  }

  // pop up menu for parameters...........
  void _showPopupMenu(BuildContext context, Offset position) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: parameters
          .map((item) => PopupMenuItem<String>(value: item, child: Text(item)))
          .toList(),
    );

    if (selected != null) {
      setState(() {
        draggableItems.add(
          ParameterModel(
            text: selected,
            dx: 50,
            dy: 150 + draggableItems.length * 60,
          ),
        );
      });
    }
  }

  // To save draggable items
  void save() {
    SharedPrefHelper.saveParameters(draggableItems);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved')));
  }

  // clear all parameters (not used)
  void clear() {
    SharedPrefHelper.clearParameters();
    setState(() => draggableItems.clear());
  }

  // remove each parameter function....
  void _removeItem(int index) {
    setState(() {
      draggableItems.removeAt(index);
    });
  }

  // To load the saved parameters in home screen container function
  void loadSaved() async {
    final items = await SharedPrefHelper.getParameters();
    setState(() => draggableItems.addAll(items));
  }

  @override
  Widget build(BuildContext context) {
    // media queryies for height and width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final provider = Provider.of<ProviderServices>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedScreen: 'settings'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpacerWidget.size32,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Equipment Type Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: 'Equipment Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue!;
                        });
                      },
                      items: equimentType.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),

                  SpacerWidget.size16w,

                  // Equipment Name Dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedName,
                      decoration: InputDecoration(
                        labelText: 'Equipment Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedName = newValue!;
                        });
                      },
                      items: equimentName.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),

                  SpacerWidget.size16w,

                  // Add AHU Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddAhuFieldScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_box_rounded, color: Colors.white),
                          SpacerWidget.size8w,
                          Text(
                            "Add AHU",
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SpacerWidget.size8w,
                  // Save Button
                  InkWell(
                    onTap: () {
                      save();
                    },
                    child: Container(
                      height: 50,
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppColors.darkblue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          SpacerWidget.size8w,
                          Text(
                            "Save",
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SpacerWidget.size8w,
                  // Add Parameter Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ParametersList(),
                        ),
                      );
                    },
                    // onTapDown: (details) {
                    //   _showPopupMenu(context, details.globalPosition);
                    // },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.list_alt_rounded,
                            color: Colors.white,
                          ),
                          SpacerWidget.size8w,
                          Text(
                            "Add Parameter",
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SpacerWidget.size64,
            Center(
              child: Container(
                height: screenHeight * 0.55,
                width: screenWidth * 0.60,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    // Static image inside container
                    Center(
                      child: Image.asset(
                        "images/ahuimage.png",
                        height: 300,
                        width: 600,
                        fit: BoxFit.fill,
                      ),
                    ),
                    // Draggable parameters
                    ...provider.parameters.asMap().entries.map((e) {
                      final index = e.key;
                      final item = e.value;
                      return Positioned(
                        left: item.dx,
                        top: item.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            provider.updatePosition(
                              index,
                              (item.dx + details.delta.dx).clamp(0.0, 700),
                              (item.dy + details.delta.dy).clamp(0.0, 350),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item.text),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      provider.removeParameter(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
