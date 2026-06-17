import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/view_models/vendor/section_vendors.vm.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:chaskiy/widgets/list_items/featured_vendor.list_item.dart';
import 'package:chaskiy/widgets/lists/custom_horizonatal.listview.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FeaturedVendorsView extends StatelessWidget {
  const FeaturedVendorsView({
    this.title,
    this.scrollDirection = Axis.vertical,
    this.itemWidth,
    this.hideEmpty = false,
    this.onSeeAllPressed,
    this.titlePadding,
    this.listViewPadding,
    this.onVendorSelected,
    Key? key,
  }) : super(key: key);

  final Axis scrollDirection;
  final String? title;
  final double? itemWidth;
  final bool hideEmpty;
  final Function? onSeeAllPressed;
  final EdgeInsets? titlePadding;
  final EdgeInsets? listViewPadding;
  final Function(Vendor)? onVendorSelected;

  @override
  Widget build(BuildContext context) {
    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: ViewModelBuilder<SectionVendorsViewModel>.reactive(
        viewModelBuilder: () => SectionVendorsViewModel(
          context,
          null,
          type: SearchFilterType.featured,
          byLocation: false,
        ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          return VStack(
            [
              //title
              Visibility(
                visible: title != null && title!.isNotBlank,
                child: Padding(
                  padding: titlePadding ?? Vx.mSymmetric(v: 10, h: 20),
                  child: HStack(
                    [
                      "$title".text.lg.medium.make().expand(),
                      //see all button
                      if (onSeeAllPressed != null)
                        "See more".tr().text.sm.make().onInkTap(
                          () {
                            onSeeAllPressed!();
                          },
                        ),
                    ],
                    spacing: 10,
                  ).wFull(context),
                ),
              ),
              //content list
              if (scrollDirection == Axis.horizontal)
                CustomHScrollView(
                  itemCount: model.vendors.length,
                  isLoading: model.isBusy,
                  itemWidth: itemWidth ?? (context.percentWidth * 55),
                  padding: listViewPadding,
                  itemSpacing: 20,
                  hideEmpty: hideEmpty,
                  itemBuilder: (context, index) {
                    final vendor = model.vendors[index];
                    return FeaturedVendorListItem(
                      vendor: vendor,
                      onPressed: (vendor) {
                        if (onVendorSelected != null) {
                          onVendorSelected!(vendor);
                        }
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
