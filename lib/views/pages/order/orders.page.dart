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
      backgroundColor: theme.colorScheme.surface,
      body: ViewModelBuilder<OrdersViewModel>.reactive(
        viewModelBuilder: () => vm,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return VStack([
            //
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        "My Orders".tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vm.orders.isEmpty
                            ? 'Compras y viajes en un solo lugar'.tr()
                            : vm.hasActiveFilters
                            ? '${vm.filteredOrders.length} de ${vm.orders.length} pedidos'
                            : '${vm.orders.length} ${vm.orders.length == 1 ? 'pedido' : 'pedidos'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: 'Actualizar'.tr(),
                      onPressed: vm.isBusy ? null : vm.fetchMyOrders,
                      icon: const Icon(Icons.refresh_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: theme.colorScheme.onSurface,
                        minimumSize: const Size(46, 46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (vm.isAuthenticated()) _OrderFilters(vm: vm),
            //
            if (vm.isAuthenticated())
              CustomListView(
                canPullUp: true,
                canRefresh: true,
                refreshController: vm.refreshController,
                onRefresh: () => vm.fetchMyOrders(),
                onLoading: () => vm.fetchMyOrders(initialLoading: false),
                dataSet: vm.filteredOrders,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                emptyWidget: EmptyOrder(),
                //si la consulta falla se veía "Sin pedidos", igual que si de
                //verdad no hubiera ninguno
                hasError: vm.hasError,
                errorWidget: LoadingError(
                  onrefresh: vm.fetchMyOrders,
                  description: "${vm.modelError ?? ''}",
                ),
                separatorBuilder: (_, index) => 18.heightBox,
                isLoading: vm.isBusy,
                itemBuilder: (context, index) {
                  final order = vm.filteredOrders[index];
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

class _OrderFilters extends StatelessWidget {
  const _OrderFilters({required this.vm});

  final OrdersViewModel vm;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        children: [
          _OrderFilterChip(
            label: 'Filtros',
            icon:
                vm.hasActiveFilters ? Icons.close_rounded : Icons.tune_rounded,
            selected: vm.hasActiveFilters,
            onTap: vm.hasActiveFilters ? vm.clearOrderFilters : () {},
          ),
          const SizedBox(width: 8),
          _OrderFilterChip(
            label: 'Entregados',
            selected: vm.showDelivered,
            onTap: vm.toggleDeliveredFilter,
          ),
          const SizedBox(width: 8),
          _OrderFilterChip(
            label: 'Cancelados',
            selected: vm.showCancelled,
            onTap: vm.toggleCancelledFilter,
          ),
          const SizedBox(width: 8),
          _OrderFilterChip(
            label: vm.orderDateRange == null ? 'Período' : 'Período activo',
            icon: Icons.keyboard_arrow_down_rounded,
            trailingIcon: true,
            selected: vm.orderDateRange != null,
            onTap: () => _selectPeriod(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPeriod(BuildContext context) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: vm.orderDateRange,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Filtrar pedidos por período',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      saveText: 'Aplicar',
    );
    if (range != null) vm.setOrderDateRange(range);
  }
}

class _OrderFilterChip extends StatelessWidget {
  const _OrderFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailingIcon = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool trailingIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconWidget =
        icon == null
            ? null
            : Icon(
              icon,
              size: 19,
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
            );
    return Material(
      color:
          selected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconWidget != null && !trailingIcon) ...[
                iconWidget,
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color:
                      selected ? scheme.onPrimaryContainer : scheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (iconWidget != null && trailingIcon) ...[
                const SizedBox(width: 5),
                iconWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
