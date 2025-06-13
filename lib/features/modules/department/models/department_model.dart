import 'dart:convert';
import 'package:flutter/cupertino.dart';

class Department {
  final int id;
  final String nombre;
  final bool isActive;

  Department({required this.id, required this.nombre, this.isActive = true});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: int.parse(json['id'].toString()),
      nombre: json['nombre'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'isActive': isActive};
  }

  // Métodos para trabajar con JSON crudo
  factory Department.fromRawJson(String str) =>
      Department.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  String toString() {
    return 'Departamento($id - $nombre)';
  }

  Department copyWith({int? id, String? nombre, bool? isActive}) {
    return Department(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Enum for department icons, each with an associated CupertinoIconData
enum DepartmentIcon {
  defaultIcon(CupertinoIcons.building_2_fill),
  employeeIcon(CupertinoIcons.person_fill),
  financeIcon(CupertinoIcons.money_dollar_circle_fill),
  hrIcon(CupertinoIcons.person_2_fill),
  marketingIcon(CupertinoIcons.phone),
  salesIcon(CupertinoIcons.cart_fill),
  itIcon(CupertinoIcons.desktopcomputer),
  logisticsIcon(CupertinoIcons.car_fill),
  supportIcon(CupertinoIcons.phone_fill),
  researchIcon(CupertinoIcons.lab_flask),
  legalIcon(CupertinoIcons.book),
  adminIcon(CupertinoIcons.person_3_fill),
  operationsIcon(CupertinoIcons.gear_alt_fill),
  customerServiceIcon(CupertinoIcons.chat_bubble_2_fill),
  qualityAssuranceIcon(CupertinoIcons.checkmark_shield_fill),
  trainingIcon(CupertinoIcons.book_fill);

  final IconData iconData;
  // Mark the constructor as const to allow constant expressions
  const DepartmentIcon(this.iconData);
}
