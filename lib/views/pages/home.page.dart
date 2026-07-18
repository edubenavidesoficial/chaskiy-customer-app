import 'dart:io';
import 'package:double_back_to_close/double_back_to_close.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/constants/app_upgrade_settings.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/views/pages/profile/profile.page.dart';
import 'package:chaskiy/view_models/home.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:upgrader/upgrader.dart';

import 'order/orders.page.dart';
import 'search/main_search.page.dart';
import 'welcome/widgets/cart.fab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  bool get wantKeepAlive => true;
  late HomeViewModel vm;
  @override
  void initState() {
    super.initState();
    //
    vm = HomeViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (LocationService.currenctAddress == null) {
        LocationService.prepareLocationListener(true);
      }
      vm.initialise();

      // Handle any pending deep links after home page is loaded
      AppService().handlePendingDeepLink();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DoubleBack(
      message: "Press back again to close".tr(),
      child: ViewModelBuilder<HomeViewModel>.reactive(
        viewModelBuilder: () => vm,
        builder: (context, model, child) {
          return BasePage(
            extendBody: true,
            backgroundColor: AppColor.faintBgColor,
            body: UpgradeAlert(
              showIgnore: !AppUpgradeSettings.forceUpgrade(),
              shouldPopScope: () => !AppUpgradeSettings.forceUpgrade(),
              dialogStyle:
                  Platform.isIOS
                      ? UpgradeDialogStyle.cupertino
                      : UpgradeDialogStyle.material,
              upgrader: Upgrader(),
              child: PageView(
                controller: model.pageViewController,
                onPageChanged: model.onPageChanged,
                //disable swipe
                physics: NeverScrollableScrollPhysics(),
                children: [
                  model.homeView,
                  OrdersPage(),
                  MainSearchPage(),
                  ProfilePage(),
                ],
              ),
            ),
            fab: AppUISettings.showCart ? CartHomeFab(model) : null,
            fabLocation:
                AppUISettings.showCart
                    ? FloatingActionButtonLocation.centerDocked
                    : null,
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColor.primaryColor.withValues(alpha: .06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withValues(alpha: 0.13),
                      offset: const Offset(0, 8),
                      blurRadius: 28,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 76,
                  child: Row(
                    children: [
                      _HomeNavItem(
                        index: 0,
                        currentIndex: model.currentIndex,
                        icon: HugeIcons.strokeRoundedHome03,
                        activeIcon: HugeIcons.strokeRoundedHome02,
                        label: "Home".tr(),
                        onTap: model.onTabChange,
                      ),
                      _HomeNavItem(
                        index: 1,
                        currentIndex: model.currentIndex,
                        icon: HugeIcons.strokeRoundedInboxUnread,
                        activeIcon: HugeIcons.strokeRoundedInbox,
                        label: "Orders".tr(),
                        onTap: model.onTabChange,
                      ),
                      if (AppUISettings.showCart) const SizedBox(width: 72),
                      _HomeNavItem(
                        index: 2,
                        currentIndex: model.currentIndex,
                        icon: HugeIcons.strokeRoundedSearch01,
                        activeIcon: HugeIcons.strokeRoundedSearch02,
                        label: "Search".tr(),
                        onTap: model.onTabChange,
                      ),
                      _HomeNavItem(
                        index: 3,
                        currentIndex: model.currentIndex,
                        icon: HugeIcons.strokeRoundedMenu08,
                        activeIcon: HugeIcons.strokeRoundedMenu03,
                        label: "Menu".tr(),
                        onTap: model.onTabChange,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeNavItem extends StatelessWidget {
  const _HomeNavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color =
        isActive
            ? AppColor.primaryColor
            : Theme.of(context).colorScheme.onSurface;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: InkWell(
          onTap: () => onTap(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? AppColor.primaryColor.withValues(alpha: .10)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 23,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
