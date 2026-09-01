import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/models/search.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchBarInput extends StatelessWidget {
  const SearchBarInput({
    this.hintText,
    this.onTap,
    this.onFilterPressed,
    this.onSubmitted,
    this.onChanged,
    this.readOnly = true,
    this.showFilter = false,
    this.search,
    this.searchTEC,
    Key? key,
  }) : super(key: key);

  final String? hintText;
  final Function? onTap;
  final Function? onFilterPressed;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final bool readOnly;
  final Search? search;
  final bool? showFilter;
  final TextEditingController? searchTEC;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return HStack([
      //
      TextFormField(
            readOnly: readOnly,
            onTap: () {
              if (search != null) {
                //pages
                final page = NavigationService().searchPageWidget(search!);
                context.nextPage(page);
              } else if (onTap != null) {
                onTap!();
              }
            },
            controller: searchTEC,
            onFieldSubmitted: onSubmitted,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText ?? "Search".tr(),
              isDense: true,
              hintStyle: context.textTheme.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(
                FlutterIcons.search_fea,
                size: 20,
                color: colors.primary,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 2,
                vertical: 11,
              ),
              constraints: const BoxConstraints(minHeight: 44, maxHeight: 46),
              filled: true,
              fillColor: colors.surfaceContainerLow,
            ),
          ).box
          .color(colors.surfaceContainerLow)
          .withRounded(value: 16)
          .clip(Clip.antiAlias)
          .make()
          .expand(),
      Visibility(
        visible: showFilter ?? true,
        child: HStack([
          UiSpacer.horizontalSpace(),
          //filter icon
          IconButton(
                onPressed: null,
                color: context.theme.colorScheme.surface,
                constraints: const BoxConstraints.tightFor(
                  width: 44,
                  height: 44,
                ),
                padding: EdgeInsets.zero,
                icon: Icon(
                  FlutterIcons.sliders_faw,
                  color: context.primaryColor,
                  size: 20,
                ),
              )
              .onInkTap(
                onFilterPressed != null ? () => onFilterPressed!() : () {},
              )
              .material(color: context.theme.colorScheme.surface)
              .box
              .color(context.theme.colorScheme.surface)
              .outerShadowSm
              .roundedSM
              .clip(Clip.antiAlias)
              .make(),
        ]),
      ),
    ]);
  }
}
