import 'package:flutter/material.dart';
import 'package:zedbeemodbus/Dropdown_folder/summary_page.dart';
import 'package:zedbeemodbus/Dropdown_folder/trends_screen.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/main.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String selectedSubScreen; // selecting the drop down pages...

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    this.selectedSubScreen = '',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black38 : Color(0xFF003D76);
    final textColor = Colors.white;
    final popupTextColor = isDarkMode ? Colors.white : Colors.black;
    final popupBgColor = isDarkMode ? Colors.grey[850] : Colors.white;
    return AppBar(
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: Icon(Icons.menu, color: textColor),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          Theme(
            data: Theme.of(
              context,
            ).copyWith(popupMenuTheme: PopupMenuThemeData(color: popupBgColor)),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 40),
              onSelected: (value) {
                if (value == 'trends' && selectedSubScreen != 'trends') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => TrendsScreen()),
                  );
                } else if (value == 'summary' &&
                    selectedSubScreen != 'summary') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => SummaryPage()),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'trends',
                  textStyle: TextStyle(color: popupTextColor),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: selectedSubScreen == 'trends'
                            ? AppColors.green
                            : popupTextColor,
                      ),
                      SpacerWidget.size8w,
                      Text(
                        'Trends',
                        style: TextStyle(
                          color: selectedSubScreen == 'trends'
                              ? AppColors.green
                              : popupTextColor,
                          fontWeight: selectedSubScreen == 'trends'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'summary',
                  textStyle: TextStyle(color: popupTextColor),
                  child: Row(
                    children: [
                      Icon(
                        Icons.summarize,
                        color: selectedSubScreen == 'summary'
                            ? AppColors.green
                            : popupTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Summary',
                        style: TextStyle(
                          color: selectedSubScreen == 'summary'
                              ? AppColors.green
                              : popupTextColor,
                          fontWeight: selectedSubScreen == 'summary'
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              child: Row(
                children: const [
                  Text(
                    'Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            themeNotifier.toggleTheme(); // Toggle the theme globally change
          },

          icon: Icon(
            isDarkMode ? Icons.wb_sunny : Icons.dark_mode,
            color: Colors.white,
          ),
          color: Colors.white,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset('images/logo.png', height: 36),
        ),
      ],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
