import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/api_config.dart';
import '../models/solicitud_model.dart';
import '../providers/solicitud_provider.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudProvider>().cargarSolicitudes();
    });
  }

  String _formatFecha(DateTime d) {
    if (d.millisecondsSinceEpoch == 0) return '—';
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudProvider>();
    final maxWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NotificaASADA',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Text(
              'Solicitudes de voluntariado (consulta)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth.clamp(0, 600)),
          child: _buildBody(context, provider),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SolicitudProvider provider) {
    final demo = ApiConfig.useDemoData;

    if (provider.isLoading && provider.solicitudes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (demo) const _DemoModeBanner(),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    if (provider.hasListError && provider.solicitudes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          if (demo) const _DemoModeBanner(),
          Icon(Icons.cloud_off, size: 56, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => provider.cargarSolicitudes(),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (demo)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _DemoModeBanner(),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.cargarSolicitudes(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.solicitudes.length,
              itemBuilder: (context, index) {
                final Solicitud s = provider.solicitudes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        s.nombre.isEmpty ? 'Sin nombre' : s.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(_formatFecha(s.fecha)),
                          ],
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      onTap: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (_) => DetailScreen(solicitudId: s.id),
                          ),
                        );
                        if (context.mounted) {
                          context.read<SolicitudProvider>().limpiarDetalle();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoModeBanner extends StatelessWidget {
  const _DemoModeBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(140),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 22,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Modo demostración: ves el modelo de datos de ejemplo. '
                'Para el API NestJS usa --dart-define=USE_DEMO_DATA=false',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
