import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/product_details.vm.dart';
import 'package:chaskiy/widgets/buttons/circle_action_button.dart';
import 'package:chaskiy/widgets/buttons/share.btn.dart';

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
            const CartCircleAction(),
          ],
        ],
      ),
    );
  }
}
