import 'dart:io';

import 'package:chaskiy/requests/auth.request.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DriverDocumentsPage extends StatefulWidget {
  const DriverDocumentsPage({super.key});

  @override
  State<DriverDocumentsPage> createState() => _DriverDocumentsPageState();
}

class _DriverDocumentsPageState extends State<DriverDocumentsPage> {
  final AuthRequest _request = AuthRequest();
  List<File> _files = const [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    //el estado de la solicitud lo decide el panel, así que se relee al entrar
    //en vez de confiar en lo que quedó guardado del último login
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    try {
      final user = await _request.getMyDetails();
      await AuthServices.saveUser(user.toJson(), reload: false);
      if (mounted) setState(() {});
    } catch (error) {
      print("No se pudo releer el perfil del conductor ==> $error");
    }
  }

  Future<void> _selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result == null || !mounted) return;
    setState(() {
      _files = result.paths
          .whereType<String>()
          .map(File.new)
          .toList(growable: false);
    });
  }

  Future<void> _submit() async {
    if (_files.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final response = await _request.submitDriverDocuments(files: _files);
      if (!response.allGood) {
        throw response.localizedMessage ?? 'No se pudo enviar';
      }
      final user = await _request.getMyDetails();
      await AuthServices.saveUser(user.toJson(), reload: false);
      if (!mounted) return;
      setState(() => _files = const []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.localizedMessage ?? 'Documentos enviados'),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final user = AuthServices.currentUser;
    final pending = user?.pendingDocumentApproval ?? false;
    //el servidor solo acepta archivos cuando hay una solicitud abierta; sin
    //ella la subida se rechaza con "no se ha encontrado la solicitud"
    final requested = user?.documentRequested ?? false;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Documentos del conductor',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshUser,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (pending)
              const _StateCard(
                icon: Icons.hourglass_top_rounded,
                tone: _Tone.warning,
                title: 'Documentos en revisión',
                message:
                    'Ya recibimos tus archivos. Te avisamos apenas termine la '
                    'revisión.',
              )
            else if (!requested)
              const _StateCard(
                icon: Icons.inbox_outlined,
                tone: _Tone.neutral,
                title: 'Todavía no te piden documentos',
                message:
                    'Cuando el equipo de Chaskiy solicite tu documentación, '
                    'aparecerá aquí para que la subas. Desliza hacia abajo '
                    'para revisar si ya hay una solicitud.',
              )
            else
              ..._uploadForm(theme, scheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _uploadForm(ThemeData theme, ColorScheme scheme) => [
    Text(
      'Adjunta los documentos solicitados',
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
      ),
    ),
    const SizedBox(height: 6),
    Text(
      'Formatos permitidos: JPG, PNG y PDF.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    const SizedBox(height: 20),
    SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _sending ? null : _selectFiles,
        icon: const Icon(Icons.attach_file_rounded),
        label: const Text('Seleccionar documentos'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
    if (_files.isNotEmpty) ...[
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            for (final file in _files)
              ListTile(
                dense: true,
                leading: Icon(
                  Icons.description_outlined,
                  color: scheme.onSurfaceVariant,
                ),
                title: Text(
                  file.path.split(Platform.pathSeparator).last,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  tooltip: 'Quitar',
                  onPressed:
                      _sending
                          ? null
                          : () => setState(() {
                            _files = _files
                                .where((item) => item != file)
                                .toList(growable: false);
                          }),
                  icon: Icon(Icons.close_rounded, color: scheme.error),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon:
              _sending
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.cloud_upload_outlined),
          label: const Text(
            'Enviar para revisión',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    ],
  ];
}

enum _Tone { warning, neutral }

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.tone,
  });

  final IconData icon;
  final String title;
  final String message;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background =
        tone == _Tone.warning
            ? scheme.tertiaryContainer
            : scheme.surfaceContainerHighest;
    final foreground =
        tone == _Tone.warning
            ? scheme.onTertiaryContainer
            : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: foreground),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
