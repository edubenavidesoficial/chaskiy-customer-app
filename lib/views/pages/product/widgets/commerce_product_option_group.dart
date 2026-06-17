import 'package:flutter/material.dart';
import 'package:chaskiy/models/option_group.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/widgets/list_items/commerce_option.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class CommerceProductOptionGroup extends StatelessWidget {
  const CommerceProductOptionGroup({
    required this.optionGroup,
    required this.model,
    Key? key,
  }) : super(key: key);

  final OptionGroup optionGroup;
  final ProductDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //group name
        "${optionGroup.name}".text.lg.semiBold.make(),
        Visibility(
          visible: optionGroup.maxOptions != null,
          child: ("Max Selection: ".tr() + "${optionGroup.maxOptions}")
              .text
              .sm
              .make(),
        ),
        UiSpacer.vSpace(6),

        //options
        Wrap(
          children: optionGroup.options.map(
            (e) {
              return CommerceOptionListItem(
                option: e,
                optionGroup: optionGroup,
                model: model,
              );
            },
          ).toList(),
        ),
      ],
    ).px20().py12();
  }
}
