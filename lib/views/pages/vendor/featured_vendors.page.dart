import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/view_models/vendor/featured_vendors.vm.dart';
import 'package:chaskiy/widgets/custom_easy_refresh_view.dart';
import 'package:chaskiy/widgets/list_items/featured_vendor.list_item.dart';
import 'package:chaskiy/widgets/states/vendor.empty.dart';
import 'package:stacked/stacked.dart';

class FeaturedVendorsPage extends StatelessWidget {
  const FeaturedVendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FeaturedVendorsPageViewModel>.reactive(
      viewModelBuilder: () => FeaturedVendorsPageViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FC),
          appBar: AppBar(
            toolbarHeight: 76,
            elevation: 0,
            foregroundColor: Colors.white,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primaryColor, AppColor.primaryColorDark],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _HeaderButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            title: const Text(
              'Negocios cerca de ti',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21),
            ),
          ),
          body: SafeArea(
            top: false,
            child: CustomEasyRefreshView(
              loading: vm.isBusy,
              dataset: vm.vendors,
              onRefresh: vm.fetchFeaturedVendors,
              onLoad: () => vm.fetchFeaturedVendors(false),
              emptyView: const EmptyVendor(
                description:
                    'No encontramos negocios disponibles en esta zona.',
              ),
              padding: const EdgeInsets.all(16),
              child:
                  vm.vendors.isEmpty
                      ? ListView(
                        padding: const EdgeInsets.only(top: 80),
                        children: const [
                          EmptyVendor(
                            description:
                                'No encontramos negocios disponibles en esta zona.',
                          ),
                        ],
                      )
                      : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                              childAspectRatio: .64,
                            ),
                        itemCount: vm.vendors.length,
                        itemBuilder: (context, index) {
                          final vendor = vm.vendors[index];
                          return FeaturedVendorListItem(
                            vendor: vendor,
                            onPressed: vm.vendorSelected,
                          );
                        },
                      ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.13),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(13),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
