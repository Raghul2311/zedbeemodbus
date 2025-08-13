import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';

class UnitDialogbox extends StatefulWidget {
  const UnitDialogbox({super.key});

  @override
  State<UnitDialogbox> createState() => _UnitDialogboxState();
}

class _UnitDialogboxState extends State<UnitDialogbox> {
  final _formKey = GlobalKey<FormState>();

  final setTemperatureController = TextEditingController();
  final setFrequencyController = TextEditingController();

  @override
  void dispose() {
    setTemperatureController.dispose();
    setFrequencyController.dispose();
    super.dispose();
  }

  Widget saveButton(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 50,
      width: 120,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget customTextfield(
    String label,
    TextEditingController controller, {
    String hintText = "",
    FormFieldValidator<String>? validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final labelColor = isDarkMode ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
        SpacerWidget.small,
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.30,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      contentPadding: EdgeInsets.zero, // remove default padding
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        height: screenHeight * 0.70,
        width: screenWidth * 0.50,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade300,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      topLeft: Radius.circular(15),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Unit Operation",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SpacerWidget.size32,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customTextfield(
                      "Set Temperature",
                      setTemperatureController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Set Temperature value";
                        }
                        final number = double.tryParse(value);
                        if (number == null) {
                          return "Invalid number";
                        }
                        if (number < 15 || number > 25) {
                          return "Temperature between 15 to 25";
                        }
                        return null;
                      },
                    ),
                    SpacerWidget.size32w,
                    saveButton("Save", () {
                      if (_formKey.currentState!.validate()) {
                        print("Temperature: ${setTemperatureController.text}");
                      }
                    }),
                  ],
                ),
                SpacerWidget.size16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    customTextfield(
                      "Set Frequency",
                      setFrequencyController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Set Frequency";
                        }
                        final number = double.tryParse(value);
                        if (number == null) {
                          return "Invalid number";
                        }
                        if (number < 20 || number > 30) {
                          return "Frequency between 20 to 30";
                        }
                        return null;
                      },
                    ),
                    SpacerWidget.size32w,
                    saveButton("Save", () {
                      if (_formKey.currentState!.validate()) {
                        print("Frequency: ${setFrequencyController.text}");
                      }
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Close",
            style: TextStyle(fontSize: 16, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
