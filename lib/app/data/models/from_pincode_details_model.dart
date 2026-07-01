class FromPincodeDetailsModel {
  final String fromCity;
  final String orgncd;
  final String orgNstnm;
  final String orgnArea;

  FromPincodeDetailsModel({required this.fromCity, required this.orgncd, required this.orgNstnm, required this.orgnArea});

  factory FromPincodeDetailsModel.fromJson(Map<String, dynamic> json) {
    return FromPincodeDetailsModel(fromCity: json['fromCity'] ?? '', orgncd: json['orgncd'] ?? '', orgNstnm: json['orgNstnm'] ?? '', orgnArea: json['orgnArea'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'fromCity': fromCity, 'orgncd': orgncd, 'orgNstnm': orgNstnm, 'orgnArea': orgnArea};
  }
}
