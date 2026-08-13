import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/view_models/order_details.vm.dart';
import 'package:chaskiy/views/pages/order/widgets/order.bottomsheet.dart';
import 'package:chaskiy/views/pages/order/widgets/order_address.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_attachment.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_details_driver_info.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_details_items.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_details_vendor_info.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_payment_info.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_status.view.dart';
import 'package:chaskiy/views/pages/order/widgets/order_details_card.dart';
import 'package:chaskiy/views/pages/order/widgets/order_status_header.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/cards/order_details_summary.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    required this.order,
    this.isOrderTracking = false,
    Key? key,
  }) : super(key: key);

  final Order order;
  final bool isOrderTracking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewModelBuilder<OrderDetailsViewModel>.reactive(
      viewModelBuilder: () => OrderDetailsViewModel(context, order),
      disposeViewModel: true,
      createNewViewModelOnInsert: true,
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Order Details".tr(),
          showAppBar: true,
          showLeadingAction: true,
          isLoading: vm.isBusy,
          elevation: 0,
          //la barra deja de ser un bloque de color y se funde con la pantalla
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          appBarColor: theme.colorScheme.surfaceContainerLow,
          appBarItemColor: theme.colorScheme.onSurface,
          onBackPressed: () => context.pop(vm.order),
          actions:
              vm.order.isPackageDelivery
                  ? [
                    IconButton(
                      onPressed: vm.shareOrderDetails,
                      icon: const Icon(FlutterIcons.share_2_fea, size: 20),
                    ),
                  ]
                  : [],
          body:
              vm.isBusy
                  ? const BusyIndicator().centered()
                  : SmartRefresher(
                    controller: vm.refreshController,
                    onRefresh: vm.fetchOrderDetails,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      //el hueco de abajo es para que el botón de cancelar no
                      //tape la última tarjeta
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children:
                            [
                              // 1. estado, negocio y código
                              OrderStatusHeader(vm: vm),

                              // 2. de dónde sale y a dónde llega
                              if (vm.order.deliveryAddress != null)
                                OrderDetailsCard(
                                  title: "Delivery details".tr(),
                                  child: OrderAddressesView(vm),
                                ),

                              if (!vm.order.isPackageDelivery &&
                                  vm.order.deliveryAddress == null)
                                OrderDetailsCard(
                                  child: Text(
                                    "Customer Order Pickup".tr(),
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),

                              // 3. seguimiento, mientras el pedido siga vivo
                              if (_showTrackingCardView(vm))
                                OrderDetailsCard(
                                  title: "Order Status tracking".tr(),
                                  child: OrderStatusView(vm),
                                ),

                              // 4. qué se pidió
                              OrderDetailsCard(
                                title: _itemsTitle(vm),
                                child: OrderDetailsItemsView(vm),
                              ),

                              // 5. negocio
                              OrderDetailsCard(
                                title:
                                    (!vm.order.isSerice
                                            ? "Vendor"
                                            : "Service Provider")
                                        .tr(),
                                child: OrderDetailsVendorInfoView(vm),
                              ),

                              // 6. conductor, si ya está asignado
                              if (vm.order.driver != null)
                                OrderDetailsCard(
                                  title: "Driver".tr(),
                                  child: OrderDetailsDriverInfoView(vm),
                                ),

                              // 7. nota y adjuntos
                              if (vm.order.note.isNotEmpty)
                                OrderDetailsCard(
                                  title: "Note".tr(),
                                  child: Text(
                                    vm.order.note,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),

                              if (vm.order.attachments != null &&
                                  vm.order.attachments!.isNotEmpty)
                                OrderDetailsCard(
                                  title: "Attachments".tr(),
                                  child: OrderAttachmentView(vm),
                                ),

                              // 8. pago y totales
                              OrderDetailsCard(
                                title: "Order Summary".tr(),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    OrderPaymentInfoView(vm),
                                    OrderDetailsSummary(vm.order),
                                  ],
                                ),
                              ),
                            ].map(_spaced).toList(),
                      ),
                    ),
                  ),
          bottomSheet: isOrderTracking ? null : OrderBottomSheet(vm),
        );
      },
    );
  }

  /// Mismo aire entre todas las tarjetas.
  Widget _spaced(Widget card) =>
      Padding(padding: const EdgeInsets.only(bottom: 12), child: card);

  String _itemsTitle(OrderDetailsViewModel vm) {
    if (vm.order.isPackageDelivery) return "Package Details".tr();
    if (vm.order.isSerice) return "Service".tr();
    return "Products".tr();
  }

  bool _showTrackingCardView(OrderDetailsViewModel vm) {
    return vm.order.status != "delivered" &&
        vm.order.status != "failed" &&
        vm.order.status != "cancelled";
  }
}
