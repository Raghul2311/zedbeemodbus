import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';
import 'package:zedbeemodbus/widgets/textfiled.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // controller for field....
  final _formkey = GlobalKey<FormState>();
  final tempHighController = TextEditingController();
  final tempLowController = TextEditingController();
  final minFlowController = TextEditingController();
  final minFreqController = TextEditingController();
  final maxFreqController = TextEditingController();
  bool isDarkMode = false;
  Color labelColor = Colors.grey;
  Color inputFillColor = Colors.white60;
  Color cursorColor = AppColors.green;

  // set button function
  void _handleSetButton() async {
    // all the fields are empty ...
    bool allEmpty =
        tempHighController.text.isEmpty &&
        tempLowController.text.isEmpty &&
        minFlowController.text.isEmpty &&
        maxFreqController.text.isEmpty &&
        minFreqController.text.isEmpty;

    if (allEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please set any value"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    // validate form ....
    if (_formkey.currentState!.validate()) {
      // individual snack bar message ....
      if (tempHighController.text.isNotEmpty) {
        final highTemp = double.tryParse(tempHighController.text);
        _showSnackBar("High Temp set to $highTemp°C");
      }
      if (tempLowController.text.isNotEmpty) {
        final lowTemp = double.tryParse(tempLowController.text);
        _showSnackBar("Low Temp set to $lowTemp°C");
      }
      if (maxFreqController.text.isNotEmpty) {
        final maxfreq = double.tryParse(maxFreqController.text);
        _showSnackBar("Max Frequency set to $maxfreq");
      }
      if (minFreqController.text.isNotEmpty) {
        final minfreq = double.tryParse(minFreqController.text);
        _showSnackBar("Min Frequecny set to $minfreq");
      }
      if (minFlowController.text.isNotEmpty) {
        final minFlow = double.tryParse(minFlowController.text);
        _showSnackBar("Min Flowrate set to $minFlow");
      }
      // clear fields ...
      tempHighController.clear();
      tempLowController.clear();
      minFlowController.clear();
      minFreqController.clear();
      maxFreqController.clear();
    }
  }

  // scafold Message ...
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedScreen: 'configure'),
      body: SafeArea(
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SpacerWidget.large,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Set Temperature High",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SpacerWidget.medium,
                            SizedBox(
                              height: 80,
                              child: CustomTextFormField(
                                controller: tempHighController,
                                cursorColor: cursorColor,
                                hintText: "Set Temp from 0 to 50",
                                inputFillColor: inputFillColor,
                                labelColor: labelColor,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ), // accepts numeric and decimals
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null ||
                                      doubleValue < 0 ||
                                      doubleValue > 50) {
                                    return "Temperature Must be 0–50";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpacerWidget.size16w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Set Temperature Low",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SpacerWidget.medium,
                            SizedBox(
                              height: 80,
                              child: CustomTextFormField(
                                controller: tempLowController,
                                cursorColor: cursorColor,
                                hintText: "set Temp from 0 to 50",
                                inputFillColor: inputFillColor,
                                labelColor: labelColor,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ), // accepts numeric and decimals
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null ||
                                      doubleValue < 0 ||
                                      doubleValue > 50) {
                                    return "Temp Must be 0-50";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpacerWidget.size16w,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Minimun Flowrate",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SpacerWidget.medium,
                            SizedBox(
                              height: 80,
                              child: CustomTextFormField(
                                controller: minFlowController,
                                cursorColor: cursorColor,
                                hintText: "set Temp from 0 to 50",
                                inputFillColor: inputFillColor,
                                labelColor: labelColor,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ), // accepts numeric and decimals
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null ||
                                      doubleValue < 0 ||
                                      doubleValue > 50) {
                                    return "Temp Must be 0-50";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpacerWidget.size16w,
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 55,
                            width: 100,
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Minimun Frequecny",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SpacerWidget.medium,
                            SizedBox(
                              height: 80,
                              width: screenWidth * 0.30,

                              child: CustomTextFormField(
                                controller: minFreqController,
                                cursorColor: cursorColor,
                                hintText: "set Min Frequency from 0 to 50",
                                inputFillColor: inputFillColor,
                                labelColor: labelColor,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ), // accepts numeric and decimals
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null ||
                                      doubleValue < 0 ||
                                      doubleValue > 50) {
                                    return "Frequency Must be 0-50";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SpacerWidget.size16w,
                      SizedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Maximium Frequecny",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SpacerWidget.medium,
                            SizedBox(
                              height: 80,
                              width: screenWidth * 0.28,
                              child: CustomTextFormField(
                                controller: maxFreqController,
                                cursorColor: cursorColor,
                                hintText: "set Max Frequency from 0 to 50",
                                inputFillColor: inputFillColor,
                                labelColor: labelColor,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ), // accepts numeric and decimals
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return null;
                                  }
                                  final doubleValue = double.tryParse(value);
                                  if (doubleValue == null ||
                                      doubleValue < 0 ||
                                      doubleValue > 50) {
                                    return "Max Frequency Must be 0-50";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
