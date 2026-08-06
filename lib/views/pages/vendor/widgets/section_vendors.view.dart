import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/view_models/vendor/section_vendors.vm.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/horizontal_vendor.list_item.dart';
import 'package:chaskiy/widgets/list_items/vendor.list_item.dart';
import 'package:chaskiy/widgets/section.title.dart';
import 'package:chaskiy/widgets/states/vendor.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionVendorsView extends StatefulWidget {
  const SectionVendorsView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = SearchFilterType.sales,
    this.itemWidth,
    this.viewType,
    this.separator,
    this.byLocation = false,
    this.itemsPadding,
    this.titlePadding,
    this.hideEmpty = false,
    this.onSeeAllPressed,
    //provide your own itembuilder
    this.itemBuilder,
    this.spacer,
    Key? key,
  }) : super(key: key);

  final VendorType? vendorType;
  final Axis scrollDirection;
  final SearchFilterType type;
  final String title;
  final double? itemWidth;
  final dynamic viewType;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final bool hideEmpty;
  final Function? onSeeAllPressed;
  final Widget Function(BuildContext, int, Vendor)? itemBuilder;
  final double? spacer;

  @override
  State<SectionVendorsView> createState() => _SectionVendorsViewState();
}

class _SectionVendorsViewState extends State<SectionVendorsView> {
  //ancho de tarjeta en el carrusel: deja asomar la siguiente
  double _cardWidth(BuildContext context) =>
      widget.itemWidth ?? (context.percentWidth * 50);

  //alto exacto de la tarjeta = banner (16:7.5) + bloque de datos
  double _cardHeight(BuildContext context) =>
      (_cardWidth(context) * 7.5 / 16) + 104;

  @override
  Widget build(BuildContext context) {
    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: ViewModelBuilder<SectionVendorsViewModel>.reactive(
        viewModelBuilder:
            () => SectionVendorsViewModel(
              context,
              widget.vendorType,
              type: widget.type,
              byLocation: widget.byLocation,
            ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          //
          Widget listView = CustomListView(
            scrollDirection: widget.scrollDirection,
            padding:
                widget.itemsPadding ?? EdgeInsets.symmetric(horizontal: 16),
            dataSet: model.vendors,
            isLoading: model.isBusy,
            noScrollPhysics: widget.scrollDirection != Axis.horizontal,
            itemBuilder:
                widget.itemBuilder != null
                    ? (ctx, index) {
                      return widget.itemBuilder!(
                        ctx,
                        index,
                        model.vendors[index],
                      );
                    }
                    : (context, index) {
                      //
                      final vendor = model.vendors[index];
                      //
                      if (widget.viewType != null &&
                          widget.viewType == HorizontalVendorListItem) {
                        return HorizontalVendorListItem(
                          vendor,
                          onPressed: model.vendorSelected,
                        );
                      }
                      //una sola tarjeta para todos los tipos de negocio: la de
                      //comida se dibujaba a 175px y se escalaba con FittedBox,
                      //por eso se veía borrosa y cortada dentro del carrusel
                      return VendorListItem(
                        vendor: vendor,
                        onPressed: model.vendorSelected,
                      ).w(_cardWidth(context));
                    },
            emptyWidget: EmptyVendor(),
            separatorBuilder:
                widget.separator != null
                    ? (ctx, index) => widget.separator!
                    : null,
          );

          //
          return Visibility(
            visible: !widget.hideEmpty || (model.vendors.isNotEmpty),
            child: VStack([
              //
              Visibility(
                visible: widget.title.isNotBlank,
                child: Padding(
                  padding:
                      widget.titlePadding ??
                      const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: HStack([
                    SectionTitle("${widget.title}").expand(),
                    //see all button
                    if (widget.onSeeAllPressed != null)
                      "See more".tr().text.sm.make().onInkTap(() {
                        widget.onSeeAllPressed!();
                      }),
                  ], spacing: 10).wFull(context),
                ),
              ),

              //vendors list
              if (model.vendors.isEmpty)
                listView.h(240).wFull(context)
              else if (widget.scrollDirection == Axis.horizontal)
                //antes era una altura fija de 195 y recortaba la tarjeta
                listView.h(_cardHeight(context)).wFull(context)
              else
                listView.wFull(context),
            ], spacing: widget.spacer ?? 0),
          );
        },
      ),
    );
  }
}
