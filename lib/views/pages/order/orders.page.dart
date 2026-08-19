import 'package:flutter/material.dart';
import 'package:chaskiy/services/order.service.dart';
import 'package:chaskiy/view_models/orders.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/list_items/order.list_item.dart';
import 'package:chaskiy/widgets/list_items/order_booking.list_item.dart';
import 'package:chaskiy/widgets/list_items/taxi_order.list_item.dart';
import 'package:chaskiy/widgets/states/empty.state.dart';
import 'package:chaskiy/widgets/states/error.state.dart';
import 'package:chaskiy/widgets/states/order.empty.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with AutomaticKeepAliveClientMixin<OrdersPage>, WidgetsBindingObserver {
  //
  late OrdersViewModel vm;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm.fetchMyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    vm = OrdersViewModel(context);
    super.build(context);
    final theme = Theme.of(context);

    return BasePage(
      allowTopSafeArea: true,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      body: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => vm,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack([
            //
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "My Orders".tr(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vm.orders.isEmpty
                              ? 'Compras y viajes en un solo lugar'.tr()
                              : '${vm.orders.length} ${vm.orders.length == 1 ? 'pedido' : 'pedidos'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar'.tr(),
                    onPressed: vm.isBusy ? null : vm.fetchMyOrders,
                    icon: const Icon(Icons.refresh_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                ],
              ),
            ),
            //
            if (vm.isAuthenticated())
              CustomListView(
                canPullUp: true,
                canRefresh: true,
                refreshController: vm.refreshController,
                onRefresh: () => vm.fetchMyOrders(),
                onLoading: () => vm.fetchMyOrders(initialLoading: false),
                dataSet: vm.orders,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                emptyWidget: EmptyOrder(),
                //si la consulta falla se veía "Sin pedidos", igual que si de
                //verdad no hubiera ninguno
                hasError: vm.hasError,
                errorWidget: LoadingError(
                  onrefresh: vm.fetchMyOrders,
                  description: "${vm.modelError ?? ''}",
                ),
                separatorBuilder: (_, index) => 12.heightBox,
                isLoading: vm.isBusy,
                itemBuilder: (context, index) {
                  final order = vm.orders[index];
                  //for taxi tye of order
                  if (order.taxiOrder != null) {
                    return TaxiOrderListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                    );
                  } else if (order.isBooking) {
                    return OrderBookingListItem(
                      order: order,
                      orderPressed: () => vm.openOrderDetails(order),
                      onPayPressed:
                          () => OrderService.openOrderPayment(order, vm),
                    );
                  }
                  return OrderListItem(
                    order: order,
                    orderPressed: () => vm.openOrderDetails(order),
                    onPayPressed:
                        () => OrderService.openOrderPayment(order, vm),
                  );
                },
              ).expand(),

            if (!vm.isAuthenticated())
              EmptyState(
                auth: true,
                showAction: true,
                actionPressed: vm.openLogin,
              ).py12().centered().expand(),
          ]);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
