import 'package:flutter/material.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/search.vm.dart';
import 'package:chaskiy/views/pages/search/widget/search.header.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/grid_view_service.list_item.dart';
import 'package:chaskiy/widgets/list_items/horizontal_product.list_item.dart';
import 'package:chaskiy/widgets/states/search.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorSearchPage extends StatelessWidget {
  const VendorSearchPage(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchViewModel>.reactive(
      viewModelBuilder: () => SearchViewModel(
        context,
        Search(
          vendorId: vendor.id,
          vendorType: vendor.vendorType.isService ? vendor.vendorType : null,
          type: vendor.vendorType.isService ? 'service' : 'product',
        ),
      ),
      onViewModelReady: (vm) => vm.startSearch(),
      builder: (context, model, child) {
        return BasePage(
          showCartView: true,
          body: SafeArea(
            bottom: false,
            child: VStack(
              [
                //header
                SearchHeader(
                  model,
                  subtitle: "",
                  showCancel: true,
                ),

                //Busy loading
                model.isBusy
                    ? BusyIndicator().centered()
                    : UiSpacer.emptySpace(),

                //products
                CustomListView(
                  refreshController: model.refreshController,
                  canRefresh: true,
                  canPullUp: true,
                  onRefresh: model.startSearch,
                  onLoading: () => model.startSearch(initialLoaoding: false),
                  isLoading: model.isBusy,
                  dataSet: model.searchResults,
                  itemBuilder: (context, index) {
                    //
                    final searchResult = model.searchResults[index];
                    if (searchResult is Product) {
                      return HorizontalProductListItem(
                        searchResult,
                        onPressed: model.productSelected,
                        qtyUpdated: model.addToCartDirectly,
                      );
                    } else {
                      return GridViewServiceListItem(
                        service: searchResult,
                        onPressed: model.servicePressed,
                      );
                    }
                  },
                  separatorBuilder: (context, index) =>
                      UiSpacer.verticalSpace(space: 0),
                  emptyWidget: EmptySearch(),
                ).py12().expand(),
              ],
            ).pOnly(
              top: Vx.dp16,
              left: Vx.dp16,
              right: Vx.dp16,
            ),
          ),
        );
      },
    );
  }
}
