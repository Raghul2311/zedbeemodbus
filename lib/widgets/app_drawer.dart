// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:zedbeemodbus/drawer_folder/configuration_page.dart';
import 'package:zedbeemodbus/drawer_folder/enter_page.dart';
import 'package:zedbeemodbus/drawer_folder/home_screen.dart';
import 'package:zedbeemodbus/drawer_folder/setting_page.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';

class AppDrawer extends StatelessWidget {
  final String selectedScreen;

  const AppDrawer({super.key, required this.selectedScreen});

  @override
  Widget build(BuildContext context) {
    // theme colors...........
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.grey[900]!.withOpacity(0.8)
        : Colors.white.withOpacity(0.6);
    final defaultTextColor = isDarkMode ? Colors.white : Colors.black;
    return SizedBox(
      width: 250,
      child: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Logo at the top of the drawer
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("images/logo.png", height: 50),
                  IconButton(
                    icon: Icon(Icons.close, color: defaultTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SpacerWidget.size16,

            _buildDrawerItem(
              context,
              icon: Icons.home,
              title: 'AHU Model',
              screenName: 'ahumodel',
              screen: const HomeScreen(),
              isDarkMode: isDarkMode,
            ),
            SpacerWidget.large,
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              title: 'Settings',
              screenName: 'settings',
              screen: SettingPage(),
              isDarkMode: isDarkMode,
            ),
            SpacerWidget.large,
            _buildDrawerItem(
              context,
              icon: Icons.build,
              title: 'Configure',
              screenName: 'configure',
              screen: ConfigurationPage(),
              isDarkMode: isDarkMode,
            ),
            SpacerWidget.large,
            _buildDrawerItem(
              context,
              icon: Icons.logout,
              title: 'Logout',
              screenName: 'logout',
              screen: EnterPage(),
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String screenName,
    required Widget screen,
    required bool isDarkMode,
  }) {
    bool isSelected = selectedScreen == screenName;

    // colors for theme dark and light mode selection.........
    final selectedBgColor = AppColors.green;
    final unselectedBgColor = isDarkMode
        ? Colors.grey[800]!.withOpacity(0.4)
        : Colors.white.withOpacity(0.8);

    final selectedTextColor = Colors.white;
    final unselectedTextColor = isDarkMode ? Colors.white70 : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? selectedBgColor // Selected: green background
              : unselectedBgColor, // Unselected: light grey background
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? Colors.white : Colors.black),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? selectedTextColor : unselectedTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            if (!isSelected) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => screen),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
