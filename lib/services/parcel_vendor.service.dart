import 'package:chaskiy/models/order_stop.dart';
import 'package:chaskiy/models/vendor.dart';

class ParcelVendorService {
  static bool canServiceAllLocations(List<OrderStop> stops, Vendor vendor) {
    bool allowed = true;
    for (var stop in stops) {
      if (stop.deliveryAddress == null) {
        continue;
      }
      allowed = vendor.canServiceLocation(stop.deliveryAddress!);
      if (!allowed) {
        break;
      }
    }
    return allowed;
  }
}
