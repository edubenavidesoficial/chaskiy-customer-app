import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:flutter/material.dart';

class DriverOnboardingPage extends StatefulWidget {
  const DriverOnboardingPage({super.key});

  @override
  State<DriverOnboardingPage> createState() => _DriverOnboardingPageState();
}

class _DriverOnboardingPageState extends State<DriverOnboardingPage> {
  String _driverType = 'delivery';
  bool _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final response = await AuthRequest().applyForDriver(
        driverType: _driverType,
      );
      if (!response.allGood) {
        await AlertService.error(
          title: 'No se pudo enviar la solicitud',
          text: response.message,
        );
        return;
      }
      final body = Map<String, dynamic>.from(response.body);
      //sin `reload: false` la recarga de configuración reinicia la navegación
      //y esta pantalla se cierra sola antes de confirmar el envío
      if (body['user'] is Map) {
        await AuthServices.saveUser(body['user'], reload: false);
      }
      await AlertService.success(
        title: 'Solicitud recibida',
        text: 'Revisaremos tu perfil antes de habilitar el modo conductor.',
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      await AlertService.error(title: 'Error', text: '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trabaja con Chaskiy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.delivery_dining, size: 72),
          const SizedBox(height: 20),
          Text(
            'Activa tu perfil de conductor',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu cuenta de cliente se conservará. Cuando aprobemos la solicitud podrás cambiar entre ambos modos sin cerrar sesión.',
          ),
          const SizedBox(height: 24),
          RadioListTile<String>(
            value: 'delivery',
            groupValue: _driverType,
            title: const Text('Motorizado / entregas'),
            onChanged: (value) => setState(() => _driverType = value!),
          ),
          RadioListTile<String>(
            value: 'taxi',
            groupValue: _driverType,
            title: const Text('Conductor de taxi'),
            subtitle: const Text('Podrás registrar el vehículo al aprobarse.'),
            onChanged: (value) => setState(() => _driverType = value!),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon:
                _busy
                    ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.send_outlined),
            label: Text(_busy ? 'Enviando…' : 'Enviar solicitud'),
          ),
        ],
      ),
    );
  }
}
