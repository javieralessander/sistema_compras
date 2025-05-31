import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/supplier_model.dart';

class SupplierService {
  static const String baseUrl = 'https://tuapi.com/api/proveedores';

  static final List<Supplier> _pruebasData = [
    Supplier(id: 1, cedulaRnc: '101112223', nombreComercial: 'Distribuidora ABC', estado: 'Activo'),
    Supplier(id: 2, cedulaRnc: '201334455', nombreComercial: 'Importadora XYZ', estado: 'Activo'),
    Supplier(id: 3, cedulaRnc: '301556677', nombreComercial: 'Servicios Globales', estado: 'Inactivo'),
    Supplier(id: 4, cedulaRnc: '401778899', nombreComercial: 'Comercializadora Delta', estado: 'Activo'),
    Supplier(id: 5, cedulaRnc: '501990011', nombreComercial: 'Proveedora Omega', estado: 'Activo'),
  ];

  // Método para obtener proveedores desde API real
  static Future<List<Supplier>> getAllFromApi() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Supplier.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener proveedores');
    }
  }

  // Método para obtener proveedores de prueba
  static Future<List<Supplier>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _pruebasData;
  }

  static Future<Supplier> create(Supplier proveedor) async {
    // Simulación en memoria
    final nuevo = Supplier(
      id: _pruebasData.isEmpty ? 1 : _pruebasData.last.id + 1,
      cedulaRnc: proveedor.cedulaRnc,
      nombreComercial: proveedor.nombreComercial,
      estado: proveedor.estado,
    );
    _pruebasData.add(nuevo);
    return nuevo;

    // Para API real:
    /*
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(proveedor.toJson()),
    );
    if (response.statusCode == 201) {
      return Supplier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear proveedor');
    }
    */
  }

  static Future<void> delete(int id) async {
    // Simulación en memoria
    _pruebasData.removeWhere((p) => p.id == id);

    // Para API real:
    /*
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar proveedor');
    }
    */
  }

  static Future<Supplier> update(Supplier proveedor) async {
    // Simulación en memoria
    final index = _pruebasData.indexWhere((p) => p.id == proveedor.id);
    if (index != -1) {
      _pruebasData[index] = proveedor;
      return proveedor;
    } else {
      throw Exception('Proveedor no encontrado');
    }

    // Para API real:
    /*
    final response = await http.put(
      Uri.parse('$baseUrl/${proveedor.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(proveedor.toJson()),
    );
    if (response.statusCode == 200) {
      return Supplier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar proveedor');
    }
    */
  }
}