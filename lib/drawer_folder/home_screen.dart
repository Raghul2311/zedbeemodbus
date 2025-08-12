// ignore_for_file: unused_local_variable, deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';
import 'package:zedbeemodbus/widgets/dialogbox.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String currentTime = ''; // store current time
  bool _isLoading = false; // loading indicator
  List<ParameterModel> savedParams = []; // To save the parameters

  // inintialize the function in init state............
  @override
  void initState() {
    super.initState();
    updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) => updateTime());
    final provider = context.read<ProviderServices>(); // To read the live data
    provider.startAutoRefresh(); // refresh every 5 seconds...
  }

  // To get the upadated time...........
  void updateTime() {
    final nowUtc = DateTime.now().toUtc();
    final istTime = nowUtc.add(const Duration(hours: 5, minutes: 30));
    final formatted = DateFormat('hh:mm:ss a').format(istTime);
    if (!mounted) return;
    setState(() => currentTime = formatted);
  }

  @override
  Widget build(BuildContext context) {
    // media query for height and width...
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final provider = context.watch<ProviderServices>(); // listen
    // chcek the last value
    final latestValue = provider.latestValues;
    final statusValue = latestValue.isNotEmpty ? latestValue[0] : 0;

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // theme background color
      key: _scaffoldKey,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedScreen: 'ahumodel'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Unit Text button
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) {
                            return CustomDialog(
                              title: "Unit Operation",
                              onClose: () => Navigator.pop(context),
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        foregroundColor: Colors.black54,
                      ),
                      icon: const Icon(Icons.ad_units),
                      label: const Text("Unit Operation"),
                    ),
                    // Loading Indicator
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.only(bottom: 24.0),
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                        ),
                      ),
                    SpacerWidget.size16w,
                    // OFF Label
                    Text(
                      'OFF',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statusValue == 1 ? Colors.grey[600] : Colors.red,
                      ),
                    ),
                    SpacerWidget.size8,
                    // Switch with Modbus control
                    Switch(
                      value: statusValue == 1,
                      onChanged: _isLoading
                          ? null
                          : (value) async {
                              final newStatus = value ? 1 : 0;
                              setState(() => _isLoading = true);
                              // Parameter-controlled Modbus write
                              await context
                                  .read<ProviderServices>()
                                  .writeRegisterInstant(
                                    0, // parameter register index
                                    newStatus,
                                  );
                              await Future.delayed(const Duration(seconds: 3));
                              setState(() {
                                _isLoading = false;
                              });
                            },
                      activeColor: Colors.green,
                      inactiveTrackColor: Colors.grey[300],
                      inactiveThumbColor: Colors.red,
                    ),
                    SpacerWidget.size8w,
                    // ON Label
                    Text(
                      'ON',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statusValue == 1
                            ? Colors.green
                            : Colors.grey[600],
                      ),
                    ),
                    SpacerWidget.size16w,
                    // Current Time
                    Text(
                      currentTime,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              // Center(
              //   child: Text(
              //     "AHU Name",
              //     style: GoogleFonts.openSans(
              //       fontSize: 25,
              //       color: Theme.of(context).textTheme.bodyMedium?.color,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
              // SpacerWidget.size32,
              // AHU Image with overlay
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: screenHeight * 0.75,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      if (statusValue == 1)
                        Positioned(
                          top: 20,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Image.asset(
                              "images/gif.gif",
                              height: screenHeight,
                              width: screenWidth,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Image.asset(
                            "images/ahuimage.png",
                            height: screenHeight,
                            width: screenWidth * 0.90,
                            fit: BoxFit.cover,
                          ),
                        ),
                      // parameter from provider dynamically...
                      ...provider.parameters.map((param) {
                        return Positioned(
                          left: param.dx,
                          top: param.dy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${param.text}: ${param.value.isEmpty ? '--' : provider.getFormattedValue(param.text, int.tryParse(param.value) ?? 0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SpacerWidget.size32,
            ],
          ),
        ),
      ),
    );
  }
}
