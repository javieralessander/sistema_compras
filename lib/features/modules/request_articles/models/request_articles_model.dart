import 'dart:convert';
import 'package:sistema_compras/features/modules/employee/models/employee_model.dart';

import '../../article/models/article_model.dart';
import '../../unit/models/unit_model.dart';

class RequestArticles {
  final int id;
  final Employee? empleadoSolicitante;
  final DateTime fechaSolicitud;
  final List<RequestArticleItem> items;
  final String estado;
  final bool isActive;

  RequestArticles({
    required this.id,
    this.empleadoSolicitante,
    required this.fechaSolicitud,
    required this.items,
    required this.estado,
    this.isActive = true,
  });

  factory RequestArticles.fromJson(Map<String, dynamic> json) {
    return RequestArticles(
      id: int.parse(json['id'].toString()),
      empleadoSolicitante: Employee.fromJson(json['empleadoSolicitante']),
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      items:
          (json['items'] as List)
              .map(
                (e) => RequestArticleItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      estado: json['estado'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() => {
    //  ToDo: Replace with actual employee ID when available
    // 'empleadoId': empleadoSolicitante.id,
    'empleadoId': 1,
    'fechaSolicitud': fechaSolicitud.toIso8601String(),
    // 'items': items.map((e) => e.toJson()).toList(),
    'estado': estado,
    'isActive': isActive,
  };

  factory RequestArticles.fromRawJson(String str) =>
      RequestArticles.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

class RequestArticleItem {
  final Article articulo;
  final int cantidad;
  final Unit unidadMedida;

  RequestArticleItem({
    required this.articulo,
    required this.cantidad,
    required this.unidadMedida,
  });

  factory RequestArticleItem.fromJson(Map<String, dynamic> json) {
    return RequestArticleItem(
      articulo: Article.fromJson(json['articulo']),
      cantidad: int.parse(json['cantidad'].toString()),
      unidadMedida: Unit.fromJson(json['unidadMedida']),
    );
  }

  Map<String, dynamic> toJson() => {
    'articulo': articulo.toJson(),
    'cantidad': cantidad,
    'unidadMedida': unidadMedida.toJson(),
  };
  RequestArticleItem copyWith({
    Article? articulo,
    int? cantidad,
    Unit? unidadMedida,
  }) {
    return RequestArticleItem(
      articulo: articulo ?? this.articulo,
      cantidad: cantidad ?? this.cantidad,
      unidadMedida: unidadMedida ?? this.unidadMedida,
    );
  }

  factory RequestArticleItem.fromRawJson(String str) =>
      RequestArticleItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}
