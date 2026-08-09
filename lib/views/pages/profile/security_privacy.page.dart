import 'package:flutter/material.dart';
import 'package:chaskiy/constants/api.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/widgets/cards/profile.card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SecurityPrivacyPage extends StatefulWidget {
  const SecurityPrivacyPage({super.key});

  @override
  State<SecurityPrivacyPage> createState() => _SecurityPrivacyPageState();
}

class _SecurityPrivacyPageState extends State<SecurityPrivacyPage>
    with WidgetsBindingObserver {
  PermissionStatus? _locationStatus;
  PermissionStatus? _notificationStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final statuses = await Future.wait([
      Permission.locationWhenInUse.status,
      Permission.notification.status,
    ]);
    if (!mounted) return;
    setState(() {
      _locationStatus = statuses[0];
      _notificationStatus = statuses[1];
    });
  }

  Future<void> _managePermission(Permission permission) async {
    final currentStatus = await permission.status;
    if (currentStatus.isPermanentlyDenied || currentStatus.isRestricted) {
      await openAppSettings();
    } else {
      final result = await permission.request();
      if (result.isPermanentlyDenied) await openAppSettings();
    }
    await _refreshPermissions();
  }

  Future<void> _openLegalPage(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.colorScheme.surface : const Color(0xFFF5F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text(
          'Seguridad y privacidad',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: .76),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: Colors.white,
                      size: 31,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu información está bajo tu control',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Administra el acceso y la seguridad de tu cuenta.',
                          style: TextStyle(
                            color: Color(0xFFE7F0FF),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: 'Seguridad de la cuenta',
              children: [
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Cambiar contraseña',
                  subtitle: 'Actualiza tu clave de acceso',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.changePasswordRoute,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SettingsSection(
              title: 'Permisos de la aplicación',
              children: [
                SettingsTile(
                  icon: Icons.location_on_outlined,
                  title: 'Ubicación',
                  subtitle: 'Direcciones, negocios cercanos y seguimiento',
                  trailing: _PermissionBadge(status: _locationStatus),
                  showChevron: false,
                  onTap: () => _managePermission(Permission.locationWhenInUse),
                ),
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificaciones',
                  subtitle: 'Actualizaciones de pedidos y promociones',
                  trailing: _PermissionBadge(status: _notificationStatus),
                  showChevron: false,
                  onTap: () => _managePermission(Permission.notification),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SettingsSection(
              title: 'Privacidad y datos',
              children: [
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de privacidad',
                  subtitle: 'Conoce cómo protegemos tus datos',
                  onTap: () => _openLegalPage(Api.privacyPolicy),
                ),
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Términos y condiciones',
                  subtitle: 'Consulta las condiciones de uso',
                  onTap: () => _openLegalPage(Api.terms),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Al tocar un permiso puedes autorizarlo o abrir la configuración '
              'del dispositivo si fue bloqueado anteriormente.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionBadge extends StatelessWidget {
  const _PermissionBadge({required this.status});

  final PermissionStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = status == null;
    final granted = status?.isGranted ?? false;
    final color = granted ? const Color(0xFF0A9B72) : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        loading ? 'Revisando' : (granted ? 'Permitido' : 'Revisar'),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
