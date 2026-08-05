import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/extensions/dynamic.dart';
import 'package:chaskiy/models/product.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductReviewSumupView extends StatelessWidget {
  const ProductReviewSumupView(this.product, {Key? key}) : super(key: key);
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReviews = product.reviewsCount > 0;

    return VStack([
      Text(
        "Customer reviews".tr(),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      UiSpacer.vSpace(12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withOpacity(.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: hasReviews ? _summary(theme) : _emptyState(theme),
      ),
    ]);
  }

  Widget _summary(ThemeData theme) {
    final rating = product.rating ?? 0;
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rating.toStringAsFixed(1),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            _stars(rating),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "%s total rating".tr().fill([
                  NumberFormat('#,###').format(product.reviewsCount),
                ]),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "%s out of %s".tr().fill([rating.toStringAsFixed(1), 5]),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyState(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.reviews_outlined,
          size: 30,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "No reviews yet".tr(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "Be the first to review this product".tr(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final IconData icon;
        if (rating >= position) {
          icon = Icons.star_rounded;
        } else if (rating >= position - .5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }
        return Icon(icon, size: 16, color: AppColor.ratingColor);
      }),
    );
  }
}
