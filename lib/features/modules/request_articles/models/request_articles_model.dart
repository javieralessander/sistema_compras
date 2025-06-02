import 'dart:convert';
import '../../article/models/article_model.dart';
import '../../unit/models/unit_model.dart';

class RequestArticles {
  final int id;
  final String empleadoSolicitante;
  final DateTime fechaSolicitud;
  final List<RequestArticleItem> items;
  final String estado;

  RequestArticles({
    required this.id,
    required this.empleadoSolicitante,
    required this.fechaSolicitud,
    required this.items,
    required this.estado,
  });

  factory RequestArticles.fromJson(Map<String, dynamic> json) {
    return RequestArticles(
      id: int.parse(json['id'].toString()),
      empleadoSolicitante: json['empleadoSolicitante'],
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      items:
          (json['items'] as List)
              .map(
                (e) => RequestArticleItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'empleadoSolicitante': empleadoSolicitante,
    'fechaSolicitud': fechaSolicitud.toIso8601String(),
    'items': items.map((e) => e.toJson()).toList(),
    'estado': estado,
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
