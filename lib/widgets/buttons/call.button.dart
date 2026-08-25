import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/constants/app_colors.dart';

class CallButton extends StatelessWidget {
  const CallButton(this.vendor, {this.phone, this.size, Key? key})
    : super(key: key);

  final Vendor? vendor;
  final double? size;
  final String? phone;
  @override
  Widget build(BuildContext context) {
    return Icon(FlutterIcons.phone_ant, size: size ?? 24, color: Colors.white)
        .p8()
        .box
        .color(AppColor.primaryColor)
        .roundedFull
        .make()
        .onInkTap(() async {
          final rawPhone = (vendor != null ? vendor?.phone : phone) ?? '';
          final normalizedPhone = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
          if (normalizedPhone.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No hay un número disponible')),
            );
            return;
          }

          final opened = await launchUrlString(
            'tel:$normalizedPhone',
            mode: LaunchMode.externalApplication,
          );
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir la aplicación de llamadas'),
              ),
            );
          }
        });
  }
}
