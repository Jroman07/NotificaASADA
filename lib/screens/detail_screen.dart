import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/solicitud_provider.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.solicitudId});

  final String solicitudId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const _bannerText =
      'Esta aplicación es de solo consulta. La gestión se realiza en el sistema web.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SolicitudProvider>().cargarDetalle(widget.solicitudId);
    });
  }

  String _formatFecha(DateTime d) {
    if (d.millisecondsSinceEpoch == 0) return '—';
    final local = d.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} ${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width;
    final provider = context.watch<SolicitudProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de solicitud'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW.clamp(0, 560)),
          child: _buildContent(context, provider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SolicitudProvider provider) {
    if (provider.isLoadingDetalle && provider.detalle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.hasDetalleError && provider.detalle == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            provider.errorDetalle ?? 'Error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => provider.cargarDetalle(widget.solicitudId),
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    final d = provider.detalle;
    if (d == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .primaryContainer
              .withAlpha((255 * 0.4).round()),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _bannerText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DetailRow(label: 'ID', value: d.id.isEmpty ? '—' : d.id),
                _DetailRow(label: 'Nombre', value: d.nombre.isEmpty ? '—' : d.nombre),
                _DetailRow(label: 'Fecha', value: _formatFecha(d.fecha)),
                _DetailRow(
                  label: 'Teléfono',
                  value: d.telefono.isEmpty ? '—' : d.telefono,
                ),
                _DetailRow(
                  label: 'Correo',
                  value: d.correo.isEmpty ? '—' : d.correo,
                ),
                const SizedBox(height: 8),
                Text(
                  'Motivo del voluntariado',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  d.motivo.isEmpty ? '—' : d.motivo,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
