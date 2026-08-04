import 'package:flutter/material.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/main_search.vm.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/custom_masonry_grid_view.dart';
import 'package:chaskiy/widgets/list_items/dynamic_vendor.list_item.dart';
import 'package:chaskiy/widgets/list_items/featured_vendor.list_item.dart';
import 'package:chaskiy/widgets/states/search.empty.dart';
// import 'package:velocity_x/velocity_x.dart';

class VendorSearchResultView extends StatefulWidget {
  VendorSearchResultView(this.vm, {Key? key}) : super(key: key);

  final MainSearchViewModel vm;
  @override
  State<VendorSearchResultView> createState() => _VendorSearchResultViewState();
}

class _VendorSearchResultViewState extends State<VendorSearchResultView> {
  @override
  Widget build(BuildContext context) {
    final refreshController = widget.vm.refreshControllers[0];
    //
    return (widget.vm.search?.layoutType == null ||
            widget.vm.search?.layoutType == "grid")
        ? CustomMasonryGridView(
            padding: EdgeInsets.symmetric(vertical: 12),
            refreshController: refreshController,
            canPullUp: true,
            canRefresh: true,
            onRefresh: widget.vm.searchVendors,
            onLoading: () => widget.vm.searchVendors(initial: false),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            isLoading: widget.vm.busy(widget.vm.vendors),
            emptyWidget: EmptySearch(type: "vendor"),
            items: [
              ...(widget.vm.vendors.map(
                (vendor) {
                  // en cuadrícula se usa la tarjeta compacta de grid;
                  // AspectRatio le da el alto que el masonry no acota
                  return AspectRatio(
                    aspectRatio: .62,
                    child: FeaturedVendorListItem(
                      vendor: vendor,
                      onPressed: widget.vm.vendorSelected,
                    ),
                  );
                },
              ).toList()),
            ],
            // dataSet: widget.vm.vendors,
            // itemBuilder: (ctx, index) {
            //   final vendor = widget.vm.vendors[index];
            //   return FittedBox(
            //     child: DynamicVendorListItem(
            //       vendor,
            //       onPressed: widget.vm.vendorSelected,
            //       width: context.percentWidth * 48,
            //     ),
            //   );
            // },
          )
        : CustomListView(
            padding: EdgeInsets.symmetric(vertical: 12),
            refreshController: refreshController,
            canPullUp: true,
            canRefresh: true,
            onRefresh: widget.vm.searchVendors,
            onLoading: () => widget.vm.searchVendors(initial: false),
            dataSet: widget.vm.vendors,
            isLoading: widget.vm.busy(widget.vm.vendors),
            emptyWidget: EmptySearch(type: "vendor"),
            itemBuilder: (ctx, index) {
              final vendor = widget.vm.vendors[index];
              return DynamicVendorListItem(
                vendor,
                onPressed: widget.vm.vendorSelected,
                width: double.infinity,
              );
            },
            separatorBuilder: (p0, p1) => UiSpacer.vSpace(10),
          );
  }
}
