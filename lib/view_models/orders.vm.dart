import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_routes.dart';
import 'package:chaskiy/models/order.dart';
import 'package:chaskiy/requests/order.request.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/view_models/payment.view_model.dart';
import 'package:chaskiy/views/pages/order/taxi_order_details.page.dart';
import 'package:chaskiy/views/pages/booking/property_booking_details.page.dart';
import 'package:chaskiy/extensions/context.dart';

class OrdersViewModel extends PaymentViewModel {
  //
  OrdersViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  OrderRequest orderRequest = OrderRequest();
  List<Order> orders = [];
  bool showDelivered = false;
  bool showCancelled = false;
  DateTimeRange? orderDateRange;
  //
  int queryPage = 1;
  StreamSubscription? homePageChangeStream;
  StreamSubscription? refreshOrderStream;
  Timer? _autoRefreshTimer;
  bool _isFetching = false;

  bool get hasActiveFilters =>
      showDelivered || showCancelled || orderDateRange != null;

  List<Order> get filteredOrders {
    return orders.where((order) {
      final status = order.status.trim().toLowerCase();
      final matchesSelectedStatus =
          (!showDelivered && !showCancelled) ||
          (showDelivered &&
              ['delivered', 'completed', 'successful'].contains(status)) ||
          (showCancelled &&
              ['failed', 'fail', 'cancelled', 'cancel'].contains(status));
      if (!matchesSelectedStatus) return false;

      final range = orderDateRange;
      if (range == null) return true;
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final endExclusive = DateTime(
        range.end.year,
        range.end.month,
        range.end.day,
      ).add(const Duration(days: 1));
      return !order.createdAt.isBefore(start) &&
          order.createdAt.isBefore(endExclusive);
    }).toList();
  }

  void toggleDeliveredFilter() {
    showDelivered = !showDelivered;
    notifyListeners();
  }

  void toggleCancelledFilter() {
    showCancelled = !showCancelled;
    notifyListeners();
  }

  void setOrderDateRange(DateTimeRange? range) {
    orderDateRange = range;
    notifyListeners();
  }

  void clearOrderFilters() {
    showDelivered = false;
    showCancelled = false;
    orderDateRange = null;
    notifyListeners();
  }

  void initialise() async {
    final cachedOrders = await orderRequest.getCachedOrders();
    if (cachedOrders.isNotEmpty) {
      orders = cachedOrders;
      notifyListeners();
      await refreshMyOrdersSilently();
    } else {
      await fetchMyOrders();
    }

    homePageChangeStream = AppService().homePageIndex.stream.listen((index) {
      //
      fetchMyOrders();
    });

    refreshOrderStream = AppService().refreshAssignedOrders.listen((refresh) {
      if (refresh) {
        fetchMyOrders();
      }
    });

    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => refreshMyOrdersSilently(),
    );
  }

  //
  dispose() {
    super.dispose();
    homePageChangeStream?.cancel();
    refreshOrderStream?.cancel();
    _autoRefreshTimer?.cancel();
  }

  //
  fetchMyOrders({bool initialLoading = true}) async {
    if (_isFetching) return;
    _isFetching = true;
    if (initialLoading) {
      setBusy(true);
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mOrders = await orderRequest.getOrders(page: queryPage);
      if (!initialLoading) {
        orders.addAll(mOrders);
      } else {
        orders = mOrders;
      }
      clearErrors();
    } catch (error) {
      print("Order Error ==> $error");
      setError(error);
    }

    setBusy(false);
    _isFetching = false;
  }

  Future<void> refreshMyOrdersSilently() async {
    if (_isFetching || !isAuthenticated()) return;
    _isFetching = true;

    try {
      final latestOrders = await orderRequest.getOrders(page: 1);
      final latestIds = latestOrders.map((order) => order.id).toSet();

      orders = [
        ...latestOrders,
        ...orders.where((order) => !latestIds.contains(order.id)),
      ];
      clearErrors();
      notifyListeners();
    } catch (error) {
      debugPrint('Silent order refresh failed: $error');
    } finally {
      _isFetching = false;
    }
  }

  refreshDataSet() {
    fetchMyOrders();
  }

  openOrderDetails(Order order) async {
    //
    if (order.taxiOrder != null) {
      await viewContext.push((context) => TaxiOrderDetailPage(order: order));
      return;
    }

    if (order.isBooking) {
      await viewContext.push((context) => PropertyBookingDetailsPage(order));
      fetchMyOrders();
      return;
    }

    final result = await Navigator.of(
      viewContext,
    ).pushNamed(AppRoutes.orderDetailsRoute, arguments: order);

    //
    if (result != null && (result is Order || result is bool)) {
      if (result is Order) {
        final orderIndex = orders.indexWhere((e) => e.id == result.id);
        orders[orderIndex] = result;
        notifyListeners();
      } else {
        fetchMyOrders();
      }
    }
  }

  void openLogin() async {
    await Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    notifyListeners();
    fetchMyOrders();
  }
}
