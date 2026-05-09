import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notifica_asada/main.dart';
import 'package:notifica_asada/providers/solicitud_provider.dart';
import 'package:notifica_asada/services/api_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Muestra listado vacío cuando el API devuelve []', (tester) async {
    final mock = MockClient((request) async {
      expect(request.url.path, endsWith('/solicitudes'));
      return http.Response('[]', 200);
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SolicitudProvider(
              apiService: ApiService(
                httpClient: mock,
                baseUrl: 'http://test',
                useDemoData: false,
              ),
            ),
          ),
        ],
        child: const VoluntariadoApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('NotificaASADA'), findsOneWidget);
  });
}
