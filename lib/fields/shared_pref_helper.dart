import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zedbeemodbus/model_folder/parameters_model.dart';

class SharedPrefHelper {
  static const _paramKey = "draggable_parameters";
  static const _checkedIndexesKey = "checked_parameter_indexes";

  // To save the parameters
  static Future<void> saveParameters(List<ParameterModel> params) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(params.map((p) => p.toJson()).toList());
    prefs.setString(_paramKey, jsonString);
  }

  // To get the parameters
  static Future<List<ParameterModel>> getParameters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_paramKey);
    if (jsonString == null) return [];
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => ParameterModel.fromJson(e)).toList();
  }

  // To remove the parameter
  static Future<void> clearParameters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_paramKey);
  }

  // save selected chekbox indexes
  static Future<void> saveCheckedIndexes(List<int> indexes) async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = indexes.map((e) => e.toString()).toList();
    await prefs.setStringList(_checkedIndexesKey, stringList);
  }

  // Load selected checkbox indexes
  static Future<List<int>> getCheckedIndexes() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(_checkedIndexesKey);
    if (stringList == null) return [];
    return stringList.map(int.parse).toList();
  }
}
