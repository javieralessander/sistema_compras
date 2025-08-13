import 'dart:convert';
import '../../brand/models/brand_model.dart';
import '../../unit/models/unit_model.dart';

class Article {
  final int id;
  final String descripcion;
  final Brand marca;
  final Unit unidadMedida;
  final int existencia;
  final bool isActive;

  Article({
    required this.id,
    required this.descripcion,
    required this.marca,
    required this.unidadMedida,
    required this.existencia,
    this.isActive = true,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      marca: Brand.fromJson(json['marca']),
      unidadMedida: Unit.fromJson(json['unidadMedida']),
      existencia: json['existencia'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'descripcion': descripcion,
      'marcaId': marca.id,
      'unidadMedidaId': unidadMedida.id,
      'existencia': existencia,
      'isActive': isActive,
    };
  }

  // Métodos para trabajar con JSON crudo
  factory Article.fromRawJson(String str) => Article.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
