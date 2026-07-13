import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/home_screen.config.dart';
import 'package:chaskiy/constants/sizes.dart';
import 'package:chaskiy/enums/product_fetch_data_type.enum.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/services/alert.service.dart';
import 'package:chaskiy/view_models/welcome.vm.dart';
import 'package:chaskiy/views/pages/vendor/widgets/banners.view.dart';
import 'package:chaskiy/views/pages/vendor/widgets/section_products.view.dart';
import 'package:chaskiy/views/pages/vendor/widgets/section_vendors.view.dart';
import 'package:chaskiy/views/shared/widgets/section_coupons.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:chaskiy/views/pages/welcome/gojek_welcome/widgets/gojek_header.dart';
import 'package:chaskiy/views/pages/welcome/gojek_welcome/widgets/gojek_wallet_card.dart';
import 'package:chaskiy/views/pages/welcome/gojek_welcome/widgets/gojek_services_grid.dart';
import 'package:chaskiy/widgets/states/loading.shimmer.dart';

class GojekWelcomeView extends StatefulWidget {
  const GojekWelcomeView({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;

  @override
  State<GojekWelcomeView> createState() => _GojekWelcomeViewState();
}

class _GojekWelcomeViewState extends State<GojekWelcomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF6F9FE)
              : Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // STEP 3: The custom green header
          SliverToBoxAdapter(
            child: GojekHeader(vm: widget.vm, onLocationTap: _onLocationTap),
          ),

          // The main body with rounded top corners
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GojekWalletCard(),

                // STEP 5: The custom Services Grid
                if (widget.vm.isBusy)
                  const LoadingShimmer().px(20).centered()
                else
                  GojekServicesGrid(vm: widget.vm),

                const SizedBox(height: 20),

                // STEP 6: The remaining sections
                _buildRemainingSections(context),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingSections(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (HomeScreenConfig.showBannerOnHomeScreen &&
            HomeScreenConfig.isBannerPositionTop)
          Banners(null, featured: true, padding: 0).py(4),

        SectionCouponsView(
          null,
          title: "Promo".tr(),
          scrollDirection: Axis.horizontal,
          itemWidth: context.percentWidth * 65,
          height: 90,
          itemsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          bPadding: 0,
        ),

        SectionVendorsView(
          null,
          title: "Featured Vendors".tr(),
          scrollDirection: Axis.horizontal,
          type: SearchFilterType.featured,
          itemWidth: context.percentWidth * 44,
          byLocation: AppStrings.enableFatchByLocation,
          hideEmpty: true,
          titlePadding: const EdgeInsets.symmetric(
            horizontal: Sizes.paddingSizeDefault,
            vertical: 8,
          ),
          itemsPadding: const EdgeInsets.symmetric(
            horizontal: Sizes.paddingSizeDefault,
          ),
        ),

        SectionProductsView(
          null,
          title: "Featured Products".tr(),
          scrollDirection: Axis.horizontal,
          type: ProductFetchDataType.featured,
          itemWidth: context.percentWidth * 42,
          byLocation: AppStrings.enableFatchByLocation,
          hideEmpty: true,
          itemsPadding: const EdgeInsets.fromLTRB(
            Sizes.paddingSizeDefault,
            0,
            Sizes.paddingSizeDefault,
            2,
          ),
          titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // listHeight: context.percentHeight * 18,
          listHeight: 171,
        ),

        if (HomeScreenConfig.showBannerOnHomeScreen &&
            !HomeScreenConfig.isBannerPositionTop)
          Banners(null, featured: true).py(4),
      ],
    );
  }

  Future<void> _onLocationTap() async {
    try {
      widget.vm.pickDeliveryAddress(
        onselected: () {
          widget.vm.pageKey = GlobalKey<State>();
          widget.vm.notifyListeners();
        },
      );
    } catch (error) {
      AlertService.stopLoading();
    }
  }
}
