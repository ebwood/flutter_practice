import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonEnum(valueField: 'index')
enum Role { manager, developer, ui, pm }

@JsonSerializable()
class Model {
  final String name;
  final int age;
  final Role role;
  const Model(
      {this.name = "wood", required this.age, this.role = Role.developer});

  factory Model.fromJson(Map<String, dynamic> map) => _$ModelFromJson(map);
  Map<String, dynamic> toJson() => _$ModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
