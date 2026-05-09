/// Solicitud de voluntariado (mapeo JSON del backend NestJS).
class Solicitud {
  const Solicitud({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.telefono,
    required this.correo,
    required this.motivo,
  });

  final String id;
  final String nombre;
  final DateTime fecha;
  final String telefono;
  final String correo;
  final String motivo;

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: _readId(json['id']),
      nombre: _readString(json['nombre']),
      fecha: _readFecha(json['fecha']),
      telefono: _readString(json['telefono'] ?? json['teléfono']),
      correo: _readString(json['correo'] ?? json['email']),
      motivo: _readString(json['motivo']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'fecha': fecha.toIso8601String(),
        'telefono': telefono,
        'correo': correo,
        'motivo': motivo,
      };

  static String _readId(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static DateTime _readFecha(dynamic value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
