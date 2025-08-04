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
    // loadSaved(); // save function
  }

  // success message for saved parameters......
  void save() {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    SharedPrefHelper.saveParameters(provider.parameters);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parameter Saved', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // media queryies for height and width
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // provider function for parameters...............
    final provider = Provider.of<ProviderServices>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedScreen: 'settings'),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            builder: (context) => ParametersListScreen(),
                          ),
                        );
                      },
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
                    SpacerWidget.size8w,
                    // clear all parmeter
                    GestureDetector(
                      onTap: () {
                        provider.clearParameters();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Parmeter Cleared successfully",
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.green, 
                          ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SpacerWidget.size64,
              Center(
                child: Container(
                  height: screenHeight * 0.60,
                  width: screenWidth * 0.80,
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
                          height: screenHeight * 0.90,
                          width: screenWidth * 0.70,
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
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${item.text}: ${item.value.isEmpty ? '--' : item.value}",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => provider.removeParameter(
                                      item.registerIndex!,
                                    ),
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
      ),
    );
  }
}
