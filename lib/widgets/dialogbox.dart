import 'package:flutter/material.dart';
import 'package:zedbeemodbus/widgets/custom_inputfield.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const CustomDialog({
    super.key,
    required this.title,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomInputField(
                label: "High Temperature",
                onSave: (value) {
                  print("High Temperature saved: $value");
                  // Call Modbus write for High Temp
                },
              ),
              CustomInputField(
                label: "Low Temperature",
                onSave: (value) {
                  print("Low Temperature saved: $value");
                },
              ),
              CustomInputField(
                label: "Max Frequency",
                onSave: (value) {
                  print("Max Frequency saved: $value");
                },
              ),
              CustomInputField(
                label: "Min Frequency",
                onSave: (value) {
                  print("Min Frequency saved: $value");
                },
              ),
              CustomInputField(
                label: "Flow Rate",
                onSave: (value) {
                  print("Flow Rate saved: $value");
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text("Close"),
        ),
      ],
    );
  }
}
