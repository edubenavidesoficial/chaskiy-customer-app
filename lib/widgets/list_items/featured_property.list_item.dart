import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/property.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class FeaturedPropertyListItem extends StatelessWidget {
  const FeaturedPropertyListItem({required this.property, Key? key})
    : super(key: key);

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: VStack([
        CustomImage(
          imageUrl: property.mainPhoto,
          boxFit: BoxFit.cover,
          height: 150,
          width: 250,
        ).box.clip(Clip.antiAlias).rounded.make(),
        10.heightBox,
        property.name.text.maxLines(2).ellipsis.semiBold.make(),
        "${"${AppStrings.currencySymbol} ${property.basePrice}".currencyFormat()} /${"night".tr()}"
            .text
            .gray600
            .make(),
      ]).onTap(() {
        Navigator.pushNamed(
          context,
          AppRoutes.propertyDetailsRoute,
          arguments: property,
        );
      }),
    );
  }
}

class CachedNetworkImage {}
