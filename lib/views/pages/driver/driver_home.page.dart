import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/session.service.dart';
import 'package:chaskiy/services/driver_location.service.dart';
import 'package:chaskiy/services/driver_assignment.service.dart';
import 'package:chaskiy/views/pages/driver/driver_assigned_orders.page.dart';
import 'package:chaskiy/views/pages/driver/driver_vehicles.page.dart';
import 'package:chaskiy/views/pages/driver/driver_documents.page.dart';
import 'package:chaskiy/views/pages/driver/driver_finance.page.dart';
import 'package:chaskiy/views/pages/splash.page.dart';
import 'package:chaskiy/views/pages/home.page.dart';
import 'package:chaskiy/enums/app_role.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:flutter/material.dart';

/// Root for every driver-only feature.
///
/// Background location and order assignment are intentionally not started by
/// this shell. Their lifecycle will be owned by the driver availability module.
class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _currentIndex = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthServices.getCurrentUser();
    if (!mounted) return;

    if (!SessionService.isDriver) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.homeRoute, (_) => false);
      return;
    }
    setState(() => _user = user);
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

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _DriverDashboard(user: _user),
      const DriverAssignedOrdersPage(),
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

class _DriverDashboard extends StatelessWidget {
  const _DriverDashboard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hola, ${user?.name ?? 'conductor'}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Centro de operaciones de Chaskiy',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 34),
                SizedBox(height: 12),
                Text(
                  'Modo conductor preparado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Text(
                  'La disponibilidad y ubicación en segundo plano se activarán desde un control independiente y solo con tus permisos.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
