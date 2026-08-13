import 'package:flutter/material.dart';

/// Botón redondo para llamar o escribir.
///
/// Antes eran botones rectangulares del ancho de un `CustomButton` metidos en
/// un `FittedBox`, y cada pantalla los encogía de una forma distinta.
class ContactIconButton extends StatelessWidget {
  const ContactIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final Function onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () => onPressed(),
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        minimumSize: const Size(44, 44),
      ),
    );
  }
}
