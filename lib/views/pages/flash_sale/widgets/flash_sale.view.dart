import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/flash_sale.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/flash_sale.vm.dart';
import 'package:chaskiy/views/pages/flash_sale/flash_sale.page.dart';
import 'package:chaskiy/views/pages/flash_sale/widgets/flash_sale.item_view.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_listed.list_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:slide_countdown/slide_countdown.dart';

class FlashSaleView extends StatefulWidget {
  const FlashSaleView(this.vendorType, {Key? key}) : super(key: key);

  //
  final VendorType vendorType;

  @override
  State<FlashSaleView> createState() => _FlashSaleViewState();
}

class _FlashSaleViewState extends State<FlashSaleView> {
  //a partir de aquí un contador ya no aporta urgencia y se vuelve ilegible
  static const Duration _countdownThreshold = Duration(hours: 48);

  static const List<String> _months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FlashSaleViewModel>.reactive(
      viewModelBuilder:
          () => FlashSaleViewModel(context, vendorType: widget.vendorType),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        //
        if (vm.isBusy) {
          return BusyIndicator().p20().centered();
        } else if (vm.flashSales.isEmpty) {
          return UiSpacer.emptySpace();
        }
        //
        return VStack([...flashSalesListView(context, vm)]);
      },
    );
  }

  //
  List<Widget> flashSalesListView(BuildContext context, FlashSaleViewModel vm) {
    List<Widget> list = [];
    List<FlashSale> flashsales = vm.flashSales;
    //
    flashsales.forEach((flashsale) {
      //
      if (flashsale.items == null ||
          flashsale.items!.isEmpty ||
          flashsale.isExpired) {
        list.add(UiSpacer.emptySpace());
        return;
      }

      //items de la promoción
      Widget items = CustomListedListView(
        noScrollPhysics: false,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        items:
            (flashsale.items ?? [])
                .map(
                  (flashSaleItem) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FlashSaleItemListItem(flashSaleItem),
                  ),
                )
                .toList(),
      ).h(216);

      //
      list.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: VStack([
            _header(context, flashsale),
            UiSpacer.vSpace(10),
            items,
          ]),
        ),
      );
    });

    return list;
  }

  //cabecera: antes era una franja roja a todo el ancho que partía la pantalla
  Widget _header(BuildContext context, FlashSale flashsale) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColor.closeColor.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: AppColor.closeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${flashsale.name}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 4),
                _deadline(context, flashsale),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "See all".tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ).onInkTap(() => openFlashSaleItems(context, flashsale)),
        ],
      ),
    );
  }

  //cuenta regresiva solo cuando falta poco; si no, la fecha de cierre
  Widget _deadline(BuildContext context, FlashSale flashsale) {
    final theme = Theme.of(context);
    final duration = flashsale.countDownDuration;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    if (duration > _countdownThreshold) {
      final expiresAt = flashsale.expiresAt;
      if (expiresAt == null) {
        return const SizedBox.shrink();
      }
      return Text(
        "Hasta el ${expiresAt.day} de ${_months[expiresAt.month - 1]}",
        style: labelStyle,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("TIME LEFT:".tr(), style: labelStyle),
        const SizedBox(width: 6),
        SlideCountdown(
          duration: duration,
          separatorType: SeparatorType.symbol,
          slideDirection: SlideDirection.up,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColor.closeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          onDone: () => setState(() {}),
        ),
      ],
    );
  }

  openFlashSaleItems(BuildContext context, FlashSale flashsale) {
    context.nextPage(FlashSaleItemsPage(flashsale));
  }
}
