import 'dart:async';

import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/requests/driver_finance.request.dart';
import 'package:chaskiy/requests/driver_vehicle.request.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/services/driver_location.service.dart';
import 'package:chaskiy/services/driver_assignment.service.dart';
import 'package:chaskiy/services/setup.service.dart';
import 'package:chaskiy/views/pages/driver/driver_assigned_orders.page.dart';
import 'package:chaskiy/views/pages/driver/driver_vehicles.page.dart';
import 'package:chaskiy/views/pages/driver/driver_documents.page.dart';
import 'package:chaskiy/views/pages/driver/driver_finance.page.dart';
import 'package:chaskiy/views/pages/driver/driver_order_details.page.dart';
import 'package:chaskiy/views/pages/splash.page.dart';
import 'package:chaskiy/views/pages/home.page.dart';
import 'package:chaskiy/enums/app_role.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:flutter/material.dart';

/// Root for every driver-only feature.
///
/// Owns the driver runtime while the driver role is active.
class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _currentIndex = 0;
  User? _user;
  bool _changingAvailability = false;
  final AuthRequest _authRequest = AuthRequest();
  final DriverVehicleRequest _vehicleRequest = DriverVehicleRequest();

  @override
  void initState() {
    super.initState();
    unawaited(_initializeDriverRuntime());
  }

  Future<void> _initializeDriverRuntime() async {
    final user = await AuthServices.getCurrentUser();
    if (!mounted) return;

    if (!SessionService.isDriver) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (_) => false);
      return;
    }
    setState(() => _user = user);

    // El modo conductor no pasa por HomeViewModel. Inicializa aquí FCM y el
    // sondeo para recibir asignaciones desde cualquier pestaña del módulo.
    await SetupService.init();
    if (!user.isOnline || !mounted) return;
    await DriverAssignmentService.instance.start();
    try {
      await DriverLocationService.instance.start();
    } catch (_) {
      // La pantalla de pedidos muestra el motivo y permite corregir permisos.
    }
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context, rootNavigator: true);
    try {
      await DriverAssignmentService.instance.stop();
      await DriverLocationService.instance.stop();
      await AuthServices.logout();
    } finally {
      if (mounted) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashPage()),
          (_) => false,
        );
      }
    }
  }

  Future<void> _switchToCustomer() async {
    final user = _user;
    if (user == null || !user.hasCustomerRole) return;
    await DriverAssignmentService.instance.stop();
    await DriverLocationService.instance.stop();
    await SessionService.setActiveRole(AppRole.customer, user: user);
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomePage()),
        (_) => false,
      );
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    final user = _user;
    if (_changingAvailability || user == null) return;
    setState(() => _changingAvailability = true);
    try {
      if (value) {
        final vehicles = await _vehicleRequest.vehicles();
        final ready = vehicles.any(
          (vehicle) => vehicle.isActive && vehicle.isVerified,
        );
        if (!ready) {
          throw const DriverLocationException(
            'Necesitas un vehículo activo y verificado para conectarte.',
          );
        }
      }
      final response = await _authRequest.updateOnlineStatus(isOnline: value);
      if (!response.allGood) throw response.message ?? 'No se pudo actualizar';
      user.isOnline = value;
      await AuthServices.saveUser(user.toJson(), reload: false);
      if (value) {
        await DriverAssignmentService.instance.start();
        await DriverLocationService.instance.start();
      } else {
        await DriverAssignmentService.instance.stop();
        await DriverLocationService.instance.stop();
      }
      if (mounted) setState(() {});
    } catch (error) {
      user.isOnline = false;
      await AuthServices.saveUser(user.toJson(), reload: false);
      try {
        await _authRequest.updateOnlineStatus(isOnline: false);
      } catch (_) {}
      await DriverAssignmentService.instance.stop();
      await DriverLocationService.instance.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
        setState(() {});
      }
    } finally {
      if (mounted) setState(() => _changingAvailability = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _DriverDashboard(
        user: _user,
        changingAvailability: _changingAvailability,
        onAvailabilityChanged: _toggleAvailability,
        openOrders: () => setState(() => _currentIndex = 1),
        openFinances: () => setState(() => _currentIndex = 2),
      ),
      DriverAssignedOrdersPage(
        availabilityUser: _user,
        changingAvailability: _changingAvailability,
        onAvailabilityChanged: _toggleAvailability,
        onAvailabilitySynced: (value) {
          if (_user == null || _user!.isOnline == value) return;
          setState(() => _user!.isOnline = value);
        },
      ),
      const DriverFinancePage(),
      _DriverAccount(
        user: _user,
        onLogout: _logout,
        onSwitchToCustomer: _switchToCustomer,
      ),
    ];

    return BasePage(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.delivery_dining_outlined),
            selectedIcon: Icon(Icons.delivery_dining),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finanzas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cuenta',
          ),
        ],
      ),
    );
  }
}

class _DriverDashboard extends StatefulWidget {
  const _DriverDashboard({
    required this.user,
    required this.changingAvailability,
    required this.onAvailabilityChanged,
    required this.openOrders,
    required this.openFinances,
  });

  final User? user;
  final bool changingAvailability;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback openOrders;
  final VoidCallback openFinances;

  @override
  State<_DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<_DriverDashboard> {
  final DriverFinanceRequest _financeRequest = DriverFinanceRequest();
  final OrderRequest _orderRequest = OrderRequest();
  Map<String, dynamic> _metrics = const {};
  Order? _nextOrder;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final user = await AuthServices.getCurrentUser();
      final results = await Future.wait([
        _financeRequest.metrics(),
        _orderRequest.getOrders(
          page: 1,
          params: {'driver_id': user.id, 'type': 'assigned'},
        ),
      ]);
      if (!mounted) return;
      final orders = results[1] as List<Order>;
      setState(() {
        _metrics = results[0] as Map<String, dynamic>;
        _nextOrder = orders.isEmpty ? null : orders.first;
      });
    } catch (_) {
      // El inicio conserva sus accesos aunque una métrica no esté disponible.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _money(dynamic value) {
    final amount = double.tryParse('${value ?? 0}') ?? 0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final earnings =
        _metrics['earnings'] is Map
            ? Map<String, dynamic>.from(_metrics['earnings'])
            : const <String, dynamic>{};
    final orders =
        _metrics['orders'] is Map
            ? Map<String, dynamic>.from(_metrics['orders'])
            : const <String, dynamic>{};
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            Text(
              'Hola, ${widget.user?.name ?? 'conductor'}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Centro de operaciones de Chaskiy',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: (widget.user?.isOnline == true
                        ? Colors.green
                        : Colors.grey)
                    .withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (widget.user?.isOnline == true
                          ? Colors.green
                          : Colors.grey)
                      .withValues(alpha: .25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.user?.isOnline == true
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color:
                        widget.user?.isOnline == true
                            ? Colors.green
                            : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user?.isOnline == true
                              ? 'Disponible'
                              : 'No disponible',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.user?.isOnline == true
                              ? 'Recibiendo nuevas solicitudes'
                              : 'Conéctate cuando estés listo',
                        ),
                      ],
                    ),
                  ),
                  if (widget.changingAvailability)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Switch(
                      value: widget.user?.isOnline ?? false,
                      onChanged: widget.onAvailabilityChanged,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_nextOrder != null) ...[
              Text(
                'Servicio en curso',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  minTileHeight: 82,
                  leading: const CircleAvatar(
                    child: Icon(Icons.route_outlined),
                  ),
                  title: Text('#${_nextOrder!.code} · ${_nextOrder!.status}'),
                  subtitle: Text(_nextOrder!.formattedDate),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => DriverOrderDetailsPage(order: _nextOrder!),
                      ),
                    );
                    await _load();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            Text(
              'Resumen de hoy',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DashboardMetric(
                    icon: Icons.payments_outlined,
                    label: 'Ganancias',
                    value: _loading ? '—' : _money(earnings['today']),
                    onTap: widget.openFinances,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DashboardMetric(
                    icon: Icons.receipt_long_outlined,
                    label: 'Servicios',
                    value: _loading ? '—' : '${orders['today'] ?? 0}',
                    onTap: widget.openOrders,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Accesos rápidos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Ver pedidos y carreras'),
              subtitle: const Text('Revisa asignaciones y servicios activos'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: widget.openOrders,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Ver ganancias'),
              subtitle: const Text('Consulta movimientos y pagos'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: widget.openFinances,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColor.primaryColor.withValues(alpha: .08),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColor.primaryColor),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _DriverAccount extends StatelessWidget {
  const _DriverAccount({
    required this.user,
    required this.onLogout,
    required this.onSwitchToCustomer,
  });

  final User? user;
  final Future<void> Function() onLogout;
  final Future<void> Function() onSwitchToCustomer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cuenta de conductor',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: Colors.white,
              child: Text(
                (user?.name.isNotEmpty == true ? user!.name[0] : 'C')
                    .toUpperCase(),
              ),
            ),
            title: Text(user?.name ?? 'Conductor'),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),
          if (user?.hasCustomerRole == true)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Cambiar a modo cliente'),
              subtitle: const Text('Compra y solicita servicios'),
              onTap: onSwitchToCustomer,
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.directions_car_outlined),
            title: const Text('Mis vehículos'),
            trailing: const Icon(Icons.chevron_right),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DriverVehiclesPage()),
                ),
          ),
          //siempre visible: aunque no haya nada pendiente, es el único lugar
          //donde el conductor puede ver y enviar su verificación
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Verificación y documentos'),
            subtitle: Text(
              user?.pendingDocumentApproval == true
                  ? 'Verificación pendiente'
                  : user?.documentRequested == true
                  ? 'Se requiere información'
                  : 'Consulta o actualiza tus documentos',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const DriverDocumentsPage(),
                  ),
                ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
