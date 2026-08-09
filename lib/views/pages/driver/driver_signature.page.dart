import 'dart:io';

import 'package:chaskiy/constants/app_colors.dart';
import 'package:hand_signature/signature.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DriverSignaturePage extends StatefulWidget {
  const DriverSignaturePage({super.key});

  @override
  State<DriverSignaturePage> createState() => _DriverSignaturePageState();
}

class _DriverSignaturePageState extends State<DriverSignaturePage> {
  final HandSignatureControl _control = HandSignatureControl(
    threshold: 3,
    smoothRatio: .65,
    velocityRange: 2,
  );
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final data = await _control.toImage();
      if (data == null || data.lengthInBytes == 0) return;
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/driver_signature_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List());
      if (mounted) Navigator.pop(context, file);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Firma de recepción'),
          actions: [
            IconButton(
              tooltip: 'Limpiar',
              onPressed: _control.clear,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Solicita al receptor que firme dentro del recuadro.',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColor.primaryColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: HandSignature(
                      control: _control,
                      color: AppColor.primaryColor,
                      width: 2,
                      maxWidth: 8,
                      type: SignatureDrawType.line,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Confirmar firma'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
