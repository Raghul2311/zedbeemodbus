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
  // controller ........
  final TextEditingController valueController = TextEditingController();
  bool isSaving = false; // boolean for save button

  

  List<int> selectedIndexes = []; // store the selected params..

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
    provider.addParameters(selectedIndexes, provider.allParameters);
    setState(() => isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context);
final parameters = provider.allParameters;

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
                          ? provider.getFormattedValue(
                              param["name"] as String,
                              provider.latestValues[index],
                            )
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
