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
      if (!response.allGood) throw response.message ?? 'No se pudo enviar';
      final user = await _request.getMyDetails();
      await AuthServices.saveUser(user.toJson(), reload: false);
      if (!mounted) return;
      setState(() => _files = const []);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Documentos enviados')),
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
    final user = AuthServices.currentUser;
    final pending = user?.pendingDocumentApproval ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('Documentos del conductor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (pending)
            const Card(
              child: ListTile(
                leading: Icon(Icons.hourglass_top, color: Colors.orange),
                title: Text('Verificación pendiente'),
                subtitle: Text(
                  'Recibirás una notificación cuando la revisión termine.',
                ),
              ),
            )
          else ...[
            const Text(
              'Adjunta los documentos solicitados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text('Formatos permitidos: JPG, PNG y PDF.'),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _sending ? null : _selectFiles,
              icon: const Icon(Icons.attach_file),
              label: const Text('Seleccionar documentos'),
            ),
            if (_files.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._files.map(
                (file) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: Text(file.path.split(Platform.pathSeparator).last),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _sending ? null : _submit,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: const Text('Enviar para revisión'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
