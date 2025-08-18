// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';
import 'package:zedbeemodbus/widgets/toggle_button.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  // Global keys..
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // text fields
  final _formKey = GlobalKey<FormState>();

  // controllers for fields ...
  final minTemController = TextEditingController();
  final maxTempController = TextEditingController();
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
  bool isLoading = false; // loading indiactor

  @override
  void dispose() {
    minTemController.dispose();
    maxTempController.dispose();
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

  // write function
  Future<void> writeParameter(
    BuildContext context,
    int address,
    String value,
    String paramName,
  ) async {
    try {
      // Accept int or float values ...
      final writeValue = (double.parse(value) * 100).toInt();

      await context.read<ProviderServices>().writeRegister(address, writeValue);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$paramName changed to $value",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to change $paramName: $e",
              style: const TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // set button function .....
  void _handleSetButton() async {
    if (minTemController.text.isEmpty &&
        maxTempController.text.isEmpty &&
        minFlowController.text.isEmpty &&
        maxFlowController.text.isEmpty &&
        minFreqController.text.isEmpty &&
        maxFreqController.text.isEmpty &&
        watervalvecontroller.text.isEmpty &&
        inletcontroller.text.isEmpty &&
        waterdeltacontroller.text.isEmpty &&
        waterpressurecontroller.text.isEmpty &&
        pressureconstantcontroller.text.isEmpty &&
        pidconstantcontroller.text.isEmpty) {
      // Empty clicking on set button
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please set some values",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // validate fields ..
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      isLoading = true; // show loading
    });

    // Delay time
    await Future.delayed(const Duration(seconds: 2));
    // mapping register start here .....
    if (minTemController.text.isNotEmpty) {
      await writeParameter(
        context,
        49, // register address for Min Temp
        minTemController.text.trim(),
        "Min Temp",
      );
    }
    if (maxTempController.text.isNotEmpty) {
      await writeParameter(
        context,
        50, // register address for Min Temp
        maxTempController.text.trim(),
        "Max Temp",
      );
    }
    if (minFlowController.text.isNotEmpty) {
      await writeParameter(
        context,
        36, // reg address for min flow
        minFlowController.text.trim(),
        "Min Flowrate",
      );
    }
    if (maxFlowController.text.isNotEmpty) {
      await writeParameter(
        context,
        35, // reg address for max flow
        maxFlowController.text.trim(),
        "Max Flowrate",
      );
    }
    if (minFreqController.text.isNotEmpty) {
      await writeParameter(
        context,
        30, // reg address for min freq
        minFreqController.text.trim(),
        "Min Frequency",
      );
    }
    if (maxFreqController.text.isNotEmpty) {
      await writeParameter(
        context,
        31, // reg address for max freq
        minFreqController.text.trim(),
        "Min Frequecny",
      );
    }
    if (watervalvecontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        23, // reg address for water value
        watervalvecontroller.text.trim(),
        "Water value",
      );
    }
    if (inletcontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        38, //reg address for inlet
        inletcontroller.text.trim(),
        "Inlet Threshold",
      );
    }
    if (waterdeltacontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        43, // reg address for water delta
        waterdeltacontroller.text.trim(),
        "Water Delta",
      );
    }
    if (waterpressurecontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        4, // reg address for water pressure
        waterpressurecontroller.text.trim(),
        "Water Pressure",
      );
    }

    if (ductpressurecontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        5, // reg address for duct pressure
        ductpressurecontroller.text.trim(),
        "Duct Pressure",
      );
    }
    if (pressureconstantcontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        37, // reg address for pressure constant
        pressureconstantcontroller.text.trim(),
        "Pressure Constant",
      );
    }

    if (pidconstantcontroller.text.isNotEmpty) {
      await writeParameter(
        context,
        33, // reg address for pid cosntant
        pidconstantcontroller.text.trim(),
        "PID Constant",
      );
    }

    setState(() {
      isLoading = false; // stop loading
    });

    // clear fields ............
    minTemController.clear();
    maxTempController.clear();
    minFlowController.clear();
    maxFlowController.clear();
    minFreqController.clear();
    maxFreqController.clear();
    watervalvecontroller.clear();
    inletcontroller.clear();
    waterdeltacontroller.clear();
    waterpressurecontroller.clear();
    ductpressurecontroller.clear();
    pressureconstantcontroller.clear();
    pidconstantcontroller.clear();
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
            cursorColor: isDarkMode ? AppColors.green : AppColors.darkblue,
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

  // validator for text fields
  String? numberValidator(String? value, String label, double min, double max) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < min || number > max) {
      return "Value must be between $min - $max";
    }
    return null;
  }

  // equipment name drop down widget ...
  Widget _equipmentNameDropdown() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: selectedName,
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
      initialValue: selectedEquipment,
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
          color: isDarkMode ? Colors.black : Colors.white,
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
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
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
                          "Min Temp",
                          minTemController,
                          hintText: "0-50",
                          validator: (value) =>
                              numberValidator(value, "Min Temp", 0, 50),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Max Temp",
                          maxTempController,
                          hintText: "0-50",
                          validator: (value) =>
                              numberValidator(value, "Max Temp", 0, 50),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Min Flowrate",
                          minFlowController,
                          hintText: "0-50",
                          validator: (value) =>
                              numberValidator(value, "Min Flowrate", 0, 50),
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
                          validator: (value) =>
                              numberValidator(value, "Max Flowrate", 0, 50),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Max Freq",
                          maxFreqController,
                          hintText: "0-50",
                          validator: (value) =>
                              numberValidator(value, "Max Frequency", 0, 50),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Min Freq",
                          minFreqController,
                          hintText: "0-50",
                          validator: (value) =>
                              numberValidator(value, "Min Frequecny", 0, 50),
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
                          validator: (value) =>
                              numberValidator(value, "Water value", 0, 100),
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
                          validator: (value) =>
                              numberValidator(value, "Inlet Threshold", 0, 15),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "water delta T",
                          waterdeltacontroller,
                          hintText: "0-10",
                          validator: (value) =>
                              numberValidator(value, "Water Delta", 0, 10),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _customTextfield(
                          "Water Pressure",
                          waterpressurecontroller,
                          hintText: "0-50",
                          validator: (value) =>
                              numberValidator(value, "Water Pressure", 0, 50),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Duct pressure",
                          ductpressurecontroller,
                          hintText: "0-2500",
                          validator: (value) =>
                              numberValidator(value, "Duct Pressure", 0, 2500),
                        ),
                        SpacerWidget.size16w,
                        _customTextfield(
                          "Pressure constant",
                          pressureconstantcontroller,
                          hintText: "0-5",
                          validator: (value) =>
                              numberValidator(value, "Pressure Constant", 0, 5),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _customTextfield(
                          "PDI constant",
                          pidconstantcontroller,
                          hintText: "0-10",
                          validator: (value) =>
                              numberValidator(value, "PDI Constant", 0, 10),
                        ),
                      ],
                    ),
                    SpacerWidget.size32,
                    // configuration toggle button
                    Row(
                      children: [
                        // Internal and External
                        CustomToggleContainer(
                          title: "BTU Selection",
                          options: ["Internal", "External"],
                          fillColor: Colors.green,
                          splashColor: Colors.green.shade100,
                          titleColor: Colors.green,
                        ),
                        SpacerWidget.size64w,
                        // temp & pressure
                        CustomToggleContainer(
                          title: "Control",
                          options: ["Temperature", "Pressure"],
                          fillColor: Colors.red,
                          splashColor: Colors.red.shade100,
                          titleColor: Colors.red,
                        ),
                        SpacerWidget.size64w,
                        // Actuator Direction
                        CustomToggleContainer(
                          title: "Actuator Direction",
                          options: ['Forward', 'Reverse'],
                          fillColor: Colors.blue,
                          splashColor: Colors.blue.shade100,
                          titleColor: Colors.blue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 180),
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
