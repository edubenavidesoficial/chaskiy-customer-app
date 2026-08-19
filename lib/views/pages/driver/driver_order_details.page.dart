import 'dart:io';

import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_taxi_settings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/traits/qrcode_scanner.trait.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/views/pages/driver/driver_signature.page.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DriverOrderDetailsPage extends StatefulWidget {
  const DriverOrderDetailsPage({required this.order, super.key});

  final Order order;

  @override
  State<DriverOrderDetailsPage> createState() => _DriverOrderDetailsPageState();
}

class _DriverOrderDetailsPageState extends State<DriverOrderDetailsPage>
    with QrcodeScannerTrait {
  final OrderRequest _request = OrderRequest();
  final ImagePicker _imagePicker = ImagePicker();
  late Order _order = widget.order;
  bool _loading = false;

  bool get _isTaxi =>
      _order.taxiOrder != null || _order.type.toLowerCase().contains('taxi');

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
    final stops = _order.orderStops ?? [];
    if (stops.length > 1 && stops.any((stop) => !stop.verified)) {
      _showError('Confirma cada parada antes de completar la ruta.');
      return;
    }
    final verified = await _verificationDialog();
    if (verified != true || !mounted) return;

    final proof = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => SafeArea(
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

  Future<void> _verifyStop(int stopId) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar entrega'),
            content: const Text(
              'Confirma que entregaste los productos indicados en esta dirección.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
    if (accepted != true) return;
    setState(() => _loading = true);
    try {
      final order = await _request.verifyDeliveryStop(stopId: stopId);
      if (mounted) setState(() => _order = order);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _advanceTaxi() async {
    final current = _order.status.toLowerCase();
    final next = switch (current) {
      'pending' || 'preparing' => 'ready',
      'ready' => 'enroute',
      'enroute' => 'delivered',
      _ => 'ready',
    };
    final requiresCode =
        AppTaxiSettings.requiredBookingCode &&
        ((next == 'enroute' && AppTaxiSettings.requiredBookingCodeBeforeTrip) ||
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

  Future<bool?> _verificationDialog({
    String title = 'Verificar entrega',
  }) async {
    final controller = TextEditingController();
    String? error;
    return showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
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
                        if (controller.text.trim() !=
                            _order.verificationCode.trim()) {
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

  Future<void> _submitProof(File file, {required String proofType}) async {
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        //la barra deja de ser un bloque de color y se funde con la pantalla
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pedido #${_order.code}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          //el hueco de abajo es para que el botón de acción no tape la última
          //tarjeta
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children:
              [
                _StatusCard(order: _order, isTaxi: _isTaxi),
                _routeCard(),
                _customerCard(),
                if (!_isTaxi) _itemsCard(),
                _paymentCard(),
                if (_order.note.isNotEmpty)
                  _DriverCard(
                    title: 'Nota del cliente',
                    icon: Icons.sticky_note_2_outlined,
                    child: Text(_order.note, style: theme.textTheme.bodyMedium),
                  ),
              ].whereType<Widget>().map(_spaced).toList(),
        ),
      ),
      bottomNavigationBar:
          _isFinished
              ? null
              : Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(top: BorderSide(color: scheme.outlineVariant)),
                ),
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child:
                      _loading
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
              ),
    );
  }

  /// Mismo aire entre todas las tarjetas.
  Widget _spaced(Widget card) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: card);

  /// De dónde se recoge y a dónde se lleva, en el orden en que el conductor
  /// las va a necesitar.
  Widget? _routeCard() {
    final stops = <_Stop>[];

    if (_isTaxi && _order.taxiOrder != null) {
      final taxi = _order.taxiOrder!;
      stops.add(
        _Stop(
          label: 'Recoger al pasajero',
          address: taxi.pickupAddress,
          latitude: taxi.pickupLatitude,
          longitude: taxi.pickupLongitude,
        ),
      );
      stops.add(
        _Stop(
          label: 'Destino',
          address: taxi.dropoffAddress,
          latitude: taxi.dropoffLatitude,
          longitude: taxi.dropoffLongitude,
        ),
      );
    } else {
      final vendor = _order.vendor;
      if (vendor != null && vendor.address.isNotEmpty) {
        stops.add(
          _Stop(
            label: 'Recoger en ${vendor.name}',
            address: vendor.address,
            latitude: vendor.latitude,
            longitude: vendor.longitude,
          ),
        );
      }
      final deliveryStops = _order.orderStops ?? [];
      if (deliveryStops.isNotEmpty) {
        for (var index = 0; index < deliveryStops.length; index++) {
          final address = deliveryStops[index].deliveryAddress;
          if (address == null) continue;
          stops.add(
            _Stop(
              label: 'Entrega ${index + 1}',
              address: address.address ?? address.name ?? '',
              latitude: '${address.latitude ?? ''}',
              longitude: '${address.longitude ?? ''}',
              stopId: deliveryStops[index].id,
              verified: deliveryStops[index].verified,
              items:
                  deliveryStops[index].items.map((item) {
                    final lineIndex =
                        int.tryParse('${item['line_index']}') ?? -1;
                    final quantity = int.tryParse('${item['quantity']}') ?? 0;
                    final products = _order.orderProducts ?? [];
                    final name =
                        lineIndex >= 0 && lineIndex < products.length
                            ? products[lineIndex].product?.name ?? 'Producto'
                            : 'Producto';
                    return '$quantity× $name';
                  }).toList(),
            ),
          );
        }
      } else {
        final address = _order.deliveryAddress;
        if (address != null) {
          stops.add(
            _Stop(
              label: 'Entregar al cliente',
              address: address.address ?? address.name ?? '',
              latitude: '${address.latitude ?? ''}',
              longitude: '${address.longitude ?? ''}',
            ),
          );
        }
      }
    }

    if (stops.isEmpty) return null;
    return _DriverCard(
      title: 'Ruta',
      icon: Icons.route_outlined,
      child: Column(
        children: [
          for (var index = 0; index < stops.length; index++)
            _StopTile(
              stop: stops[index],
              isFirst: index == 0,
              isLast: index == stops.length - 1,
              onNavigate: () => _openStop(stops[index]),
              onVerify:
                  stops[index].stopId == null || stops[index].verified
                      ? null
                      : () => _verifyStop(stops[index].stopId!),
            ),
        ],
      ),
    );
  }

  Widget _customerCard() {
    final theme = Theme.of(context);
    final phone = _order.user.phone;

    return _DriverCard(
      title: _isTaxi ? 'Pasajero' : 'Cliente',
      icon: Icons.person_outline_rounded,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _order.user.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (phone.isNotEmpty)
                  Text(
                    phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (phone.isNotEmpty)
            _RoundIconButton(
              icon: Icons.call_rounded,
              tooltip: 'Llamar al cliente',
              onPressed: () => launchUrlString('tel:$phone'),
            ),
        ],
      ),
    );
  }

  /// Qué lleva el pedido. Sin esto el conductor no puede revisar que le
  /// entregaron todo.
  Widget? _itemsCard() {
    final products = _order.orderProducts ?? [];
    if (products.isEmpty) return null;

    final theme = Theme.of(context);
    return _DriverCard(
      title: 'Qué lleva',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: [
          for (final product in products)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${product.quantity}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.product?.name ?? 'Producto',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if ((product.options ?? '').isNotEmpty)
                          Text(
                            product.options!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currencySymbol = AppStrings.currencySymbol;
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return _DriverCard(
      title: 'Cobro',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('Estado del pago', style: mutedStyle)),
              OrderStatusChip(_order.paymentStatus),
            ],
          ),
          if (_order.paymentMethod != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Text('Método', style: mutedStyle)),
                Text(
                  '${_order.paymentMethod?.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          Divider(height: 24, color: scheme.outlineVariant),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                //el total salía como "2.12", sin moneda ni formato
                "$currencySymbol ${_order.total ?? 0}".currencyFormat(
                  currencySymbol,
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openStop(_Stop stop) =>
      _openLocation(stop.latitude, stop.longitude);

  Future<void> _openLocation(String latitude, String longitude) async {
    final uri =
        'https://www.google.com/maps/dir/?api=1&destination='
        '$latitude,$longitude';
    if (!await launchUrlString(uri, mode: LaunchMode.externalApplication)) {
      _showError('No se pudo abrir la navegación');
    }
  }
}

/// Una parada de la ruta.
class _Stop {
  const _Stop({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.stopId,
    this.verified = false,
    this.items = const [],
  });

  final String label;
  final String address;
  final String latitude;
  final String longitude;
  final int? stopId;
  final bool verified;
  final List<String> items;

  /// Sin coordenadas el botón de navegar no lleva a ninguna parte.
  bool get canNavigate {
    final lat = double.tryParse(latitude) ?? 0;
    final lng = double.tryParse(longitude) ?? 0;
    return lat != 0 && lng != 0;
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.onNavigate,
    this.onVerify,
  });

  final _Stop stop;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onNavigate;
  final VoidCallback? onVerify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    //el origen se marca hueco y el destino lleno, como en los mapas
    final color = isLast ? scheme.primary : scheme.onSurfaceVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: isLast ? color : scheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: scheme.outlineVariant),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stop.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (stop.items.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    for (final item in stop.items)
                      Text(
                        item,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                  if (stop.verified)
                    Text(
                      'Entregado',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (onVerify != null)
            TextButton.icon(
              onPressed: onVerify,
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Entregar'),
            ),
          if (stop.canNavigate)
            _RoundIconButton(
              icon: Icons.navigation_rounded,
              tooltip: 'Abrir en el mapa',
              onPressed: onNavigate,
            ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order, required this.isTaxi});

  final Order order;
  final bool isTaxi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isTaxi
                  ? Icons.local_taxi_outlined
                  : Icons.delivery_dining_outlined,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //el estado ya no se muestra crudo en inglés
                OrderStatusChip(order.status),
                const SizedBox(height: 6),
                Text(
                  Utils.orderDate(order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta con el mismo aspecto que las del detalle del pedido del cliente.
class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
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
    final (String label, IconData icon, VoidCallback action) = _action();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: action,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  (String, IconData, VoidCallback) _action() {
    if (isTaxi) {
      return switch (status.toLowerCase()) {
        'pending' || 'preparing' => (
          'Llegué al punto de recogida',
          Icons.location_on_outlined,
          onTaxiAdvance,
        ),
        'ready' => ('Iniciar viaje', Icons.navigation_outlined, onTaxiAdvance),
        'enroute' => ('Finalizar viaje', Icons.flag_outlined, onTaxiAdvance),
        _ => ('Actualizar viaje', Icons.sync_outlined, onTaxiAdvance),
      };
    }
    if (status.toLowerCase() == 'enroute') {
      return ('Completar entrega', Icons.verified_outlined, onComplete);
    }
    return ('Iniciar entrega', Icons.navigation_outlined, onEnroute);
  }
}
