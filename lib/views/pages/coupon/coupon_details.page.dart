import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/coupon.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/services/toast.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/coupons.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/vendor_details.page.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/dynamic_product.list_item.dart';
import 'package:chaskiy/widgets/list_items/vendor.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CouponDetailsPage extends StatelessWidget {
  const CouponDetailsPage(this.coupon, {Key? key}) : super(key: key);

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    Color bgColor = coupon.color != null
        ? Vx.hexToColor(coupon.color!)
        : AppColor.primaryColor;
    Color textColor = Utils.textColorByColor(bgColor);
    //
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      extendBodyBehindAppBar: true,
      elevation: 0,
      appBarColor: bgColor,
      actions: [
        IconButton(
          onPressed: () async {
            try {
              await Clipboard.setData(
                ClipboardData(
                  text: coupon.code,
                ),
              );
              //
              ToastService.toastSuccessful("Copied to clipboard".tr());
            } catch (error) {
              ToastService.toastError("$error");
            }
          },
          icon: Icon(FlutterIcons.copy_fea),
        ),
      ],
      body: ViewModelBuilder<CouponsViewModel>.reactive(
        viewModelBuilder: () => CouponsViewModel(context, null, coupon: coupon),
        onViewModelReady: (vm) => vm.fetchCouponDetails(),
        builder: (context, vm, child) {
          //
          return VStack(
            [
              //header
              VStack(
                [
                  "${vm.coupon?.code}"
                      .text
                      .xl3
                      .extraBlack
                      .color(textColor)
                      .makeCentered(),
                  "${vm.coupon?.description}"
                      .text
                      .sm
                      .medium
                      .color(textColor)
                      .makeCentered(),
                  UiSpacer.vSpace(),
                ],
              ).wFull(context).px(10).safeArea().box.color(bgColor).make(),

              VStack(
                [
                  Visibility(
                    visible: vm.coupon!.products.isNotEmpty,
                    child: "Products".tr().text.semiBold.xl.make().py(10),
                  ),
                  //vendor/products
                  CustomListView(
                    noScrollPhysics: true,
                    padding: EdgeInsets.zero,
                    isLoading: vm.busy(vm.coupon),
                    dataSet: vm.coupon!.products,
                    separatorBuilder: ((p0, p1) => UiSpacer.vSpace(0)),
                    itemBuilder: (context, index) {
                      final product = vm.coupon!.products[index];
                      return DynamicProductListItem(
                        product,
                        onPressed: (product) {
                          //
                          final page = NavigationService()
                              .productDetailsPageWidget(product);
                          context.nextPage(page);
                        },
                      );
                    },
                    emptyWidget:
                        "Coupon can be use with most products without restrictions"
                            .tr()
                            .text
                            .lg
                            .thin
                            .center
                            .makeCentered(),
                  ),

                  UiSpacer.vSpace(),
                  Visibility(
                    visible: vm.coupon!.vendors.isNotEmpty,
                    child: "Vendors".tr().text.semiBold.xl.make().py(10),
                  ),
                  CustomListView(
                    noScrollPhysics: true,
                    padding: EdgeInsets.zero,
                    isLoading: vm.busy(vm.coupon),
                    dataSet: vm.coupon!.vendors,
                    separatorBuilder: ((p0, p1) => UiSpacer.vSpace(0)),
                    itemBuilder: (context, index) {
                      final vendor = vm.coupon!.vendors[index];
                      return VendorListItem(
                        vendor: vendor,
                        onPressed: (vendor) {
                          context.nextPage(VendorDetailsPage(vendor: vendor));
                        },
                      );
                    },
                    emptyWidget:
                        "Coupon can be use with most vendors without restrictions"
                            .tr()
                            .text
                            .lg
                            .thin
                            .center
                            .makeCentered(),
                  ),
                ],
                crossAlignment: CrossAxisAlignment.start,
                alignment: MainAxisAlignment.start,
              ).p16().scrollVertical().expand(),
            ],
          );
        },
      ),
    );
  }
}
