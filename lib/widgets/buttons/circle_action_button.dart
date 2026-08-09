import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/services/cart.service.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/views/pages/cart/cart.page.dart';
import 'package:velocity_x/velocity_x.dart';

/// Botón circular con efecto vidrio: se apoya en la foto sin taparla y
/// mantiene el contraste sea cual sea la imagen.
///
/// Vive aquí y no junto al detalle del producto porque la portada de la
/// tienda usa exactamente los mismos botones.
class CircleActionButton extends StatelessWidget {
  const CircleActionButton({
    this.icon,
    this.child,
    this.onTap,
    this.iconSize = 20,
    Key? key,
  }) : assert(icon != null || child != null, 'Se necesita un ícono o un hijo'),
       super(key: key);

  final IconData? icon;

  /// Para envolver widgets que ya traen su propia acción, como el corazón de
  /// favoritos.
  final Widget? child;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.black.withValues(alpha: .28),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: child ?? Icon(icon, size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carrito con contador, con el mismo aspecto que el resto de los botones
/// flotantes.
class CartCircleAction extends StatefulWidget {
  const CartCircleAction({Key? key}) : super(key: key);

  @override
  State<CartCircleAction> createState() => _CartCircleActionState();
}

class _CartCircleActionState extends State<CartCircleAction> {
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
