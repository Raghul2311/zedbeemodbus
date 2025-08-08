// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';

class CustomToggleContainer extends StatefulWidget {
  final String title;
  final List<String> options;
  final Color containerColor;
  final Color fillColor;
  final Color splashColor;
  final Color titleColor;

  const CustomToggleContainer({
    super.key,
    required this.title,
    required this.options,
    required this.containerColor,
    required this.fillColor,
    required this.splashColor,
    required this.titleColor,
  });

  @override
  State<CustomToggleContainer> createState() => _CustomToggleContainerState();
}

class _CustomToggleContainerState extends State<CustomToggleContainer> {
  late List<bool> _isSelected; // track selection

  @override
  void initState() {
    super.initState();
    _isSelected = List.generate(widget.options.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: widget.containerColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: widget.titleColor,
            ),
          ),
          SpacerWidget.size16,
          ToggleButtons(
            isSelected: _isSelected,
            onPressed: (int index) {
              setState(() {
                for (int i = 0; i < _isSelected.length; i++) {
                  _isSelected[i] = (i == index);
                }
              });
            },
            borderRadius: BorderRadius.circular(10.0),
            selectedBorderColor: Colors.black,
            selectedColor: Colors.white,
            fillColor: widget.fillColor,
            color: Colors.blueGrey,
            splashColor: widget.splashColor,
            children: widget.options.map<Widget>((String option) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Text(option, style: const TextStyle(fontSize: 16.0)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20.0),
          Text(
            "${widget.title} : ${widget.options[_isSelected.indexOf(true)]}",
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
