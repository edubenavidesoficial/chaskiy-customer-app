import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/sizes.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/booking.vm.dart';
import 'package:chaskiy/views/pages/vendor/widgets/banners.view.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/featured_property.list_item.dart';
import 'package:chaskiy/widgets/list_items/property.list_item.dart';
import 'package:chaskiy/widgets/list_items/property_type.list_item.dart';
import 'package:chaskiy/widgets/states/alternative.view.dart';
import 'package:chaskiy/widgets/states/loading.shimmer.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class BookingPage extends StatefulWidget {
  const BookingPage(this.vendorType, {Key? key}) : super(key: key);

  final VendorType vendorType;
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with AutomaticKeepAliveClientMixin<BookingPage> {
  GlobalKey pageKey = GlobalKey<State>();
  bool showBannersView = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final primaryThemeColor = Utils.textColorByPrimaryColor();
    return ViewModelBuilder<BookingViewModel>.reactive(
      viewModelBuilder: () => BookingViewModel(context, widget.vendorType),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          key: pageKey,
          backgroundColor: context.theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: context.primaryColor,
            elevation: 0,
            automaticallyImplyLeading: !AppStrings.isSingleVendorMode,
            leading:
                !AppStrings.isSingleVendorMode
                    ? IconButton(
                      icon: Icon(
                        !Utils.isArabic
                            ? FlutterIcons.arrow_left_fea
                            : FlutterIcons.arrow_right_fea,
                        color: primaryThemeColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    )
                    : null,
            title:
                widget.vendorType.name.text
                    .color(primaryThemeColor)
                    .semiBold
                    .make(),
            centerTitle: true,
          ),
          body: SmartRefresher(
            controller: model.refreshController,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: model.onRefresh,
            onLoading: model.onLoadMore,
            child: VStack([
              // Encabezado flexible: evita desbordamientos en pantallas angostas.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descubre tu próxima estadía',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: primaryThemeColor,
                        fontWeight: FontWeight.w800,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Material(
                      color: context.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 3,
                      shadowColor: Colors.black26,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap:
                            () => Navigator.pushNamed(
                              context,
                              AppRoutes.propertySearchRoute,
                              arguments: widget.vendorType,
                            ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: context.primaryColor.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: context.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¿A dónde?',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Cualquier lugar · Cualquier fecha · Huéspedes',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color:
                                            context
                                                .theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.tune_rounded),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Banners
              if (showBannersView)
                Banners(
                  model.vendorType,
                  onEmpty: () {
                    if (mounted) {
                      setState(() {
                        showBannersView = false;
                      });
                    }
                  },
                ).py(10),

              // Featured properties
              if (!model.busy(model.featuredProperties) &&
                  model.featuredProperties.isNotEmpty)
                LoadingShimmer(
                  loading: model.busy(model.featuredProperties),
                  child: VStack([
                    "Featured".tr().text.xl.bold.make().px16(),
                    10.heightBox,
                    HStack(
                      [
                        ...model.featuredProperties.map((property) {
                          return FeaturedPropertyListItem(property: property);
                        }).toList(),
                      ],
                      spacing: Sizes.paddingSizeDefault,
                      alignment: MainAxisAlignment.start,
                      crossAlignment: CrossAxisAlignment.start,
                    ).px(Sizes.paddingSizeDefault).scrollHorizontal(),
                  ]),
                ).py(10),

              // Property Types (Categories)
              LoadingShimmer(
                loading: model.busy(model.propertyTypes),
                child: AlternativeView(
                  ismain: model.propertyTypes.isNotEmpty,
                  main: HStack(
                        model.propertyTypes.map((type) {
                          return PropertyTypeListItem(
                            propertyType: type,
                            isSelected:
                                model.selectedPropertyType?.id == type.id,
                            onPressed: model.onPropertyTypeSelected,
                          );
                        }).toList(),
                        spacing: Sizes.paddingSizeDefault,
                      )
                      .px(Sizes.paddingSizeDefault)
                      .scrollHorizontal(
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.paddingSizeDefault,
                          vertical: 12,
                        ),
                      ),
                  alt: VStack([
                    Icon(Icons.error, color: Colors.red, size: 50),
                    "No Property Type Found".tr().text.makeCentered(),
                  ], crossAlignment: CrossAxisAlignment.center).p(20),
                ),
              ),

              // Properties List
              LoadingShimmer(
                loading: model.busy(model.properties),
                child: CustomListView(
                  dataSet: model.properties,
                  noScrollPhysics: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.paddingSizeDefault,
                  ),
                  itemBuilder: (context, index) {
                    return PropertyListItem(property: model.properties[index]);
                  },
                  emptyWidget:
                      (!model.isBusy &&
                              !model.busy(model.propertyTypes) &&
                              !model.busy(model.properties) &&
                              model.properties.isEmpty)
                          ? Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: context
                                  .theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(.55),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  HugeIcons.strokeRoundedHouse01,
                                  size: 52,
                                  color: context.primaryColor,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Aún no hay propiedades',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Prueba otra categoría o ajusta tu búsqueda.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color:
                                        context
                                            .theme
                                            .colorScheme
                                            .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : 0.heightBox,
                ),
              ),
            ], spacing: Sizes.paddingSizeDefault),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
