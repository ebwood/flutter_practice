// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Model _$ModelFromJson(Map<String, dynamic> json) => Model(
      name: json['name'] as String? ?? "wood",
      age: (json['age'] as num).toInt(),
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']) ?? Role.developer,
    );

Map<String, dynamic> _$ModelToJson(Model instance) => <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'role': _$RoleEnumMap[instance.role]!,
    };

const _$RoleEnumMap = {
  Role.manager: 0,
  Role.developer: 1,
  Role.ui: 2,
  Role.pm: 3,
};
