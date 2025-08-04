import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class AddAhuFieldScreen extends StatefulWidget {
  const AddAhuFieldScreen({super.key});

  @override
  State<AddAhuFieldScreen> createState() => _AddAhuFieldScreenState();
}

class _AddAhuFieldScreenState extends State<AddAhuFieldScreen> {
  // controller for fileds...................
  final TextEditingController equipmentTypeController = TextEditingController();
  final TextEditingController equipmentNameController = TextEditingController();
  // global key for feilds........
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // drawer global key

  // dispose for memory space......
  @override
  void dispose() {
    equipmentTypeController.dispose();
    equipmentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(
      context,
    ).size.width; // media query for width
    // colors for dark theme...........
    final backgroundColor = isDarkMode ? Colors.grey[900] : AppColors.lightblue;
    final inputFillColor = isDarkMode ? Colors.black12 : Colors.white;
    final inputTextColor = isDarkMode ? Colors.white : AppColors.darkblue;
    final labelColor = isDarkMode ? Colors.white70 : AppColors.darkblue;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedScreen: ''),
      body: Form(
        key: _formkey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SpacerWidget.size32,
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(color: backgroundColor),
                  child: Center(
                    child: Text(
                      "Add New AHU",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: inputTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SpacerWidget.size32,
                // Equipment Type field
                SizedBox(
                  width: screenWidth / 2,
                  child: TextFormField(
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: inputTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: AppColors.darkblue,
                    controller: equipmentTypeController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      labelText: 'Equipment Type',
                      labelStyle: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.green,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    validator: (value) {
                      final pattern = RegExp(r'^AHU-\d{3}$');
                      if (value == null || value.isEmpty) {
                        return 'Enter your Equipment Type';
                      } else if (!pattern.hasMatch(value)) {
                        return 'Enter in correct format ex: AHU-001';
                      }
                      return null;
                    },
                  ),
                ),
                SpacerWidget.size32,
                // Equipment Name field
                SizedBox(
                  width: screenWidth / 2,
                  child: TextFormField(
                    style: GoogleFonts.openSans(
                      fontSize: 15,
                      color: inputTextColor,
                      fontWeight: FontWeight.w400,
                    ),
                    cursorColor: inputTextColor,
                    controller: equipmentNameController,
                    decoration: InputDecoration(
                      labelText: 'Equipment Name',
                      labelStyle: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.white30
                              : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.green,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your Equipment Name';
                      }
                      return null;
                    },
                  ),
                ),

                SpacerWidget.size64,
                // Save Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 55,
                      width: screenWidth / 6,
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
                          // if (_formkey.currentState!.validate()) {
                          //   Navigator.pop(context);
                          // }
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save",
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SpacerWidget.size32w,
                    SizedBox(
                      height: 55,
                      width: screenWidth / 6,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          // if (_formkey.currentState!.validate()) {
                          //   Navigator.pop(context);
                          // }
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
