import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class DeliveryAddressListItem extends StatelessWidget {
  const DeliveryAddressListItem({
    required this.deliveryAddress,
    this.onEditPressed,
    this.onDeletePressed,
    this.action = true,
    this.border = true,
    this.borderColor,
    this.showDefault = true,
    Key? key,
  }) : super(key: key);

  final DeliveryAddress deliveryAddress;
  final Function? onEditPressed;
  final Function? onDeletePressed;
  final bool action;
  final bool border;
  final bool showDefault;
  final Color? borderColor;

  bool get _canDeliver =>
      deliveryAddress.can_deliver == null || deliveryAddress.can_deliver!;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = deliveryAddress.defaultDeliveryAddress;
    final name = "${deliveryAddress.name ?? ''}".trim();
    final description = "${deliveryAddress.description ?? ''}".trim();

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDefault ? Icons.home_rounded : Icons.location_on_rounded,
            size: 26,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //etiqueta que le puso la persona a la dirección
                if (name.isNotEmpty)
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  "${deliveryAddress.address ?? ''}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: theme.colorScheme.onSurface.withOpacity(.92),
                  ),
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ),
                if (isDefault && showDefault)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _defaultChip(theme),
                  ),
                if (!_canDeliver)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      "Vendor does not service this location".tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (action) _actionsMenu(context, theme),
        ],
      ),
    );

    final resolvedBorderColor =
        borderColor ?? (border ? theme.colorScheme.outlineVariant : null);
    if (resolvedBorderColor == null ||
        resolvedBorderColor == Colors.transparent) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: resolvedBorderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: content,
    );
  }

  Widget _defaultChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Default".tr(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColor.primaryColor,
        ),
      ),
    );
  }

  /// Menú de acciones: reemplaza los bloques rojo y azul del diseño anterior.
  Widget _actionsMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      tooltip: "",
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) {
        if (value == 0) {
          onEditPressed?.call();
        } else {
          onDeletePressed?.call();
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 0,
              child: Row(
                children: [
                  const Icon(Icons.edit_outlined, size: 20),
                  const SizedBox(width: 10),
                  Text("Edit".tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Delete".tr(),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
    );
  }
}
