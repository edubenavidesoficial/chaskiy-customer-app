import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/option.dart';
import 'package:chaskiy/models/option_group.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/widgets/currency_hstack.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class OptionListItem extends StatelessWidget {
  const OptionListItem({
    required this.option,
    required this.optionGroup,
    required this.model,
    Key? key,
  }) : super(key: key);

  final Option option;
  final OptionGroup optionGroup;
  final ProductDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currentCurrencySymbol;
    return HStack([
      //image/photo
      Stack(
        children: [
          //
          CustomImage(
            imageUrl: option.photo,
            width: Vx.dp32,
            height: Vx.dp32,
            canZoom: true,
            hideDefaultImg: true,
          ).card.clip(Clip.antiAlias).roundedSM.make(),

          //
          model.isOptionSelected(option)
              ? Positioned(
                top: 5,
                bottom: 5,
                left: 5,
                right: 5,
                child:
                    Icon(
                      FlutterIcons.check_ant,
                    ).box.color(AppColor.accentColor).roundedSM.make(),
              )
              : UiSpacer.emptySpace(),
        ],
      ),

      //details
      VStack([
        //
        option.name.text.medium.lg.make(),
        if (option.description.isNotEmptyAndNotNull ||
            option.description.isNotNullOrBlank)
          "${option.description}".text.sm
              .maxLines(3)
              .overflow(TextOverflow.ellipsis)
              .make(),
      ]).px12().expand(),

      //price
      CurrencyHStack([
        currencySymbol.text.sm.medium.make(),
        option.price.convertCurrency.currencyValueFormat().text.sm.bold.make(),
      ], crossAlignment: CrossAxisAlignment.end),
    ], crossAlignment: CrossAxisAlignment.center).onInkTap(
      () => model.toggleOptionSelection(optionGroup, option),
    );
  }
}
