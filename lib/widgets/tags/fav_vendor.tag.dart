import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/models/vendor.dart';
import 'package:chaskiy/view_models/favourite_vendor.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FavVendorTag extends StatelessWidget {
  const FavVendorTag(this.vendor, {this.color, this.size = 22, Key? key})
      : super(key: key);

  final Vendor vendor;

  /// Sobre una foto el color de marca no siempre se distingue, así que quien
  /// lo use encima de la portada puede forzar uno.
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    //fav icon
    return ViewModelBuilder<FavouriteVendorViewModel>.reactive(
      viewModelBuilder: () => FavouriteVendorViewModel(context, vendor),
      builder: (context, model, child) {
        return model.isBusy
            ? BusyIndicator().wh(18, 18).p4()
            : Icon(
                model.vendor!.isFavourite
                    ? FlutterIcons.favorite_mdi
                    : FlutterIcons.favorite_border_mdi,
                size: size,
                color: color ?? context.theme.primaryColor,
              ).p4().onTap(
                () {
                  !model.isAuthenticated()
                      ? model.openLogin()
                      : !model.vendor!.isFavourite
                          ? model.addFavourite()
                          : model.removeFavourite();
                },
              );
      },
    );
  }
}
