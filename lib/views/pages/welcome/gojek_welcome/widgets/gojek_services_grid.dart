import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/view_models/welcome.vm.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class GojekServicesGrid extends StatelessWidget {
  const GojekServicesGrid({required this.vm, Key? key}) : super(key: key);

  final WelcomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.vendorTypes.isEmpty) return const SizedBox.shrink();

    return AnimationLimiter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Servicios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: vm.openFeaturedVendors,
                  child: const Text(
                    'Explorar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColor.primaryColor.withValues(alpha: .06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primaryColor.withValues(alpha: .07),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Wrap(
                spacing: 0,
                runSpacing: 18,
                children: List.generate(vm.vendorTypes.take(8).length, (index) {
                  final vt = vm.vendorTypes[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    child: SlideAnimation(
                      verticalOffset: 20.0,
                      horizontalOffset: 0,
                      child: FadeInAnimation(
                        child: SizedBox(
                          // strictly 4 items per row
                          width: (MediaQuery.of(context).size.width - 52) / 4,
                          child: _ServiceCircleItem(
                            vendorType: vt,
                            onTap:
                                () => NavigationService.pageSelected(
                                  vt,
                                  context: context,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCircleItem extends StatelessWidget {
  const _ServiceCircleItem({
    required this.vendorType,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final dynamic vendorType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = Vx.hexToColor(vendorType.color ?? "#000000");

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  tint.withValues(alpha: .18),
                  tint.withValues(alpha: .07),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tint.withValues(alpha: .12)),
            ),
            padding: const EdgeInsets.all(9),
            child: CustomImage(
              imageUrl: vendorType.logo,
              boxFit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            vendorType.name ?? '',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.12,
            ),
          ).px(2),
        ],
      ),
    );
  }
}
