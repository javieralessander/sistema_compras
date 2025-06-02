import 'dart:convert';
import '../../brand/models/brand_model.dart';
import '../../unit/models/unit_model.dart';

class Article {
  final int id;
  final String descripcion;
  final Brand marca;
  final Unit unidadMedida;
  final int existencia;
  final String estado;

  Article({
    required this.id,
    required this.descripcion,
    required this.marca,
    required this.unidadMedida,
    required this.existencia,
    required this.estado,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: int.parse(json['id'].toString()),
      descripcion: json['descripcion'],
      marca: Brand.fromJson(json['marca']),
      unidadMedida: Unit.fromJson(json['unidadMedida']),
      existencia: json['existencia'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'marca': marca.toJson(),
      'unidadMedida': unidadMedida.toJson(),
      'existencia': existencia,
      'estado': estado,
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
