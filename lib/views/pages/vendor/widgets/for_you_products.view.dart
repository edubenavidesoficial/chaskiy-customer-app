import 'package:flutter/material.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/vendor/for_you_products.vm.dart';
import 'package:chaskiy/widgets/custom_dynamic_grid_view.dart';
import 'package:chaskiy/widgets/list_items/commerce_product.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ForYouProducts extends StatelessWidget {
  const ForYouProducts(
    this.vendorType, {
    this.imageHeight,
    Key? key,
  }) : super(key: key);

  final VendorType vendorType;
  final double? imageHeight;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForYouProductsViewModel>.reactive(
      viewModelBuilder: () => ForYouProductsViewModel(context, vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return VStack(
          [
            //
            "For You".tr().text.make().px12().py2(),
            CustomDynamicHeightGridView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 2),
              separatorBuilder: (context, index) =>
                  UiSpacer.smHorizontalSpace(),
              itemCount: model.products.length,
              isLoading: model.isBusy,
              noScrollPhysics: true,
              itemBuilder: (context, index) {
                //
                return CommerceProductListItem(
                  model.products[index],
                  height: imageHeight ?? 80,
                  // onPressed: model.productSelected,
                  // qtyUpdated: model.addToCartDirectly,
                );
              },
            ).px12().py2(),
          ],
        );
      },
    );
  }
}
