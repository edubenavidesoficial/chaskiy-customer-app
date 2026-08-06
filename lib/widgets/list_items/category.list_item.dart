import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/category.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    required this.category,
    required this.onPressed,
    this.maxLine = true,
    this.h,
    this.inverted = false,
    this.textColor,
    this.lines = 1,
    Key? key,
  }) : super(key: key);

  final Function(Category) onPressed;
  final Category category;
  final bool maxLine;
  final double? h;
  final bool inverted;
  final Color? textColor;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget child = 5.heightBox;

    if (inverted) {
      //el color de la categoría se usa solo como tinte: un bloque sólido de
      //color claro quedaba ilegible sobre el tema oscuro
      final accent = Vx.hexToColor(category.color);
      final isDark = theme.brightness == Brightness.dark;
      final bgColor = Color.alphaBlend(
        accent.withOpacity(isDark ? .18 : .14),
        theme.colorScheme.surface,
      );
      child = _buildCategoryViewBase(
        maxLine,
        inverted,
        textColor ?? theme.colorScheme.onSurface,
      );
      child = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(isDark ? .30 : .22)),
        ),
        child: child,
      );
    } else {
      Color mTextColor = Utils.textColorByColor(Colors.transparent);
      child = _buildCategoryViewBase(
        maxLine,
        inverted,
        textColor ?? mTextColor,
      );
    }

    //
    if (maxLine || h != null) {
      double _width = (AppStrings.categoryImageWidth * 1.8);
      _width += AppStrings.categoryTextSize;
      double _height = (AppStrings.categoryImageHeight * 1.8);
      _height += AppStrings.categoryImageHeight;
      if (h != null) {
        _height = h!;
      }
      child =
          SizedBox(
            width: _width,
            height: _height,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(onTap: () => onPressed(category), child: child),
            ),
          ).px4();
    } else {
      child = child.onInkTap(() => this.onPressed(this.category)).px4();
    }
    return child;
  }

  //
  Widget _buildCategoryViewBase(bool maxLine, bool inverted, Color textColor) {
    Widget nameView = category.name.text
        .size(AppStrings.categoryTextSize)
        .wrapWords(true)
        .center
        .fontWeight(FontWeight.w700)
        .color(textColor)
        .make()
        .py(1);
    if (maxLine) {
      nameView = category.name.text
          .minFontSize(AppStrings.categoryTextSize)
          .size(AppStrings.categoryTextSize)
          .center
          .fontWeight(FontWeight.w700)
          .color(textColor)
          .maxLines(lines)
          .ellipsis
          .make()
          .py(1);
    }
    return Container(
      width: AppStrings.categoryImageWidth,
      child: VStack(
        [
          //
          CustomImage(
                imageUrl: category.imageUrl,
                boxFit: BoxFit.contain,
                width: AppStrings.categoryImageWidth * (inverted ? 0.75 : 1),
                height: AppStrings.categoryImageHeight * (inverted ? 0.75 : 1),
              ).box
              .withRounded(value: 14)
              .clip(Clip.antiAlias)
              .color(
                inverted ? Colors.transparent : Vx.hexToColor(category.color),
              )
              .make()
              .py2(),

          //
          nameView,
        ],
        crossAlignment: CrossAxisAlignment.center,
        alignment: MainAxisAlignment.center,
      ),
    );
  }
}
