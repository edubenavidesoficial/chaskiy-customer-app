import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/delivery_address/delivery_addresses.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/list_items/delivery_address.list_item.dart';
import 'package:chaskiy/widgets/states/delivery_address.empty.dart';
import 'package:chaskiy/widgets/states/error.state.dart';
import 'package:chaskiy/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';

class DeliveryAddressesPage extends StatelessWidget {
  const DeliveryAddressesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeliveryAddressesViewModel>.reactive(
      viewModelBuilder: () => DeliveryAddressesViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Delivery Addresses".tr(),
          isLoading: vm.isBusy,
          body: _body(context, vm),
          bottomNavigationBar: _addAddressButton(context, vm),
        );
      },
    );
  }

  Widget _body(BuildContext context, DeliveryAddressesViewModel vm) {
    if (vm.busy(vm.deliveryAddresses)) {
      return LoadingShimmer();
    }
    // sin esto, un fallo al cargar se mostraba como "no hay direcciones"
    if (vm.hasError) {
      return LoadingError(onrefresh: vm.fetchDeliveryAddresses);
    }
    if (vm.deliveryAddresses.isEmpty) {
      return EmptyDeliveryAddress();
    }

    final defaultAddresses =
        vm.deliveryAddresses
            .where((address) => address.defaultDeliveryAddress)
            .toList();
    final otherAddresses =
        vm.deliveryAddresses
            .where((address) => !address.defaultDeliveryAddress)
            .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        if (defaultAddresses.isNotEmpty)
          _section(context, vm, "Delivery Address".tr(), defaultAddresses),
        if (otherAddresses.isNotEmpty)
          _section(context, vm, "Other addresses".tr(), otherAddresses),
      ],
    );
  }

  Widget _section(
    BuildContext context,
    DeliveryAddressesViewModel vm,
    String title,
    List<DeliveryAddress> addresses,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 18, bottom: 6),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        //cada dirección va separada por una línea suave
        for (int index = 0; index < addresses.length; index++) ...[
          if (index > 0)
            Divider(
              height: 1,
              thickness: 1,
              color: theme.colorScheme.outlineVariant.withOpacity(.45),
            ),
          _tile(vm, addresses[index]),
        ],
      ],
    );
  }

  Widget _tile(DeliveryAddressesViewModel vm, DeliveryAddress address) {
    return DeliveryAddressListItem(
      deliveryAddress: address,
      border: false,
      onEditPressed: () => vm.editDeliveryAddress(address),
      onDeletePressed: () => vm.deleteDeliveryAddress(address),
    );
  }

  Widget _addAddressButton(
    BuildContext context,
    DeliveryAddressesViewModel vm,
  ) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        height: 54,
        child: FilledButton.icon(
          onPressed: vm.newDeliveryAddressPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColor.primaryColor,
            foregroundColor: Utils.textColorByColor(AppColor.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text(
            "Add address".tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
