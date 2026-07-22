import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/services/navigation.service.dart';
import 'package:chaskiy/view_models/welcome.vm.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';

class GojekServicesGrid extends StatelessWidget {
  const GojekServicesGrid({required this.vm, super.key});

  final WelcomeViewModel vm;

  @override
  Widget build(BuildContext context) {
    if (vm.vendorTypes.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;
    const horizontalPadding = 36.0;
    const totalSpacing = 24.0;
    final cardWidth = (screenWidth - horizontalPadding - totalSpacing) / 4;

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
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
          ),
          SizedBox(
            height: 158,
            width: double.infinity,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: vm.vendorTypes.take(8).length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final vendorType = vm.vendorTypes[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 360),
                  child: SlideAnimation(
                    horizontalOffset: 28,
                    child: FadeInAnimation(
                      child: SizedBox(
                        width: cardWidth,
                        child: _ServiceIdentityCard(
                          vendorType: vendorType,
                          onTap:
                              () => NavigationService.pageSelected(
                                vendorType,
                                context: context,
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceIdentityCard extends StatelessWidget {
  const _ServiceIdentityCard({required this.vendorType, required this.onTap});

  final dynamic vendorType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = Vx.hexToColor(vendorType.color ?? '#0874F9');

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tint.withValues(alpha: .24),
                tint.withValues(alpha: .07),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, .53, 1],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: tint.withValues(alpha: .10)),
            boxShadow: [
              BoxShadow(
                color: tint.withValues(alpha: .12),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 10, 5, 8),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .78),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .85),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tint.withValues(alpha: .16),
                        blurRadius: 9,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CustomImage(
                    imageUrl: vendorType.logo,
                    boxFit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vendorType.name ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
