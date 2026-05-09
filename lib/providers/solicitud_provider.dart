import 'package:flutter/foundation.dart';

import '../models/solicitud_model.dart';
import '../services/api_service.dart';

/// Estado de la lista y del detalle (carga, éxito, error) vía [ChangeNotifier].
class SolicitudProvider extends ChangeNotifier {
  SolicitudProvider({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  List<Solicitud> _solicitudes = [];
  List<Solicitud> get solicitudes => List.unmodifiable(_solicitudes);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get errorMessage => _error;

  Solicitud? _detalle;
  Solicitud? get detalle => _detalle;

  bool _isLoadingDetalle = false;
  bool get isLoadingDetalle => _isLoadingDetalle;

  String? _errorDetalle;
  String? get errorDetalle => _errorDetalle;

  bool get hasListError => _error != null && !_isLoading;
  bool get hasDetalleError => _errorDetalle != null && !_isLoadingDetalle;

  Future<void> cargarSolicitudes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitudes = await _api.fetchSolicitudes();
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      _solicitudes = [];
    } catch (e) {
      _error = 'Error de red o formato inesperado: $e';
      _solicitudes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDetalle(String id) async {
    _isLoadingDetalle = true;
    _errorDetalle = null;
    _detalle = null;
    notifyListeners();

    try {
      _detalle = await _api.fetchSolicitudPorId(id);
      _errorDetalle = null;
    } on ApiException catch (e) {
      _errorDetalle = e.message;
      _detalle = null;
    } catch (e) {
      _errorDetalle = 'Error de red o formato inesperado: $e';
      _detalle = null;
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  void limpiarDetalle() {
    _detalle = null;
    _errorDetalle = null;
    notifyListeners();
  }
}
