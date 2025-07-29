class ParameterModel {
  final String text;
  final double dx;
  final double dy;
  final int? registerIndex;
  String value;

  ParameterModel({
    required this.text,
    required this.dx,
    required this.dy,
    this.registerIndex,
    this.value = "",
  });
  
  Map<String, dynamic> toJson() => {
    'text': text,
    'dx': dx,
    'dy': dy,
    'registerIndex': registerIndex,
    'value': value,
  };

  factory ParameterModel.fromJson(Map<String, dynamic> json) {
    return ParameterModel(
      text: json['text'],
      dx: json['dx'],
      dy: json['dy'],
      registerIndex: json['registerIndex'],
      value: json['value'] ?? "",
    );
  }
}
