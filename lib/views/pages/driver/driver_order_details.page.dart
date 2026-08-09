import 'dart:io';

import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_taxi_settings.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/traits/qrcode_scanner.trait.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/views/pages/driver/driver_signature.page.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DriverOrderDetailsPage extends StatefulWidget {
  const DriverOrderDetailsPage({required this.order, super.key});

  final Order order;

  @override
  State<DriverOrderDetailsPage> createState() =>
      _DriverOrderDetailsPageState();
}

class _DriverOrderDetailsPageState extends State<DriverOrderDetailsPage>
    with QrcodeScannerTrait {
  final OrderRequest _request = OrderRequest();
  final ImagePicker _imagePicker = ImagePicker();
  late Order _order = widget.order;
  bool _loading = false;

  bool get _isTaxi => _order.taxiOrder != null ||
      _order.type.toLowerCase().contains('taxi');

  bool get _isFinished => const {
    'delivered',
    'completed',
    'cancelled',
    'failed',
  }.contains(_order.status.toLowerCase());

  Future<void> _refresh() async {
    final order = await _request.getOrderDetails(id: _order.id);
    if (mounted) setState(() => _order = order);
  }

  Future<void> _changeStatus(String status) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final order = await _request.updateDriverOrder(
        id: _order.id,
        status: status,
      );
      if (mounted) setState(() => _order = order);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startDeliveryVerification() async {
    final verified = await _verificationDialog();
    if (verified != true || !mounted) return;

    final proof = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const ListTile(
              title: Text('Evidencia de entrega'),
              subtitle: Text('Selecciona la evidencia antes de completar.'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Tomar fotografía'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.draw_outlined),
              title: const Text('Firma del receptor'),
              onTap: () => Navigator.pop(context, 'signature'),
            ),
          ],
        ),
      ),
    );
    if (proof == null) return;
    if (proof == 'signature') {
      final file = await Navigator.of(context).push<File>(
        MaterialPageRoute(builder: (_) => const DriverSignaturePage()),
      );
      if (file != null) await _submitProof(file, proofType: 'signature');
      return;
    }
    final source = proof == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1800,
    );
    if (picked == null) return;
    await _submitProof(File(picked.path), proofType: 'delivery_photo');
  }

  Future<void> _advanceTaxi() async {
    final current = _order.status.toLowerCase();
    final next = switch (current) {
      'pending' || 'preparing' => 'ready',
      'ready' => 'enroute',
      'enroute' => 'delivered',
      _ => 'ready',
    };
    final requiresCode = AppTaxiSettings.requiredBookingCode &&
        ((next == 'enroute' &&
                AppTaxiSettings.requiredBookingCodeBeforeTrip) ||
            (next == 'delivered' &&
                AppTaxiSettings.requiredBookingCodeAfterTrip));
    if (requiresCode) {
      final verified = await _verificationDialog(
        title: next == 'enroute' ? 'Verificar pasajero' : 'Finalizar viaje',
      );
      if (verified != true) return;
    }
    await _changeStatus(next);
    if (next == 'delivered' && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje completado correctamente')),
      );
    }
  }

  Future<bool?> _verificationDialog({String title = 'Verificar entrega'}) async {
    final controller = TextEditingController();
    String? error;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Código del cliente',
                  errorText: error,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final code = await openScanner(context);
                  if (code != null) controller.text = code;
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Escanear QR'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim() != _order.verificationCode.trim()) {
                  setDialogState(() => error = 'El código no coincide');
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitProof(
    File file, {
    required String proofType,
  }) async {
    setState(() => _loading = true);
    try {
      final order = await _request.submitDriverProof(
        id: _order.id,
        file: file,
        proofType: proofType,
      );
      if (!mounted) return;
      setState(() => _order = order);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido completado correctamente')),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$error'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pedido #${_order.code}')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            _StatusCard(order: _order),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Cliente',
              icon: Icons.person_outline,
              lines: [_order.user.name, _order.user.phone],
              onAction: _order.user.phone.isEmpty
                  ? null
                  : () => launchUrlString('tel:${_order.user.phone}'),
            ),
            const SizedBox(height: 12),
            if (_order.deliveryAddress != null)
              _InfoCard(
                title: 'Dirección de entrega',
                icon: Icons.location_on_outlined,
                lines: [
                  _order.deliveryAddress?.address ??
                      _order.deliveryAddress?.name ??
                      '',
                ],
              ),
            if (_isTaxi && _order.taxiOrder != null) ...[
              _InfoCard(
                title: 'Punto de recogida',
                icon: Icons.my_location_outlined,
                lines: [_order.taxiOrder!.pickupAddress],
                actionIcon: Icons.navigation_outlined,
                onAction: () => _openLocation(
                  _order.taxiOrder!.pickupLatitude,
                  _order.taxiOrder!.pickupLongitude,
                ),
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Destino',
                icon: Icons.flag_outlined,
                lines: [_order.taxiOrder!.dropoffAddress],
                actionIcon: Icons.navigation_outlined,
                onAction: () => _openLocation(
                  _order.taxiOrder!.dropoffLatitude,
                  _order.taxiOrder!.dropoffLongitude,
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Resumen',
              icon: Icons.receipt_long_outlined,
              lines: [
                'Estado de pago: ${_order.paymentStatus}',
                'Total: ${_order.total ?? 0}',
                if (_order.note.isNotEmpty) 'Nota: ${_order.note}',
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isFinished
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: _loading
                  ? const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                    )
                  : _DriverOrderActions(
                      status: _order.status,
                      isTaxi: _isTaxi,
                      onEnroute: () => _changeStatus('enroute'),
                      onComplete: _startDeliveryVerification,
                      onTaxiAdvance: _advanceTaxi,
                    ),
            ),
    );
  }

  Future<void> _openLocation(String latitude, String longitude) async {
    final uri = 'https://www.google.com/maps/dir/?api=1&destination='
        '$latitude,$longitude';
    if (!await launchUrlString(uri, mode: LaunchMode.externalApplication)) {
      _showError('No se pudo abrir la navegación');
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColor.primaryColor.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_shipping_outlined),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                order.status,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.lines,
    this.onAction,
    this.actionIcon = Icons.call_outlined,
  });
  final String title;
  final IconData icon;
  final List<String> lines;
  final VoidCallback? onAction;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(lines.where((line) => line.isNotEmpty).join('\n')),
      trailing: onAction == null ? null : IconButton(
        onPressed: onAction,
        icon: Icon(actionIcon),
      ),
    ),
  );
}

class _DriverOrderActions extends StatelessWidget {
  const _DriverOrderActions({
    required this.status,
    required this.isTaxi,
    required this.onEnroute,
    required this.onComplete,
    required this.onTaxiAdvance,
  });
  final String status;
  final bool isTaxi;
  final VoidCallback onEnroute;
  final VoidCallback onComplete;
  final VoidCallback onTaxiAdvance;

  @override
  Widget build(BuildContext context) {
    if (isTaxi) {
      final action = switch (status.toLowerCase()) {
        'pending' || 'preparing' => ('Llegué al punto de recogida', Icons.location_on_outlined),
        'ready' => ('Iniciar viaje', Icons.navigation_outlined),
        'enroute' => ('Finalizar viaje', Icons.flag_outlined),
        _ => ('Actualizar viaje', Icons.sync_outlined),
      };
      return FilledButton.icon(
        onPressed: onTaxiAdvance,
        icon: Icon(action.$2),
        label: Text(action.$1),
      );
    }
    final enroute = status.toLowerCase() == 'enroute';
    return FilledButton.icon(
      onPressed: enroute ? onComplete : onEnroute,
      icon: Icon(enroute ? Icons.verified_outlined : Icons.navigation_outlined),
      label: Text(enroute ? 'Completar entrega' : 'Iniciar entrega'),
    );
  }
}
