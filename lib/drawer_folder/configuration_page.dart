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
  final TextEditingController tempHighController = TextEditingController();
  final TextEditingController tempLowController = TextEditingController();
  final TextEditingController minFlowController = TextEditingController();
  final TextEditingController maxFreqController = TextEditingController();
  final TextEditingController minFreqController = TextEditingController();

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
    maxFreqController.dispose();
    minFreqController.dispose();
    super.dispose();
  }

  // set button function .....
  void _handleSetButton() {
    if (tempHighController.text.isEmpty &&
        tempLowController.text.isEmpty &&
        minFlowController.text.isEmpty &&
        maxFreqController.text.isEmpty &&
        minFreqController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set any value"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProviderServices>(context, listen: false);
      // write function each text fields .....
      if (tempHighController.text.isNotEmpty) {
        double value = double.parse(tempHighController.text);
        provider.writeRegister(0, value.toInt());
        _showSnackbar("High Temp set: $value°C");
      }

      if (tempLowController.text.isNotEmpty) {
        double value = double.parse(tempLowController.text);
        provider.writeRegister(1, value.toInt());
        _showSnackbar("Low Temp set: $value°C");
      }

      if (minFlowController.text.isNotEmpty) {
        double value = double.parse(minFlowController.text);
        provider.writeRegister(2, value.toInt());
        _showSnackbar("Min Flowrate set: $value");
      }

      if (maxFreqController.text.isNotEmpty) {
        double value = double.parse(maxFreqController.text);
        provider.writeRegister(3, value.toInt());
        _showSnackbar("Max Frequency set: $value");
      }

      if (minFreqController.text.isNotEmpty) {
        double value = double.parse(minFreqController.text);
        provider.writeRegister(4, value.toInt());
        _showSnackbar("Min Frequency set: $value");
      }
      // clear fields...
      tempHighController.clear();
      tempLowController.clear();
      minFlowController.clear();
      maxFreqController.clear();
      minFreqController.clear();
    }
  }

  // success message ........
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Text field widget ...

  Widget _customTextfield(
    String label,
    TextEditingController controller, {
    bool isValue = false, // boolean for 0 to 50
  }) {
    final screenWidth = MediaQuery.of(context).size.width; // width
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        SizedBox(
          width: screenWidth * 0.30,
          height: 60,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: Colors.blue,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              hintText: isValue ? '0-50' : '',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              final doubleValue = double.tryParse(value);
              if (doubleValue == null) return 'Invalid number';
              if (isValue && (doubleValue < 0 || doubleValue > 50)) {
                return 'values from 0–50 only';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  // equipment name drop down widget ...
  Widget _equipmentNameDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: selectedName,
      decoration: InputDecoration(
        labelText: 'Equipment Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      items: equimentName.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }
  // equipment Type drop down widget ...

  Widget _equipmentTypeDrowpdown() {
    return DropdownButtonFormField<String>(
      value: selectedEquipment,
      decoration: InputDecoration(
        labelText: 'Equipment Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      icon: const Icon(Icons.arrow_drop_down),
      onChanged: (String? newValue) {
        setState(() {
          selectedEquipment = newValue!;
        });
      },
      items: equimentType.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
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
                child: Row(
                  children: [
                    Expanded(child: _equipmentTypeDrowpdown()),
                    SpacerWidget.size32w,
                    Expanded(child: _equipmentNameDropdown()),
                  ],
                ),
              ),
              SpacerWidget.size32,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    _customTextfield(
                      "High Temp",
                      tempHighController,
                      isValue: true,
                    ),
                    SpacerWidget.size16w,
                    _customTextfield(
                      "Low Temp",
                      tempLowController,
                      isValue: true,
                    ),
                    SpacerWidget.size16w,
                    _customTextfield(
                      "Min Flowrate",
                      minFlowController,
                      isValue: true,
                    ),
                    SpacerWidget.size16w,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    _customTextfield(
                      "Max Freq",
                      maxFreqController,
                      isValue: true,
                    ),
                    SpacerWidget.size16w,
                    _customTextfield(
                      "Min Freq",
                      minFreqController,
                      isValue: true,
                    ),
                    SpacerWidget.size16w,
                  ],
                ),
              ),
              SpacerWidget.size16,
              SizedBox(
                height: 55,
                width: screenWidth * 0.15,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
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
      ),
    );
  }
}
