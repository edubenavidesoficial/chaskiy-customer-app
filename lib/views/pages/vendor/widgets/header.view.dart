import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorHeader extends StatefulWidget {
  const VendorHeader({
    Key? key,
    required this.model,
    this.showSearch = true,
    this.bottomPadding = true,
    required this.onrefresh,
    this.onSearchPress,
  }) : super(key: key);

  final MyBaseViewModel model;
  final bool showSearch;
  final bool bottomPadding;
  final Function onrefresh;
  final Function? onSearchPress;

  @override
  _VendorHeaderState createState() => _VendorHeaderState();
}

class _VendorHeaderState extends State<VendorHeader> {
  @override
  void initState() {
    super.initState();
    //
    if (widget.model.deliveryaddress == null) {
      widget.model.fetchCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = widget.model.deliveryaddress?.address;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 21,
              color: AppColor.primaryColor,
            ),
          ).onInkTap(widget.model.useUserLocation),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                widget.model.pickDeliveryAddress(
                  vendorCheckRequired: false,
                  onselected: widget.onrefresh,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Delivery Location".tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  //sin dirección todavía se mostraba el texto "null"
                  Text(
                    (address == null || address.trim().isEmpty)
                        ? "Selecciona tu dirección".tr()
                        : address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          //
          CustomVisibilty(
            visible: widget.showSearch,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Material(
                color: Color.alphaBlend(
                  theme.colorScheme.onSurface.withOpacity(.06),
                  theme.colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (widget.onSearchPress != null) {
                      widget.onSearchPress!();
                    } else {
                      widget.model.openSearch();
                    }
                  },
                  child: const SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.search_rounded, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).pOnly(bottom: widget.bottomPadding ? Vx.dp12 : 0);
  }
}
