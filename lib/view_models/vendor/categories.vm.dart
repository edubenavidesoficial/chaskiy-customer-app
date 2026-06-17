import 'package:flutter/material.dart';
import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/models/vendor_type.dart';
import 'package:chaskiy/requests/category.request.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';

class CategoriesViewModel extends MyBaseViewModel {
  CategoriesViewModel(BuildContext context, {this.vendorType, this.page}) {
    this.viewContext = context;
  }

  int? page;

  //
  CategoryRequest _categoryRequest = CategoryRequest();
  // RefreshController refreshController = RefreshController();

  //
  List<Category> categories = [];
  VendorType? vendorType;

  //
  initialise() {
    loadCategories();
  }

  //
  loadCategories() async {
    categories = [];
    setBusy(true);

    try {
      categories = await _categoryRequest.categories(
        vendorTypeId: vendorType?.id,
        page: page,
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  categorySelected(Category category) async {
    NavigationService.categorySelected(category);
  }
}
