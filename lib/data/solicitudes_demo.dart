import '../models/solicitud_model.dart';

/// Solicitudes de ejemplo para previsualizar la UI sin API NestJS.
/// Desactiva con: `flutter run --dart-define=USE_DEMO_DATA=false`
final List<Solicitud> solicitudesDemo = [
  Solicitud(
    id: 'demo-1',
    nombre: 'María Fernández López',
    fecha: DateTime.utc(2026, 5, 8, 14, 30),
    telefono: '+506 8888-1111',
    correo: 'maria.fernandez@ejemplo.com',
    motivo:
        'Quiero apoyar en jornadas de reforestación y educación ambiental los fines de semana.',
  ),
  Solicitud(
    id: 'demo-2',
    nombre: 'José Miguel Rojas',
    fecha: DateTime.utc(2026, 5, 7, 9, 15),
    telefono: '+506 7777-2222',
    correo: 'jrojas.voluntario@ejemplo.com',
    motivo:
        'Tengo experiencia en logística y puedo colaborar en la organización de eventos comunitarios.',
  ),
  Solicitud(
    id: 'demo-3',
    nombre: 'Ana Lucía Vargas',
    fecha: DateTime.utc(2026, 5, 5, 16, 45),
    telefono: '+506 6666-3333',
    correo: 'ana.vargas@ejemplo.com',
    motivo:
        'Me interesa el módulo de atención a familias y acompañamiento en visitas de campo.',
  ),
];
