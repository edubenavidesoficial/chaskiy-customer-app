import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/delivery_address/delivery_addresses_picker.vm.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:chaskiy/widgets/list_items/delivery_address.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class DeliveryAddressPicker extends StatelessWidget {
  const DeliveryAddressPicker({
    required this.onSelectDeliveryAddress,
    this.allowOnMap = false,
    this.vendorCheckRequired = true,
    Key? key,
  }) : super(key: key);

  final Function(DeliveryAddress) onSelectDeliveryAddress;
  final bool allowOnMap;
  final bool vendorCheckRequired;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeliveryAddressPickerViewModel>.reactive(
      viewModelBuilder:
          () => DeliveryAddressPickerViewModel(
            context,
            onSelectDeliveryAddress,
            vendorCheckRequired,
          ),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return VStack([
              UiSpacer.swipeIndicator().py8(),
              HStack([
                VStack([
                  "Dirección de entrega".text.xl.bold.make(),
                  "Selecciona dónde recibir tu pedido".text.sm
                      .color(context.theme.colorScheme.onSurfaceVariant)
                      .make(),
                ]).expand(),
                AuthServices.authenticated()
                    ? CustomButton(
                      title: "Nueva",
                      icon: FlutterIcons.plus_ant,
                      onPressed: vm.newDeliveryAddressPressed,
                    )
                    : UiSpacer.emptySpace(),
              ]).px20().py12(),
              CustomTextFormField(
                hintText: "Buscar dirección",
                prefixIcon: Icon(FlutterIcons.search_fea, size: 20),
                onChanged: vm.filterResult,
              ).px20().py8(),
              if (vm.isBusy)
                const Center(child: CircularProgressIndicator()).expand()
              else if (vm.deliveryAddresses.isEmpty)
                Center(
                  child: VStack(
                    [
                      Icon(
                        Icons.location_on_outlined,
                        size: 42,
                        color: context.theme.colorScheme.primary,
                      ),
                      "No tienes direcciones guardadas".text.lg.bold.center
                          .make(),
                      "Elige una ubicación en el mapa para continuar".text
                          .color(context.theme.colorScheme.onSurfaceVariant)
                          .center
                          .make(),
                    ],
                    spacing: 8,
                    crossAlignment: CrossAxisAlignment.center,
                  ),
                ).px24().expand()
              else
                SafeArea(
                  top: false,
                  child: CustomListView(
                    dataSet: vm.deliveryAddresses,
                    isLoading: false,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final deliveryAddress = vm.deliveryAddresses[index];
                      return DeliveryAddressListItem(
                        deliveryAddress: deliveryAddress,
                        action: false,
                        borderColor: Colors.transparent,
                      ).onInkTap(
                        (deliveryAddress.can_deliver == null ||
                                deliveryAddress.can_deliver!)
                            ? () => onSelectDeliveryAddress(deliveryAddress)
                            : null,
                      );
                    },
                    separatorBuilder:
                        (context, index) => UiSpacer.verticalSpace(space: 8),
                  ),
                ).expand(),
              allowOnMap
                  ? SafeArea(
                    child:
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            alignment: Alignment.center,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          label: "Elegir en el mapa".text.bold.make(),
                          icon: Icon(FlutterIcons.location_pin_ent),
                          onPressed: vm.pickFromMap,
                        ).wFull(context).px20(),
                  )
                  : UiSpacer.emptySpace(),
            ]).box
            .color(context.theme.colorScheme.surface)
            .topRounded()
            .clip(Clip.antiAlias)
            .make()
            .h(context.percentHeight * 78);
      },
    );
  }
}
