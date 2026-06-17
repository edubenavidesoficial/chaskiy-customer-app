import 'package:flutter/material.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/view_models/vendor_details.vm.dart';
import 'package:chaskiy/views/pages/vendor_details/service_vendor_details.page.dart';
import 'package:chaskiy/views/pages/vendor_details/widgets/vendor_with_subcategory.view.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/bottomsheets/cart.bottomsheet.dart';
import 'package:chaskiy/widgets/buttons/custom_rounded_leading.dart';
import 'package:chaskiy/widgets/buttons/share.btn.dart';
import 'package:chaskiy/widgets/cart_page_action.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorPlainDetailsView extends StatelessWidget {
  const VendorPlainDetailsView(this.model, {Key? key}) : super(key: key);
  final VendorDetailsViewModel model;
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      showCart: true,
      elevation: 0,
      extendBodyBehindAppBar: true,
      appBarColor: Colors.transparent,
      backgroundColor: context.theme.colorScheme.surface,
      leading: CustomRoundedLeading(),
      // fab: UploadPrescriptionFab(model),
      actions: [
        SizedBox(
          width: 50,
          height: 50,
          child: FittedBox(
            child: ShareButton(
              model: model,
            ),
          ),
        ),
        UiSpacer.hSpace(10),
        PageCartAction(),
      ],
      body: model.vendor!.isServiceType
          ? ServiceVendorDetailsPage(
              model,
              vendor: model.vendor!,
            )
          : VendorDetailsWithSubcategoryPage(
              vendor: model.vendor!,
            ),
      //
      bottomSheet: CartViewBottomSheet(),
    );
  }
}
