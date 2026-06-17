import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/delivery_address/delivery_addresses.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/delivery_address.list_item.dart';
import 'package:chaskiy/widgets/states/delivery_address.empty.dart';
import 'package:chaskiy/widgets/states/error.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

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
          fab: FloatingActionButton(
            backgroundColor: AppColor.primaryColor,
            child: Icon(
              FlutterIcons.plus_ant,
              color: Colors.white,
            ),
            onPressed: vm.newDeliveryAddressPressed,
          ),
          body: CustomListView(
            padding:
                EdgeInsets.fromLTRB(20, 20, 20, context.percentHeight * 20),
            dataSet: vm.deliveryAddresses,
            isLoading: vm.busy(vm.deliveryAddresses),
            emptyWidget: EmptyDeliveryAddress(),
            errorWidget: LoadingError(
              onrefresh: vm.fetchDeliveryAddresses,
            ),
            itemBuilder: (context, index) {
              //
              final deliveryAddress = vm.deliveryAddresses[index];
              //
              return DeliveryAddressListItem(
                deliveryAddress: deliveryAddress,
                onEditPressed: () => vm.editDeliveryAddress(deliveryAddress),
                onDeletePressed: () =>
                    vm.deleteDeliveryAddress(deliveryAddress),
              );
            },
            separatorBuilder: (context, index) =>
                UiSpacer.verticalSpace(space: 10),
          ),
        );
      },
    );
  }
}
