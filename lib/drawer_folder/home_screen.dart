// ignore_for_file: unused_local_variable, deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String currentTime = ''; // store current time
  bool isSwitched = false; // switch for ON/OFF button
  List<ParameterModel> savedParams = []; // To save the parameters
  // controller for pin text field.......
  final TextEditingController pinController = TextEditingController();

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
    final provider = context
        .watch<ProviderServices>(); // listen and update in UI
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
                    // ON/OFF Toggle
                    Row(
                      children: [
                        Text(
                          'ON',
                          style: TextStyle(
                            fontSize: 18,
                            color: isSwitched
                                ? Theme.of(context).textTheme.bodyMedium?.color
                                : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Switch(
                            value: isSwitched,
                            onChanged: (value) =>
                                setState(() => isSwitched = value),
                            activeColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            activeTrackColor: Colors.green,
                            inactiveThumbColor: Theme.of(
                              context,
                            ).colorScheme.onSurface,
                            inactiveTrackColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        Text(
                          'OFF',
                          style: TextStyle(
                            fontSize: 18,
                            color: isSwitched
                                ? Colors.grey
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
              Center(
                child: Text(
                  "AHU Name",
                  style: GoogleFonts.openSans(
                    fontSize: 25,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SpacerWidget.size32,
              // AHU Image with overlay
              Center(
                child: Container(
                  height: 400,
                  width: 800,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      if (isSwitched)
                        Positioned(
                          top: 20,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Image.asset(
                              "images/gif.gif",
                              height: screenHeight,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        Center(
                          child: Image.asset(
                            "images/ahuimage.png",
                            height: screenHeight * 0.50,
                            width: screenWidth * 0.53,
                            fit: BoxFit.fill,
                          ),
                        ),
                      // parameter from provider dynamically
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
                              "${param.text}: ${param.value.isEmpty ? '--' : param.value}",
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
            ],
          ),
        ),
      ),
    );
  }
}
