import 'package:flutter/material.dart';

/// Bloque de la pantalla de detalles del pedido.
///
/// Cada sección traía su propio título con distinto tamaño y peso, así que la
/// pantalla se leía como recuadros sueltos. El título vive aquí para que todos
/// tengan la misma jerarquía y la misma separación.
class OrderDetailsCard extends StatelessWidget {
  const OrderDetailsCard({
    required this.child,
    this.title,
    this.action,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final String? title;

  /// Acción al lado del título (compartir, ver código, etc.).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
