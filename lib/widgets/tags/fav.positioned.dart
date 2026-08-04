import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/favourite.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class FavPositiedView extends StatelessWidget {
  const FavPositiedView(this.product, {Key? key}) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    //fav icon con estilo "vidrio" (blur sobre la imagen)
    return Positioned(
      top: 6,
      left: !Utils.isArabic ? null : 6,
      right: Utils.isArabic ? null : 6,
      child: ViewModelBuilder<FavouriteViewModel>.reactive(
        viewModelBuilder: () => FavouriteViewModel(context, product),
        builder: (context, model, child) {
          return ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(.22),
                padding: const EdgeInsets.all(6),
                child: model.isBusy
                    ? BusyIndicator().wh(16, 16)
                    : Icon(
                        product.isFavourite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: product.isFavourite
                            ? const Color(0xFFFF5A5F)
                            : Colors.white,
                        size: 18,
                      ).onTap(
                        () {
                          !model.isAuthenticated()
                              ? model.openLogin()
                              : !model.product.isFavourite
                                  ? model.addFavourite()
                                  : model.removeFavourite();
                        },
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
