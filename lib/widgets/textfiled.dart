import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zedbeemodbus/fields/colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final TextEditingController controller;
  final Color labelColor;
  final Color? inputTextColor;
  final Color? inputFillColor;
  final Color? cursorColor;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatter;
  final TextInputType? keyboardType;
  const CustomTextFormField({
    super.key,
    this.hintText,
    required this.controller,
    required this.labelColor,
    this.inputFillColor,
    this.inputTextColor,
    this.validator,
    this.cursorColor,
    this.inputFormatter,
    this.keyboardType,
    required List<dynamic> inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: GoogleFonts.openSans(
        fontSize: 15,
        color: inputTextColor,
        fontWeight: FontWeight.w400,
      ),
      cursorColor: inputTextColor,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      inputFormatters: inputFormatter,
      decoration: InputDecoration(
        hintText: hintText,
        labelStyle: TextStyle(color: labelColor, fontWeight: FontWeight.w300),
        filled: true,
        fillColor: inputFillColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.darkblue, width: 1.2),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.green, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: AppColors.darkblue),
        ),
      ),
      validator: validator,
    );
  }
}
