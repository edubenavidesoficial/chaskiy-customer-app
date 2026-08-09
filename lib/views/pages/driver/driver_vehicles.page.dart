import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/driver_vehicle.dart';
import 'package:chaskiy/requests/driver_vehicle.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/views/pages/driver/driver_vehicle_form.page.dart';

class DriverVehiclesPage extends StatefulWidget {
  const DriverVehiclesPage({super.key});

  @override
  State<DriverVehiclesPage> createState() => _DriverVehiclesPageState();
}

class _DriverVehiclesPageState extends State<DriverVehiclesPage> {
  final DriverVehicleRequest _request = DriverVehicleRequest();
  List<DriverVehicle> _vehicles = const [];
  bool _loading = true;
  int? _activatingId;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final vehicles = await _request.vehicles();
      if (!mounted) return;
      setState(() => _vehicles = vehicles);
      final active = vehicles.where((vehicle) => vehicle.isActive).firstOrNull;
      if (active != null) await AuthServices.saveDriverVehicle(active.toJson());
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _activate(DriverVehicle vehicle) async {
    if (!vehicle.isVerified || vehicle.isActive || _activatingId != null) return;
    setState(() => _activatingId = vehicle.id);
    try {
      await _request.activate(vehicle.id);
      await AuthServices.saveDriverVehicle(vehicle.toJson());
      await _load();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _activatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
        actions: [
          IconButton(
            tooltip: 'Registrar vehículo',
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const DriverVehicleFormPage()),
              );
              if (saved == true) await _load();
            },
            icon: const Icon(Icons.add_road_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const Icon(Icons.directions_car_outlined, size: 54),
          const SizedBox(height: 12),
          Text('$_error', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: _load, child: const Text('Reintentar')),
        ],
      );
    }
    if (_vehicles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const Icon(Icons.no_crash_outlined, size: 54),
          const SizedBox(height: 12),
          const Text('Todavía no tienes vehículos registrados.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final saved = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const DriverVehicleFormPage()),
              );
              if (saved == true) await _load();
            },
            icon: const Icon(Icons.add),
            label: const Text('Registrar vehículo'),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: vehicle.isActive
                  ? AppColor.primaryColor
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_car_filled_outlined),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        vehicle.type.isEmpty ? 'Vehículo' : vehicle.type,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (vehicle.isActive)
                      const Chip(label: Text('Activo')),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${vehicle.make} ${vehicle.model}'.trim()),
                Text('${vehicle.registrationNumber} · ${vehicle.color}'),
                const SizedBox(height: 8),
                Text(
                  vehicle.isVerified ? 'Verificado' : 'Pendiente de verificación',
                  style: TextStyle(
                    color: vehicle.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (vehicle.isVerified && !vehicle.isActive) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: _activatingId == vehicle.id
                          ? null
                          : () => _activate(vehicle),
                      child: _activatingId == vehicle.id
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Usar este vehículo'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
