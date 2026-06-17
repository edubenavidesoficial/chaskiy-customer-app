import 'package:chaskiy/enums/product_fetch_data_type.enum.dart';
import 'package:chaskiy/extensions/context.dart';
import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/views/pages/search/products.page.dart';

mixin ProductSearchTrait {
  Future<void> openProductsSeeAllPage({
    required String title,
    ProductFetchDataType type = ProductFetchDataType.RANDOM,
    VendorType? vendorType,
    Category? category,
    bool showGrid = true,
  }) async {
    final context = AppService().navigatorKey.currentContext;
    context!.push((context) {
      return ProducsPage(
        title: title,
        vendorType: vendorType,
        type: type,
        category: category,
        showGrid: showGrid,
      );
    });
  }
}
