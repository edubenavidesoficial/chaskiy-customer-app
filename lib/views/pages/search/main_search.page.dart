import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/main_search.vm.dart';
import 'package:chaskiy/views/pages/search/widget/property_search_result.view.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/states/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';

import 'widget/product_search_result.view.dart';
import 'widget/search.header.dart';
import 'widget/service_search_result.view.dart';
import 'widget/vendor_search_result.view.dart';

class MainSearchPage extends StatelessWidget {
  const MainSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainSearchViewModel>.reactive(
      viewModelBuilder: () => MainSearchViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          allowTopSafeArea: true,
          body: VStack([
            //header
            UiSpacer.verticalSpace(),
            SearchHeader(vm, showCancel: false),
            //if by location is enabled and results are empty, show a disclaimer
            Visibility(
              visible:
                  (vm.search?.byLocation ?? true) &&
                  vm.searchResults.isEmpty &&
                  !vm.isBusy,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: HStack([
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColor.primaryColor,
                    size: 14,
                  ),
                  6.widthBox,
                  "Resultados según tu ubicación · ajústalo en filtros"
                      .text
                      .size(12)
                      .color(AppColor.primaryColor)
                      .maxLines(1)
                      .overflow(TextOverflow.ellipsis)
                      .make()
                      .expand(),
                ], crossAlignment: CrossAxisAlignment.center),
              ).py(4),
            ),
            //tab-
            LoadingIndicator(
              loading: vm.isBusy,
              child: Theme(
                // apaga la línea divisoria inferior del TabBar (Material 3)
                data: context.theme.copyWith(
                  tabBarTheme: context.theme.tabBarTheme.copyWith(
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                  ),
                ),
                child: ContainedTabBarView(
                    callOnChangeWhileIndexIsChanging: true,
                    tabBarProperties: TabBarProperties(
                      height: 46,
                      margin: const EdgeInsets.only(top: 2, bottom: 10),
                      alignment: TabBarAlignment.start,
                      isScrollable: true,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      // contenedor "glass" translúcido estilo iOS
                      background: Container(
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.onSurface
                              .withOpacity(.05),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: context.theme.colorScheme.onSurface
                                .withOpacity(.06),
                          ),
                        ),
                      ),
                      labelColor: AppColor.primaryColor,
                      unselectedLabelColor: context
                          .theme.colorScheme.onSurface
                          .withOpacity(.55),
                      labelStyle: context.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      unselectedLabelStyle:
                          context.textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      // pill flotante de la pestaña activa
                      indicatorPadding: const EdgeInsets.all(4),
                      indicator: BoxDecoration(
                        color: context.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.14),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    tabs: [
                      //
                      if (vm.showVendors)
                        Tab(child: "Vendors".tr().text.make()),
                      //
                      if (vm.showProducts)
                        Tab(child: "Products".tr().text.make()),
                      //
                      if (vm.showServices)
                        Tab(child: "Services".tr().text.make()),
                      if (vm.showProperties)
                        Tab(child: "Properties".tr().text.make()),
                    ],
                    views: [
                      if (vm.showVendors) VendorSearchResultView(vm),
                      //
                      if (vm.showProducts) ProductSearchResultView(vm),
                      //
                      if (vm.showServices) ServiceSearchResultView(vm),
                      //
                      if (vm.showProperties) PropertySearchResultView(vm),
                    ],
                    // onChange: vm.onTabChange,
                  ),
              ).expand(),
            ),
          ]).px(16),
        );
      },
    );
  }
}
