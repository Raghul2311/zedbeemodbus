import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  final List<String> parameterLabels = [
    "Status", // 00000
    "Frequency", // 00001
    "Auto/Manual", // 00002
    "Flowrate", // 00003
    "Water Pressure", // 00004
    "Duct Pressure", // 00005
    "Running hours", // 00006
    "Running hours", // 00007
    "BTU", // 00008
    "BTU", // 00009
    "Water In", // 00010
    "Water Out", // 00011
    "Supply Temperature", // 00012
    "Return Temperature", // 00013
    "Stop Condition", // 00014
    "Fire Status", // 00015
    "Trip Status", // 00016
    "Filter Status", // 00017
    "NONC Status", // 00018
    "Run Status", // 00019
    "Auto/Manual Status", // 00020
    "N/A", // 00021
    "N/A", // 00022
    "Water Value", // 00023
    "N/A", // 00024
    "Voltage", // 00025
    "Current", // 00026
    "Power", // 00027
    "Delta TAverage", // 00028
    "Set Temperature", // 00029
    "Minimum Frequency", // 00030
    "Maximum Frequency", // 00031
    "VAV Number", // 00032
    "PID Constant", // 00033
    "Ductset Pressure", // 00034
    "Maximun FlowRate", // 00035
    "Minimum FlowRate", // 00036
    "Pressure Constant", // 00037
    "Inlet Threshold", // 00038
    "Actuator Direction", // 00039
    "Actuator Type", // 00040
    "Minimum Act Position", // 00041
    "Ramp Up Sel", // 00042
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ProviderServices>(context, listen: false);
    provider.fetchRegisters();
    provider.startAutoRefresh(); // auto update every 5 sec
  }

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

    provider.writeRegister(selectedRegister!, value);
    valueController.clear();
    setState(() {
      selectedRegister = null;
    });
    showSnackBar("Value updated successfully");
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void saveSelectedParameters() async {
    setState(() => isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context); // or navigate to Settings
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modbus Parameter",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.darkblue,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Registers Loaded: ${provider.latestValues.length}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Divider(),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.green,
                  onRefresh: () => provider.fetchRegisters(),
                  child: ListView.builder(
                    itemCount: parameterLabels.length,
                    itemBuilder: (context, index) {
                      final paramName = parameterLabels[index];
                      final value = (index < provider.latestValues.length)
                          ? provider.latestValues[index].toString()
                          : "--";

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: provider.parameters.any(
                                      (p) => p.registerIndex == index,
                                    ),
                                    activeColor: AppColors.darkblue,
                                    onChanged: (checked) {
                                      if (checked == true) {
                                        provider.addParameter(
                                          paramName,
                                          index: index,
                                        );
                                      } else {
                                        provider.removeParameter(index);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    paramName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                value,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 150),
            ],
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
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
                      DropdownButton<int>(
                        value: selectedRegister,
                        hint: const Text("Select Register"),
                        items: provider.parameters
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.registerIndex,
                                child: Text(e.text),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedRegister = val),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: valueController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: "Value",
                            isDense: true,
                            border: OutlineInputBorder(),
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
                  const SizedBox(height: 12),
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
