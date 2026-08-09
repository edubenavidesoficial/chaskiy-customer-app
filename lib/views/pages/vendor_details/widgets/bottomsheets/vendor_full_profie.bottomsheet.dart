import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_semantic_colors.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_meta_chip.dart';
import 'package:chaskiy/widgets/buttons/call.button.dart';
import 'package:chaskiy/widgets/buttons/route.button.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/widgets/html_text_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

/// Ficha completa de la tienda: estado, contacto, horario y descripción.
class VendorFullProfileBottomSheet extends StatelessWidget {
  const VendorFullProfileBottomSheet(this.vendor, {super.key});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final description = vendor.description.trim();

    return ConstrainedBox(
      //la hoja solo crece lo que necesita: con pocos datos no tiene por qué
      //ocupar toda la pantalla
      constraints: BoxConstraints(maxHeight: context.percentHeight * 88),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(vendor: vendor),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Wrap(spacing: 8, runSpacing: 8, children: _chips(context)),
            ),

            if (vendor.address.isNotEmptyAndNotNull &&
                AppUISettings.showVendorAddress)
              _ContactRow(
                icon: HugeIcons.strokeRoundedLocation01,
                value: vendor.address,
                action: RouteButton(vendor, size: 20),
              ),

            if (vendor.phone.isNotEmptyAndNotNull &&
                AppUISettings.showVendorPhone)
              _ContactRow(
                icon: HugeIcons.strokeRoundedCall02,
                value: vendor.phone,
                action: CallButton(vendor, size: 20),
              ),

            _Section(
              title: "Working hours".tr(),
              child: _WorkingHours(vendor: vendor),
            ),

            if (description.isNotEmpty)
              _Section(
                title: "Description".tr(),
                //en web view la descripción venía con su propio fondo blanco,
                //que en modo oscuro quedaba como un recuadro en blanco
                child: DefaultTextStyle(
                  style:
                      theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ) ??
                      const TextStyle(),
                  child: HtmlTextView(description, padding: EdgeInsets.zero),
                ),
              ),

            SizedBox(height: 20 + context.mq.padding.bottom),
          ],
        ),
      ),
    );
  }

  List<Widget> _chips(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantics = theme.semantics;

    return [
      VendorMetaChip(
        icon:
            vendor.isOpen
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded,
        label: vendor.isOpen ? "Open".tr() : "Closed".tr(),
        foreground:
            vendor.isOpen
                ? semantics.onSuccessContainer
                : colors.onErrorContainer,
        background:
            vendor.isOpen ? semantics.successContainer : colors.errorContainer,
      ),
      if (vendor.delivery == 1)
        VendorMetaChip(
          icon: Icons.delivery_dining_outlined,
          label: "Delivery".tr(),
          foreground: semantics.onWarningContainer,
          background: semantics.warningContainer,
        ),
      if (vendor.pickup == 1)
        VendorMetaChip(
          icon: Icons.shopping_bag_outlined,
          label: "Pickup".tr(),
          foreground: colors.onPrimaryContainer,
          background: colors.primaryContainer,
        ),
      VendorMetaChip(
        icon: Icons.schedule_rounded,
        label: _timeLabel(vendor.prepareTime, vendor.prepareTimeUnit),
      ),
      VendorMetaChip(
        icon: Icons.directions_bike_outlined,
        label: _timeLabel(vendor.deliveryTime, vendor.deliveryTimeUnit),
      ),
    ];
  }

  String _timeLabel(String? value, String? unit) {
    final parts =
        [value, unit]
            .where((part) => part != null && part.trim().isNotEmpty)
            .map((part) => part!.trim())
            .toList();
    return parts.isEmpty ? 'Por confirmar' : parts.join(' ');
  }
}

/// Logo y nombre de la tienda.
class _Header extends StatelessWidget {
  const _Header({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomImage(imageUrl: vendor.logo, boxFit: BoxFit.cover),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              vendor.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bloque con título en versalitas y un separador arriba.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: colors.outlineVariant, height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

/// Dirección o teléfono con su botón de acción.
class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.value,
    required this.action,
  });

  final IconData icon;
  final String value;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 19, color: colors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
          const SizedBox(width: 10),
          action,
        ],
      ),
    );
  }
}

/// Horario de la semana.
class _WorkingHours extends StatelessWidget {
  const _WorkingHours({required this.vendor});

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final labelStyle = theme.textTheme.bodyMedium;
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colors.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (vendor.days.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${"Sunday".tr()} - ${"Saturday".tr()}', style: labelStyle),
          Text("All Hours".tr(), style: valueStyle),
        ],
      );
    }

    return Column(
      children:
          vendor.days
              .map(
                (opDay) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${opDay.name}'.tr(), style: labelStyle),
                      Text(
                        '${opDay.openTime} - ${opDay.closeTime}',
                        style: valueStyle,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }
}
