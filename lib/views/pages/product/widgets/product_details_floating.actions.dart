import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/views/pages/cart/cart.page.dart';
import 'package:chaskiy/widgets/buttons/share.btn.dart';
import 'package:velocity_x/velocity_x.dart';

/// Acciones flotantes sobre la cabecera: volver, compartir y carrito.
/// Mantiene exactamente las mismas acciones que la AppBar anterior.
class ProductDetailsFloatingActions extends StatelessWidget {
  const ProductDetailsFloatingActions({required this.model, Key? key})
    : super(key: key);

  final ProductDetailsViewModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 6,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          CircleActionButton(
            icon:
                !Utils.isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
            iconSize: 18,
            onTap: () => Navigator.pop(context),
          ),
          const Spacer(),
          ShareButton(
            model: model,
            child: const CircleActionButton(icon: Icons.ios_share_rounded),
          ),
          if (AppUISettings.showCart) ...[
            const SizedBox(width: 10),
            const _CartActionButton(),
          ],
        ],
      ),
    );
  }
}

/// Botón circular con efecto vidrio: se apoya en la foto sin taparla y
/// mantiene el contraste sea cual sea la imagen.
class CircleActionButton extends StatelessWidget {
  const CircleActionButton({
    required this.icon,
    this.onTap,
    this.iconSize = 20,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.black.withOpacity(.28),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carrito con contador (mismo stream y navegación que PageCartAction).
class _CartActionButton extends StatefulWidget {
  const _CartActionButton();

  @override
  State<_CartActionButton> createState() => _CartActionButtonState();
}

class _CartActionButtonState extends State<_CartActionButton> {
  @override
  void initState() {
    super.initState();
    CartServices.getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CartServices.cartItemsCountStream.stream,
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            CircleActionButton(
              icon: Icons.shopping_bag_outlined,
              onTap: () => context.nextPage(CartPage()),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 21),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  "$count",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Utils.textColorByColor(AppColor.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
