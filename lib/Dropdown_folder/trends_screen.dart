import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zedbeemodbus/fields/colors.dart';
import 'package:zedbeemodbus/fields/spacer_widget.dart';
import 'package:zedbeemodbus/widgets/app_bar.dart';
import 'package:zedbeemodbus/widgets/app_drawer.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  // drawer global key............
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> equimentType = [
    'AHU',
    'FCU',
    'VRF',
    'Chiller',
    'Cooling Tower',
  ];

  final List<String> parameters = [
    'Flow meter',
    'Water Temperture',
    'BTU',
    'Power',
    'Voltage',
    'Current',
  ];

  // parameter names for above charts............
  final List<String> parameterNames = [
    'H2O Valve set',
    'return air',
    'filter status',
    'AHU Status',
    'BTU',
    'Water Flowrate',
    'Water_in',
    'Water_out',
    'Supply Air',
    'Ambient Duct Pressure',
  ];

  // parameter colors
  final List<Color> parameterColors = const [
    Colors.pink,
    Colors.deepOrange,
    Colors.purple,
    Colors.orange,
    Colors.pinkAccent,
    Colors.yellow,
    Colors.green,
    Colors.orangeAccent,
    Colors.red,
    Colors.brown,
  ];

  List<String> selectedParameters = []; // store the parameter

  late String selectedType; // initialize the selected type later....

  @override
  void initState() {
    super.initState();
    selectedType = equimentType.first;
    selectedParameters = []; // To store the parameters
  }

  // cureent data....
  String getCurrentFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('MMM dd yyyy');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    // dark theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // colors..
    final popupTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        selectedSubScreen: 'trends',
      ),
      drawer: AppDrawer(selectedScreen: ''),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade300),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AHU Analysis",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.black, size: 25),
                      SpacerWidget.size4w,
                      Text(
                        "Today :",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SpacerWidget.size4w,
                      Text(
                        getCurrentFormattedDate(),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SpacerWidget.size32,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  // equipment drop down ..........
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Filter By Equipment',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: popupTextColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: equimentType.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SpacerWidget.size16w,
                Expanded(
                  // parameter dialouge box list.......
                  child: GestureDetector(
                    onTap: _showMultiSelectDialog,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: popupTextColor),

                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected: ${selectedParameters.length}',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                SpacerWidget.size16w,
                Row(
                  children: [
                    // run hours..........
                    Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Run Hour(s)",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SpacerWidget.medium,
                            Text(
                              "11 hrs 30 mins",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SpacerWidget.size16w,
                    // run count..........
                    Container(
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Run Count",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SpacerWidget.medium,
                            Text(
                              "15",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SpacerWidget.size16w,
                    // container for list data
                    Container(
                      width: 180,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BTU Consumed",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SpacerWidget.medium,
                            Text(
                              "278.9",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SpacerWidget.size32,
          // parameter legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(parameterNames.length, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    color: parameterColors[index],
                  ),
                  SpacerWidget.size8w,
                  Text(parameterNames[index], style: TextStyle(fontSize: 12)),
                ],
              );
            }),
          ),
          SpacerWidget.large,
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int hour = value.toInt();
                        if (hour >= 0 && hour <= 10) {
                          return Text(
                            '${hour == 0 ? 12 : hour} AM',
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                lineTouchData: LineTouchData(enabled: true),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  _buildLineBar(
                    dummyData1(),
                    parameterColors[0],
                    parameterNames[0],
                  ),
                  _buildLineBar(
                    dummyData2(),
                    parameterColors[1],
                    parameterNames[1],
                  ),
                  _buildLineBar(
                    dummyData3(),
                    parameterColors[2],
                    parameterNames[2],
                  ),
                  _buildLineBar(
                    dummyData4(),
                    parameterColors[3],
                    parameterNames[3],
                  ),
                  _buildLineBar(
                    dummyData5(),
                    parameterColors[4],
                    parameterNames[4],
                  ),
                  _buildLineBar(
                    dummyData6(),
                    parameterColors[5],
                    parameterNames[5],
                  ),
                  _buildLineBar(
                    dummyData7(),
                    parameterColors[6],
                    parameterNames[6],
                  ),
                  _buildLineBar(
                    dummyData8(),
                    parameterColors[7],
                    parameterNames[7],
                  ),
                  _buildLineBar(
                    dummyData9(),
                    parameterColors[8],
                    parameterNames[8],
                  ),
                  _buildLineBar(
                    dummyData10(),
                    parameterColors[9],
                    parameterNames[9],
                  ),
                ],
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // multi selection parameters Dialouge box ............
  void _showMultiSelectDialog() {
    selectedParameters = List.from(selectedParameters); // lsit of parameter
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Parameters"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return SingleChildScrollView(
                child: Column(
                  children: parameters.map((param) {
                    return CheckboxListTile(
                      checkColor: Colors.white,
                      activeColor: AppColors.darkblue,
                      title: Text(param),
                      value: selectedParameters.contains(param),
                      onChanged: (bool? value) {
                        dialogSetState(() {
                          if (value == true) {
                            selectedParameters.add(param); // add para
                          } else {
                            selectedParameters.remove(param); // remove para
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  selectedParameters = List.from(selectedParameters);
                });
                Navigator.of(context).pop();
              },
              child: Text(
                "Save",
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

LineChartBarData _buildLineBar(List<FlSpot> data, Color color, String name) {
  return LineChartBarData(
    spots: data,
    isCurved: true,
    color: color,
    barWidth: 2,
    dotData: FlDotData(show: false),
  );
}

List<FlSpot> dummyData1() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 80 + (i % 2) * 5));
List<FlSpot> dummyData2() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 70 + (i % 3) * 3));
List<FlSpot> dummyData3() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 60 + (i % 4) * 4));
List<FlSpot> dummyData4() => List.generate(11, (i) => FlSpot(i.toDouble(), 90));
List<FlSpot> dummyData5() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 20 + (i % 5) * 8));
List<FlSpot> dummyData6() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 40 + (i % 3) * 5));
List<FlSpot> dummyData7() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 65 + (i % 2) * 2));
List<FlSpot> dummyData8() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 60 + (i % 3) * 3));
List<FlSpot> dummyData9() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 55 + (i % 4) * 2));
List<FlSpot> dummyData10() =>
    List.generate(11, (i) => FlSpot(i.toDouble(), 45 + (i % 2) * 6));
