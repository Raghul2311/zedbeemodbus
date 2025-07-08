import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zedbeemodbus/services_class/provider_services.dart';

class ParametersList extends StatefulWidget {
  const ParametersList({super.key});

  @override
  State<ParametersList> createState() => _ParametersListState();
}

class _ParametersListState extends State<ParametersList> {
  final List<String> parameters = [
    'Flow meter',
    'Water Temperature',
    'BTU',
    'Power',
    'Voltage',
  ];
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderServices>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Parameter')),
      body: ListView.builder(
        itemCount: parameters.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(parameters[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              provider.addParameter(parameters[index]);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
