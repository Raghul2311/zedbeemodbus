// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import '../fields/colors.dart';
import '../services_class/provider_services.dart';

class ParametersListScreen extends StatefulWidget {
  const ParametersListScreen({super.key});

  @override
  State<ParametersListScreen> createState() => _ParametersListScreenState();
}

class _ParametersListScreenState extends State<ParametersListScreen> {
  final TextEditingController valueController = TextEditingController();
  int? selectedRegister;
  bool isSaving = false;

  final List<Map<String, String>> parameters = [
    {"name": "Status", "unit": ""},
    {"name": "Frequency", "unit": "Hz"},
    {"name": "Auto/Manual", "unit": ""},
    {"name": "Flowrate", "unit": "m³/h"},
    {"name": "Water Pressure", "unit": "bar"},
    {"name": "Duct Pressure", "unit": "bar"},
    {"name": "Running Hours 1", "unit": "hr"},
    {"name": "Running Hours 2", "unit": "hr"},
    {"name": "BTU 1", "unit": "kWh"},
    {"name": "BTU 2", "unit": "kWh"},
    {"name": "Water In", "unit": "°C"},
    {"name": "Water Out", "unit": "°C"},
    {"name": "Supply Temp", "unit": "°C"},
    {"name": "Return Temp", "unit": "°C"},
    {"name": "Stop Condition", "unit": ""},
    {"name": "Fire Status", "unit": ""},
    {"name": "Trip Status", "unit": ""},
    {"name": "Filter Status", "unit": ""},
    {"name": "NONC Status", "unit": ""},
    {"name": "Run Status", "unit": ""},
    {"name": "Auto/Manual Status", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Water Value", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Voltage", "unit": "V"},
    {"name": "Current", "unit": "A"},
    {"name": "Power", "unit": "kW"},
    {"name": "Delta T Avg", "unit": "°C"},
    {"name": "Set Temperature", "unit": "°C"},
    {"name": "Min Frequency", "unit": "Hz"},
    {"name": "Max Frequency", "unit": "Hz"},
    {"name": "VAV Number", "unit": ""},
    {"name": "PID Constant", "unit": ""},
    {"name": "Ductset Pressure", "unit": "bar"},
    {"name": "Max FlowRate", "unit": "m³/h"},
    {"name": "Min FlowRate", "unit": "m³/h"},
    {"name": "Pressure Constant", "unit": ""},
    {"name": "Inlet Threshold", "unit": ""},
    {"name": "Actuator Direction", "unit": ""},
    {"name": "Actuator Type", "unit": ""},
    {"name": "Min Act Position", "unit": ""},
    {"name": "Ramp Up Sel", "unit": ""},
  ];

  List<int> selectedIndexes = []; // store the selected index..

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderServices>(context, listen: false);
    provider.fetchRegisters();
    provider.startAutoRefresh(); // auto refresh 5 seconds
  }

  // write parameter fucntion.......
  void handleWrite() {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    final valueText = valueController.text.trim();

    if (selectedRegister == null) {
      showSnackBar("Select a register");
      return;
    }
    if (valueText.isEmpty) {
      showSnackBar("Enter a value");
      return;
    }

    final value = int.tryParse(valueText);
    if (value == null) {
      showSnackBar("Invalid number");
      return;
    }
    // get the register of paramter to write
    provider.writeRegister(selectedRegister!, value);
    valueController.clear();
    setState(() {
      selectedRegister = null;
    });
    showSnackBar("parameter updated successfully");
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // save the selected parameters
  void saveSelectedParameters() async {
    final provider = Provider.of<ProviderServices>(context, listen: false);
    provider.addParameters(selectedIndexes, parameters);
    setState(() => isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark; // Theme

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modbus Parameters",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.darkblue,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.green,
            onRefresh: () => provider.fetchRegisters(),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: parameters.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // Show 4 per row
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                    itemBuilder: (context, index) {
                      final param = parameters[index];
                      final isSelected = selectedIndexes.contains(index);
                      // 0 for OFF and 1 for ON.........
                      String value;
                      if (index < provider.latestValues.length) {
                        if (index == 0) {
                          value = provider.latestValues[index] == 1
                              ? "ON"
                              : "OFF";
                        } else {
                          value = provider.latestValues[index].toString();
                        }
                      } else {
                        value = "--";
                      }
                      // select the parmeter
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIndexes.remove(index);
                            } else {
                              if (selectedIndexes.length < 5) {
                                selectedIndexes.add(index);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Only 5 parameters can be selected at a time !!!!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.green
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                param["name"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              SpacerWidget.size8w,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SpacerWidget.size8w,
                                  Text(
                                    param["unit"]!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 150),
              ],
            ),
          ),
          // floating action container ..........
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black54
                        : Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButton<int>(
                          value: selectedRegister,
                          dropdownColor: Theme.of(context).cardColor,
                          underline: SizedBox(),
                          iconEnabledColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          hint: Text(
                            "Select Register",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          items: selectedIndexes
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    parameters[e]["name"]!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => selectedRegister = val),
                        ),
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
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
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
                  SpacerWidget.medium,
                  // save parameter button .....
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
