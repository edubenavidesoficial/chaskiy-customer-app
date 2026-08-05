import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/product_review.vm.dart';
import 'package:chaskiy/views/pages/product/widgets/amazon/product_review_sumup.view.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/product_review.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class AmazonCustomerProductReview extends StatelessWidget {
  const AmazonCustomerProductReview({required this.product, Key? key})
    : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductReviewViewModel>.reactive(
      viewModelBuilder: () => ProductReviewViewModel(context, product, true),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return VStack([
          //resumen de la valoración (abre el listado completo)
          ProductReviewSumupView(product).onInkTap(vm.openAllReviews),

          //reseñas recientes
          CustomVisibilty(
            visible: vm.productReviews.isNotEmpty,
            child: VStack([
              UiSpacer.vSpace(6),
              CustomListView(
                noScrollPhysics: true,
                isLoading: vm.busy(vm.productReviews),
                dataSet: vm.productReviews,
                itemBuilder: (ctx, index) {
                  final productReview = vm.productReviews[index];
                  return ProductReviewListItem(productReview);
                },
              ),
              UiSpacer.vSpace(6),
              _seeAllButton(context, vm),
            ]),
          ),
        ]);
      },
    );
  }

  Widget _seeAllButton(BuildContext context, ProductReviewViewModel vm) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColor.primaryColor.withOpacity(.5)),
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: vm.openAllReviews,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "See all reviews".tr(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Utils.isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 20,
                color: AppColor.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
