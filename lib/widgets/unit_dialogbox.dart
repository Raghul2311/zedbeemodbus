// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';

class UnitDialogbox extends StatefulWidget {
  const UnitDialogbox({super.key});

  @override
  State<UnitDialogbox> createState() => _UnitDialogboxState();
}

class _UnitDialogboxState extends State<UnitDialogbox> {
  // Controllers
  final setTemperatureController = TextEditingController();
  final setFrequencyController = TextEditingController();

  bool isLoading = false;

  // Error messages for each field
  String? temperatureError;
  String? frequencyError;

  @override
  void dispose() {
    setTemperatureController.dispose();
    setFrequencyController.dispose();
    super.dispose();
  }

  // Save button widget
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

  // Custom TextField widget
  Widget customTextfield(
    String label,
    TextEditingController controller, {
    String? errorText,
    String hintText = "",
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
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: isDarkMode ? AppColors.green : AppColors.darkblue,
            style: TextStyle(color: labelColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              hintText: hintText,
              errorText: errorText,
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
          ),
        ),
      ],
    );
  }

  // Validation functions
  String? validateTemperature(String value) {
    if (value.isEmpty) return "Set Temperature value";
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 15 || number > 25) return "Temperature between 15 to 25";
    return null;
  }

  String? validateFrequency(String value) {
    if (value.isEmpty) return "Set Frequency value";
    final number = double.tryParse(value);
    if (number == null) return "Invalid number";
    if (number < 20 || number > 30) return "Frequency between 20 to 30";
    return null;
  }

  // write function
  Future<void> writeParameter(
    BuildContext context,
    int address,
    String value,
    String paramName,
  ) async {
    try {
      final writeValue = (double.parse(value) * 100).toInt();
      await context.read<ProviderServices>().writeRegister(address, writeValue);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$paramName changed to $value°C",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to changed $paramName: $e°C",
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        height: screenHeight * 0.70,
        width: screenWidth * 0.50,
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

              // Temperature Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "Set Temperature",
                    setTemperatureController,
                    errorText: temperatureError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () async {
                    setState(() {
                      temperatureError = validateTemperature(
                        setTemperatureController.text.trim(),
                      );
                    });
                    if (temperatureError == null) {
                      setState(() {
                        isLoading = true; // start loading
                      });
                      // Delay time
                      await Future.delayed(const Duration(seconds: 5));
                      // write register
                      await writeParameter(
                        context,
                        29,
                        setTemperatureController.text.trim(),
                        "Set Temperature",
                      );
                      setState(() {
                        isLoading = false;
                        // close the dialog box
                        Navigator.pop(context);
                      });

                      setTemperatureController.clear();
                    }
                  }),
                  SpacerWidget.size8w,
                  if (isLoading)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                ],
              ),
              SpacerWidget.size16,
              // Frequency Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customTextfield(
                    "Set Frequency",
                    setFrequencyController,
                    errorText: frequencyError,
                  ),
                  SpacerWidget.size32w,
                  saveButton("Save", () {
                    setState(() {
                      frequencyError = validateFrequency(
                        setFrequencyController.text.trim(),
                      );
                    });
                    if (frequencyError == null) {
                      print("Frequency: ${setFrequencyController.text}");
                      setFrequencyController.clear();
                    }
                  }),
                ],
              ),
            ],
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
