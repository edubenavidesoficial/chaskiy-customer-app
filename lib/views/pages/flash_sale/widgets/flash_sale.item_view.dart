import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/services/app_currency_system.service.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class FlashSaleItemListItem extends StatelessWidget {
  const FlashSaleItemListItem(this.product, {this.fullPage = false, Key? key})
    : super(key: key);

  final Product product;
  final bool fullPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageHeight =
        fullPage ? (context.percentHeight * 18) : (context.percentWidth * 28);

    return SizedBox(
      width: context.percentWidth * 42,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(.10),
        child: InkWell(
          onTap:
              () => context.nextPage(
                NavigationService().productDetailsPageWidget(product),
              ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImage(
                imageUrl: product.photo,
                width: double.infinity,
                height: imageHeight,
                boxFit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${product.name}",
                      maxLines: fullPage ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${AppStrings.currentCurrencySymbol}"
                      "${product.sellPrice.convertCurrency.currencyValueFormat()}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                        color: AppColor.primaryColor,
                      ),
                    ),
                    //stock restante, solo si el servidor lo informa
                    if (product.availableQty != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "%s items left".tr().fill([product.availableQty]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColor.closeColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
