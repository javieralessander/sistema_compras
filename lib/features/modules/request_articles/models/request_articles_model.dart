import 'dart:convert';
import 'package:sistema_compras/features/modules/employee/models/employee_model.dart';
import '../../../../core/constants/app_constants.dart';

import '../../article/models/article_model.dart';
import '../../unit/models/unit_model.dart';
import '../../department/models/department_model.dart';

class RequestArticles {
  // Constantes para estados de solicitud (usar constantes centralizadas)
  static const String estadoPendiente = AppConstants.estadoPendiente;
  static const String estadoAprobada = AppConstants.estadoAprobada;
  static const String estadoRechazada = AppConstants.estadoRechazada;
  
  // Mantener constantes legacy para compatibilidad (deprecar gradualmente)
  @Deprecated('Use estadoPendiente instead')
  static const String ESTADO_PENDIENTE = AppConstants.estadoPendiente;
  @Deprecated('Use estadoAprobada instead')
  static const String ESTADO_APROBADA = AppConstants.estadoAprobada;
  @Deprecated('Use estadoRechazada instead')
  static const String ESTADO_RECHAZADA = AppConstants.estadoRechazada;

  final int id;
  final Employee empleadoSolicitante;
  final DateTime fechaSolicitud;
  final String estado;
  final bool isActive;
  final List<RequestArticleItem> items;

  RequestArticles({
    required this.id,
    required this.empleadoSolicitante,
    required this.fechaSolicitud,
    required this.items,
    required this.estado,
    this.isActive = true,
  });

  /// Constructor para crear nueva solicitud con fecha automática
  RequestArticles.nueva({
    required this.empleadoSolicitante,
    required this.items,
    this.id = 0,
    this.isActive = true,
  }) : fechaSolicitud = DateTime.now(),
       estado = ESTADO_PENDIENTE; // Siempre pendiente para nuevas solicitudes

  factory RequestArticles.fromJson(Map<String, dynamic> json) {
    return RequestArticles(
      id: int.parse(json['id'].toString()),
      empleadoSolicitante: json['empleadoSolicitante'] != null 
          ? Employee.fromJson(json['empleadoSolicitante'])
          : Employee(
              id: json['empleadoId'] ?? 1,
              cedula: '00000000',
              nombre: 'Usuario Desconocido',
              departamento: Department(
                id: 1,
                nombre: 'Sin Departamento',
                isActive: true,
              ),
              isActive: true,
            ),
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      items: json['items'] != null
          ? (json['items'] as List)
              .map(
                (e) => RequestArticleItem.fromJson(e as Map<String, dynamic>),
              )
              .toList()
          : <RequestArticleItem>[], // Lista vacía si no hay items
      estado: json['estado'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() => {
    'empleadoId': empleadoSolicitante.id,
    'fechaSolicitud': fechaSolicitud.toIso8601String(),
    'estado': estado,
    'isActive': isActive,
    // No incluir items aquí porque se envían por separado al backend para CREATE
  };

  /// JSON para operaciones de UPDATE que pueden requerir más campos
  Map<String, dynamic> toJsonForUpdate() => {
    'empleadoId': empleadoSolicitante.id,
    'fechaSolicitud': fechaSolicitud.toIso8601String(),
    'estado': estado,
    'isActive': isActive,
    // Para update, incluir items si es necesario
    // 'items': items.map((e) => e.toJson()).toList(),
  };

  /// Crea una nueva solicitud con fecha automática (fecha actual)
  /// SIEMPRE se crea con estado 'pendiente'
  static RequestArticles crearNueva({
    required Employee empleadoSolicitante,
    required List<RequestArticleItem> items,
  }) {
    return RequestArticles(
      id: 0,
      empleadoSolicitante: empleadoSolicitante,
      fechaSolicitud: DateTime.now(),
      items: items,
      estado: ESTADO_PENDIENTE, // SIEMPRE pendiente para nuevas solicitudes
      isActive: true,
    );
  }

  RequestArticles copyWith({
    int? id,
    Employee? empleadoSolicitante,
    DateTime? fechaSolicitud,
    String? estado,
    bool? isActive,
    List<RequestArticleItem>? items,
  }) {
    return RequestArticles(
      id: id ?? this.id,
      empleadoSolicitante: empleadoSolicitante ?? this.empleadoSolicitante,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      estado: estado ?? this.estado,
      isActive: isActive ?? this.isActive,
      items: items ?? this.items,
    );
  }

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
