// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
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
  bool isSaving = false; // boolean for save button
  final List<Map<String, dynamic>> parameters = [
    {"name": "Status", "unit": ""}, // int
    {"name": "Frequency", "unit": "Hz"}, // float
    {"name": "Auto/Manual", "unit": ""}, // int
    {"name": "Flowrate", "unit": "m³/h"}, //
    {"name": "Water Pressure", "unit": "bar"},
    {"name": "Duct Pressure", "unit": "bar"},
    {"name": "Running Hours 1", "unit": "hr"},
    {"name": "Running Hours 2", "unit": "hr"},
    {"name": "BTU 1", "unit": "kWh"},
    {"name": "BTU 2", "unit": "kWh"},
    {"name": "Water In", "unit": "°C"}, // float
    {"name": "Water Out", "unit": "°C"}, // float
    {"name": "Supply Temp", "unit": "°C"}, // float
    {"name": "Return Temp", "unit": "°C"}, // float
    {"name": "Stop Condition", "unit": ""},
    {"name": "Fire Status", "unit": ""}, // int
    {"name": "Trip Status", "unit": ""}, //int
    {"name": "Filter Status", "unit": ""}, // int
    {"name": "NONC Status", "unit": ""}, // int
    {"name": "Run Status", "unit": ""}, //int
    {"name": "Auto/Manual Status", "unit": ""}, //int
    {"name": "N/A", "unit": ""},
    {"name": "N/A", "unit": ""},
    {"name": "Water Value", "unit": ""}, //int
    {"name": "N/A", "unit": ""},
    {"name": "Voltage", "unit": "V"}, //int
    {"name": "Current", "unit": "A"}, //int
    {"name": "Power", "unit": "kW"}, //int
    {"name": "Delta T Avg", "unit": "°C"}, //float
    {"name": "Set Temperature", "unit": "°C"}, //float
    {"name": "Min Frequency", "unit": "Hz"}, //float
    {"name": "Max Frequency", "unit": "Hz"}, //float
    {"name": "VAV Number", "unit": ""}, //int
    {"name": "PID Constant", "unit": ""}, //int
    {"name": "Ductset Pressure", "unit": "bar"}, //float
    {"name": "Max FlowRate", "unit": "m³/h"}, //float
    {"name": "Min FlowRate", "unit": "m³/h"}, //float
    {"name": "Pressure Constant", "unit": ""}, //float
    {"name": "Inlet Threshold", "unit": ""}, //float
    {"name": "Actuator Direction", "unit": ""}, //int
    {"name": "Actuator Type", "unit": ""}, // int
    {"name": "Min Act Position", "unit": ""}, //int
    {"name": "Ramp Up Sel", "unit": ""}, //int
    {"name": "Water Delta T", "unit": ""}, //int
    {"name": "Pressure Temp Sel", "unit": ""}, //float
    {"name": "N/A", "unit": ""},
    {"name": "Flowmeter Type", "unit": ""}, //int
    {"name": "7 Span", "unit": ""}, //int
    {"name": "6 Span", "unit": ""}, //int
    {"name": "Min Set Temp", "unit": "°C"}, //float
    {"name": "Max Set Temp", "unit": "°C"}, //float
    {"name": "1", "unit": ""}, //int
    {"name": "9600", "unit": ""}, //int
    {"name": "0", "unit": ""}, //int
    {"name": "1", "unit": ""}, //int
    {"name": "Schedule ON/OFF", "unit": ""}, //int
    {"name": "Schedule ON Time", "unit": ""}, //int
    {"name": "Schedule OFF Time", "unit": ""}, //int
    {"name": "Poll Time", "unit": ""}, //int
    // Total 59 values ............
  ];

  List<int> selectedIndexes = []; // store the selected index..
  // float types parameters .......
  final List<String> floatValueNames = [
    "Frequency",
    "Water In",
    "Water Out",
    "Supply Temp",
    "Return Temp",
    "Delta T Avg",
    "Set Temperature",
    "Min Frequency",
    "Max Frequency",
    "Max FlowRate",
    "Min FlowRate",
    "Pressure Constant",
    "Inlet Threshold",
    "Pressure Temp Sel",
    "Min Set Temp",
    "Max Set Temp",
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderServices>(context, listen: false);
    provider.fetchRegisters();
    provider.startAutoRefresh(); // auto refresh 5 seconds
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
                      // status ON/OFF
                      String value;
                      value = index < provider.latestValues.length
                          ? (param["name"] == "Status" ||
                                    param["name"] == "Fire Status" ||
                                    param["name"] == "Schedule ON/OFF"
                                ? (provider.latestValues[index] == 1
                                      ? "ON"
                                      : "OFF")
                                : param["name"] == "Auto/Manual Status"
                                ? (provider.latestValues[index] == 0
                                      ? "OFF"
                                      : provider.latestValues[index] == 1
                                      ? "AUTO"
                                      : provider.latestValues[index] == 2
                                      ? "MANUAL"
                                      : "--")
                                : floatValueNames.contains(param["name"])
                                ? (provider.latestValues[index] / 100)
                                      .toStringAsFixed(2)
                                : provider.latestValues[index].toString())
                          : "--";
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
                const SizedBox(height: 150),
              ],
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }
}
