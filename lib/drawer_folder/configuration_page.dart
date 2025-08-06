import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  // Global keys..
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  // controllers for fields ...
  final tempHighController = TextEditingController();
  final tempLowController = TextEditingController();
  final minFlowController = TextEditingController();
  final maxFlowController = TextEditingController();
  final maxFreqController = TextEditingController();
  final minFreqController = TextEditingController();
  final btucontroller = TextEditingController(); //
  final watervalvecontroller = TextEditingController();
  final actuatordircontroller = TextEditingController(); //
  final inletcontroller = TextEditingController();
  final waterdeltacontroller = TextEditingController();
  final pressureconstantcontroller = TextEditingController();
  final ductpressurecontroller = TextEditingController();
  final waterpressurecontroller = TextEditingController();
  final pidconstantcontroller = TextEditingController();
  final minspeedcontroller = TextEditingController(); //
  final maxspeedcontroller = TextEditingController(); //
  // Total 17 controllers ....

  // List for equipment type
  final List<String> equimentType = [
    'AHU',
    'FCU',
    'VRF',
    'Chiller',
    'Cooling Tower',
  ];
  final List<String> equimentName = ['AHU-01', 'AHU-02', 'AHU-03', 'AHU-04'];
  // selection state ....
  String? selectedEquipment;
  String? selectedName;

  @override
  void dispose() {
    tempHighController.dispose();
    tempLowController.dispose();
    minFlowController.dispose();
    maxFlowController.dispose();
    maxFreqController.dispose();
    minFreqController.dispose();
    watervalvecontroller.dispose();
    inletcontroller.dispose();
    waterdeltacontroller.dispose();
    pressureconstantcontroller.dispose();
    waterpressurecontroller.dispose();
    ductpressurecontroller.dispose();
    pidconstantcontroller.dispose();
    super.dispose();
  }

  // set button function .....
  void _handleSetButton() {
    if (tempHighController.text.isEmpty &&
        tempLowController.text.isEmpty &&
        minFlowController.text.isEmpty &&
        maxFlowController.text.isEmpty &&
        maxFreqController.text.isEmpty &&
        minFreqController.text.isEmpty &&
        watervalvecontroller.text.isEmpty &&
        inletcontroller.text.isEmpty &&
        waterdeltacontroller.text.isEmpty &&
        pressureconstantcontroller.text.isEmpty &&
        waterpressurecontroller.text.isEmpty &&
        ductpressurecontroller.text.isEmpty &&
        pidconstantcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set any value"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(top: 20, left: 16, right: 16),

        ),
      );
      return;
    }
    // validation fuction for byte types ...........
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProviderServices>(context, listen: false);

      try {
        // float value
        if (tempHighController.text.isNotEmpty) {
          double value = double.parse(tempHighController.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int high = bytes.getUint16(0);
          provider.writeRegister(50, high);
          _showSnackbar("High Temp value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // flaot value
        if (tempLowController.text.isNotEmpty) {
          double value = double.parse(tempLowController.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int low = bytes.getUint16(0);
          provider.writeRegister(49, low);
          _showSnackbar("Low Temp value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (minFlowController.text.isNotEmpty) {
          double value = double.parse(minFlowController.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int minflow = bytes.getUint16(0);
          provider.writeRegister(36, minflow);
          _showSnackbar("Min Flowrate value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (maxFlowController.text.isNotEmpty) {
          double value = double.parse(maxFlowController.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int maxflow = bytes.getUint16(0);
          provider.writeRegister(36, maxflow);
          _showSnackbar("Max Flowrate value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (maxFreqController.text.isNotEmpty) {
          double value = double.parse(maxFreqController.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int maxfreq = bytes.getUint16(0);
          provider.writeRegister(31, maxfreq);
          _showSnackbar("Max Flowrate value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (minFreqController.text.isNotEmpty) {
          double value = double.parse(minFreqController.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int minfreq = bytes.getUint16(0);
          provider.writeRegister(30, minfreq);
          _showSnackbar("Min Frequecny value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // int value
        if (watervalvecontroller.text.isNotEmpty) {
          int value = int.parse(watervalvecontroller.text);
          provider.writeRegister(23, value);
          _showSnackbar("water valve value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (inletcontroller.text.isNotEmpty) {
          double value = double.parse(inletcontroller.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int inlet = bytes.getUint16(0);
          provider.writeRegister(38, inlet);
          _showSnackbar("inlet value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (waterdeltacontroller.text.isNotEmpty) {
          double value = double.parse(waterdeltacontroller.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int delta = bytes.getUint16(0);
          provider.writeRegister(43, delta);
          _showSnackbar("water delta value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (pressureconstantcontroller.text.isNotEmpty) {
          double value = double.parse(pressureconstantcontroller.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int pressure = bytes.getUint16(0);
          provider.writeRegister(37, pressure);
          _showSnackbar("Pressure constant value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (ductpressurecontroller.text.isNotEmpty) {
          double value = double.parse(ductpressurecontroller.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int duct = bytes.getUint16(0);
          provider.writeRegister(5, duct);
          _showSnackbar("Duct pressure value is ${value.toString()}");
        }
      } catch (_) {}

      try {
        // float value
        if (pidconstantcontroller.text.isNotEmpty) {
          double value = double.parse(pidconstantcontroller.text);
          final bytes = ByteData(4)..setFloat32(0, value, Endian.big);
          int pdi = bytes.getUint16(0);
          provider.writeRegister(30, pdi);
          _showSnackbar("PDI constant value is ${value.toString()}");
        }
      } catch (_) {}

      // Clear controllers
      tempHighController.clear();
      tempLowController.clear();
      minFlowController.clear();
      maxFlowController.clear();
      maxFreqController.clear();
      minFreqController.clear();
      watervalvecontroller.clear();
      inletcontroller.clear();
      waterdeltacontroller.clear();
      pressureconstantcontroller.clear();
      waterpressurecontroller.clear();
      ductpressurecontroller.clear();
      pidconstantcontroller.clear();
    }
  }

  // success message ........
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
      ),
    );
  }

  // Text field widget ...

  Widget _customTextfield(
    String label,
    TextEditingController controller, {
    String hintText = "", // hint text
    FormFieldValidator<String>? validator, // text field validator
  }) {
    final screenWidth = MediaQuery.of(context).size.width; // width
    // dark theme color
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white : Colors.black87;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        SpacerWidget.small,
        SizedBox(
          width: screenWidth * 0.30,
          height: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: Colors.white,
            style: TextStyle(color: labelColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.green),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: validator,
          ),
        ),
      ],
    );
  }

  // equipment name drop down widget ...
  Widget _equipmentNameDropdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedName,
      decoration: InputDecoration(
        labelText: 'Equipment Name',
        labelStyle: TextStyle(color: labelColor),
        fillColor: inputFillColor,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.green : Colors.black87,
          ),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? newValue) {
        setState(() {
          selectedName = newValue!;
        });
      },
      dropdownColor: isDarkMode ? Colors.grey[800] : null,
      items: equimentName.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: labelColor)),
        );
      }).toList(),
    );
  }

  // equipment Type drop down widget ...
  Widget _equipmentTypeDrowpdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    return DropdownButtonFormField<String>(
      value: selectedEquipment,
      decoration: InputDecoration(
        labelText: 'Equipment Type',
        labelStyle: TextStyle(color: labelColor),
        fillColor: inputFillColor,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkMode ? AppColors.green : Colors.black87,
          ),
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? newValue) {
        setState(() {
          selectedEquipment = newValue!;
        });
      },
      dropdownColor: isDarkMode ? Colors.grey[800] : null,
      items: equimentType.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: labelColor)),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // floating action button starts here .............
      floatingActionButton: Container(
        padding: EdgeInsets.all(12),
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 25),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black12 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: _equipmentTypeDrowpdown()),
            SpacerWidget.size32w,
            Expanded(child: _equipmentNameDropdown()),
            SpacerWidget.size16w,
            SizedBox(
              height: 55,
              width: screenWidth * 0.15,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  _handleSetButton(); // set button function
                },
                child: Center(
                  child: Text(
                    "Set",
                    style: GoogleFonts.openSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedScreen: 'configure'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade400),
                child: Center(
                  child: Text(
                    "Configuration Parameter",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SpacerWidget.size32,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _customTextfield(
                          "High Temp",
                          tempHighController,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Low Temp",
                          tempLowController,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Min Flowrate",
                          minFlowController,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                      ],
                    ),
                    Row(
                      children: [
                        _customTextfield(
                          "Max Flowrate",
                          maxFlowController,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Max Freq",
                          maxFreqController,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Min Freq",
                          minFreqController,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // _customTextfield("BTU", btucontroller),
                        // SpacerWidget.size16w,
                        _customTextfield(
                          "water valve",
                          watervalvecontroller,
                          hintText: "0-100",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 100)) {
                              return 'values from 0–100 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        // _customTextfield(
                        //   "Actuator Direction",
                        //   actuatordircontroller,
                        // ),
                        _customTextfield(
                          "Inlet Threshold",
                          inletcontroller,
                          hintText: "0-15",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 15)) {
                              return 'values from 0–15 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "water delta T",
                          waterdeltacontroller,
                          hintText: "0-10",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 10)) {
                              return 'values from 0–10 only';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _customTextfield(
                          "Water Pressure",
                          waterpressurecontroller,
                          hintText: "0-50",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 50)) {
                              return 'values from 0–50 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Duct pressure",
                          ductpressurecontroller,
                          hintText: "0-2500",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 2500)) {
                              return 'values from 0–2500 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Pressure constant",
                          pressureconstantcontroller,
                          hintText: "0-5",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 5)) {
                              return 'values from 0–5 only';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _customTextfield(
                          "PDI constant",
                          pidconstantcontroller,
                          hintText: "0-10",
                          validator: (value) {
                            if (value!.isEmpty) return null;
                            final number = double.tryParse(value);
                            if (number == null) return 'Invalid number';
                            if ((number < 0 || number > 10)) {
                              return 'values from 0–10 only';
                            }
                            return null;
                          },
                        ),
                        SpacerWidget.size16w,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
