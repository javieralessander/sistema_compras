class Supplier {
  final int id;
  final String cedulaRnc;
  final String nombreComercial;
  final String estado;

  Supplier({
    required this.id,
    required this.cedulaRnc,
    required this.nombreComercial,
    required this.estado,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      cedulaRnc: json['cedulaRnc'],
      nombreComercial: json['nombreComercial'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cedulaRnc': cedulaRnc,
      'nombreComercial': nombreComercial,
      'estado': estado,
    };
  }
}