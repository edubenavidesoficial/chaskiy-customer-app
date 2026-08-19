import 'dart:async';

import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/driver_assignment.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/requests/driver_vehicle.request.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/driver_location.service.dart';
import 'package:chaskiy/services/driver_assignment.service.dart';
import 'package:chaskiy/widgets/order_status_chip.dart';
import 'package:chaskiy/views/pages/driver/driver_order_details.page.dart';
import 'package:flutter/material.dart';

class DriverAssignedOrdersPage extends StatefulWidget {
  const DriverAssignedOrdersPage({super.key});

  @override
  State<DriverAssignedOrdersPage> createState() =>
      _DriverAssignedOrdersPageState();
}

class _DriverAssignedOrdersPageState extends State<DriverAssignedOrdersPage> {
  final OrderRequest _orderRequest = OrderRequest();
  final AuthRequest _authRequest = AuthRequest();
  final DriverVehicleRequest _vehicleRequest = DriverVehicleRequest();
  List<Order> _orders = const [];
  User? _user;
  bool _loading = true;
  bool _changingAvailability = false;
  Object? _error;
  StreamSubscription<DriverAssignment>? _assignmentSubscription;
  StreamSubscription<bool>? _refreshSubscription;
  Timer? _refreshTimer;
  bool _showingAssignment = false;

  /// Cada cuánto se vuelve a pedir la lista.
  ///
  /// Una asignación hecha a mano desde el panel no manda aviso, así que sin
  /// esto el conductor solo se entera si arrastra la lista hacia abajo.
  static const _refreshInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    _assignmentSubscription = DriverAssignmentService.instance.assignments
        .listen(_showAssignment);
    _refreshSubscription = AppService().refreshAssignedOrders.listen(
      (_) => _load(silent: true),
    );
    _refreshTimer = Timer.periodic(
      _refreshInterval,
      (_) => _load(silent: true),
    );
    _load();
  }

  @override
  void dispose() {
    _assignmentSubscription?.cancel();
    _refreshSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// [silent] evita el indicador de carga: las recargas de fondo no deben
  /// hacer parpadear la lista que el conductor está mirando.
  Future<void> _load({bool silent = false}) async {
    if (mounted && !silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final user = await AuthServices.getCurrentUser();
      final orders = await _orderRequest.getOrders(
        page: 1,
        params: {'driver_id': user.id, 'type': 'assigned'},
      );
      if (!mounted) return;
      setState(() {
        _user = user;
        _orders = orders;
      });
      if (user.isOnline) {
        try {
          await _ensureReadyToReceive();
          await DriverLocationService.instance.start();
          await DriverAssignmentService.instance.start();
        } catch (error) {
          await _forceOffline(error);
        }
      }
    } catch (error) {
      //un fallo de red en una recarga de fondo no debe borrar la lista que el
      //conductor ya tiene en pantalla; el siguiente intento la actualiza
      if (mounted && !silent) setState(() => _error = error);
    } finally {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_changingAvailability || _user == null) return;
    setState(() => _changingAvailability = true);
    try {
      final response = await _authRequest.updateOnlineStatus(isOnline: value);
      if (!response.allGood) throw response.message ?? 'No se pudo actualizar';
      _user!.isOnline = value;
      await AuthServices.saveUser(_user!.toJson(), reload: false);
      if (value) {
        try {
          await _ensureReadyToReceive();
          await DriverLocationService.instance.start();
          await DriverAssignmentService.instance.start();
        } catch (error) {
          await _forceOffline(error);
          rethrow;
        }
      } else {
        await DriverAssignmentService.instance.stop();
        await DriverLocationService.instance.stop();
      }
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _changingAvailability = false);
    }
  }

  Future<void> _ensureReadyToReceive() async {
    final vehicles = await _vehicleRequest.vehicles();
    final ready = vehicles.any(
      (vehicle) => vehicle.isActive && vehicle.isVerified,
    );
    if (!ready) {
      throw const DriverLocationException(
        'Necesitas un vehículo activo y verificado para recibir solicitudes.',
      );
    }
  }

  Future<void> _forceOffline(Object reason) async {
    await DriverAssignmentService.instance.stop();
    await DriverLocationService.instance.stop();
    if (_user != null) {
      _user!.isOnline = false;
      await AuthServices.saveUser(_user!.toJson(), reload: false);
    }
    try {
      await _authRequest.updateOnlineStatus(isOnline: false);
    } catch (_) {
      // Preserve the local safe state even if the compensating request fails.
    }
    if (mounted) setState(() {});
  }

  Future<void> _showAssignment(DriverAssignment assignment) async {
    if (!mounted || _showingAssignment) return;
    _showingAssignment = true;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      showDragHandle: true,
      builder: (context) => _DriverAssignmentSheet(assignment: assignment),
    );
    try {
      final driverId = (await AuthServices.getCurrentUser()).id;
      if (accepted == true) {
        await _orderRequest.acceptDriverAssignment(
          orderId: assignment.orderId,
          driverId: driverId,
        );
        await _load();
      } else {
        await _orderRequest.rejectDriverAssignment(
          orderId: assignment.orderId,
          driverId: driverId,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      await DriverAssignmentService.instance.clear(assignment);
      _showingAssignment = false;
    }
  }

  Future<void> _openOrder(Order order) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DriverOrderDetailsPage(order: order)),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              sliver: SliverToBoxAdapter(
                child: _AvailabilityCard(
                  isOnline: _user?.isOnline ?? false,
                  busy: _changingAvailability,
                  onChanged: _toggleAvailability,
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: _DriverOrderMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'No pudimos cargar los pedidos',
                  message: '$_error',
                  action: _load,
                ),
              )
            else if (_orders.isEmpty)
              const SliverFillRemaining(
                child: _DriverOrderMessage(
                  icon: Icons.inbox_outlined,
                  title: 'No tienes pedidos asignados',
                  message: 'Desliza hacia abajo para actualizar.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList.separated(
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Material(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _openOrder(order),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor.withValues(
                                    alpha: .1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.local_shipping_outlined,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${order.code}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    OrderStatusChip(order.status),
                                    const SizedBox(height: 6),
                                    Text(
                                      order.formattedDate,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DriverAssignmentSheet extends StatelessWidget {
  const _DriverAssignmentSheet({required this.assignment});

  final DriverAssignment assignment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              assignment.isTaxi ? 'Nueva carrera' : 'Nuevo pedido',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.trip_origin, color: Colors.green),
              title: const Text('Recoger en'),
              subtitle: Text(
                assignment.pickup.isEmpty
                    ? 'Ubicación por confirmar'
                    : assignment.pickup,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Entregar en'),
              subtitle: Text(
                assignment.dropoff.isEmpty
                    ? 'Ubicación por confirmar'
                    : assignment.dropoff,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: _AssignmentAmount(
                    label: 'Ganancia',
                    value: assignment.amount,
                  ),
                ),
                Expanded(
                  child: _AssignmentAmount(
                    label: 'Total',
                    value: assignment.total,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Aceptar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentAmount extends StatelessWidget {
  const _AssignmentAmount({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      Text(
        value,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isOnline,
    required this.busy,
    required this.onChanged,
  });

  final bool isOnline;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (isOnline ? Colors.green : Colors.grey).withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isOnline ? Colors.green : Colors.grey).withValues(alpha: .25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.location_on : Icons.location_off_outlined,
            color: isOnline ? Colors.green : Colors.grey.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Disponible' : 'No disponible',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  isOnline
                      ? 'Puedes recibir asignaciones'
                      : 'Actívate cuando estés listo',
                ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(value: isOnline, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DriverOrderMessage extends StatelessWidget {
  const _DriverOrderMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function()? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: action, child: const Text('Reintentar')),
            ],
          ],
        ),
      ),
    );
  }
}
