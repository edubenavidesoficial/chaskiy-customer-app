import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/services/location.service.dart';
import 'package:chaskiy/view_models/welcome.vm.dart';
import 'package:chaskiy/views/pages/notification/notifications.page.dart';
import 'package:chaskiy/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class GojekHeader extends StatelessWidget {
  const GojekHeader({required this.vm, required this.onLocationTap, super.key});

  final WelcomeViewModel vm;
  final Future<void> Function() onLocationTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.surface,
            AppColor.primaryColor.withValues(alpha: .055),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColor.primaryColor,
                          AppColor.primaryColor.withValues(alpha: .78),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withValues(alpha: .22),
                          blurRadius: 14,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedLocation01,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: onLocationTap,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Deliver To'.tr(),
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            StreamBuilder<DeliveryAddress?>(
                              stream:
                                  LocationService
                                      .currenctDeliveryAddressSubject,
                              initialData: vm.deliveryaddress,
                              builder:
                                  (_, snapshot) => Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          snapshot.data?.address ??
                                              'Select Location'.tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor
                                              .withValues(alpha: .10),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          size: 18,
                                          color: AppColor.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _HeaderAction(
                    icon: HugeIcons.strokeRoundedNotification02,
                    showBadge: true,
                    onTap: () => context.nextPage(const NotificationsPage()),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<dynamic>(
                    stream: AuthServices.listenToAuthState(),
                    builder: (_, snapshot) {
                      final photo = AuthServices.currentUser?.photo ?? '';
                      return InkWell(
                        onTap: () => AppService().homePageIndex.add(3),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surfaceContainerHighest,
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              photo.isEmpty
                                  ? Icon(
                                    HugeIcons.strokeRoundedUser,
                                    color: colors.onSurfaceVariant,
                                  )
                                  : CustomImage(
                                    imageUrl: photo,
                                    boxFit: BoxFit.cover,
                                  ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Material(
                color: colors.surface,
                elevation: 0,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => AppService().homePageIndex.add(2),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColor.primaryColor.withValues(alpha: .14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withValues(alpha: .08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedSearch01,
                          size: 27,
                          color: AppColor.primaryColor,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Buscar servicios, restaurantes, tiendas...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF7A00,
                            ).withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            HugeIcons.strokeRoundedFilterHorizontal,
                            size: 21,
                            color: Color(0xFFFF7A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications'.tr(),
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: showBadge,
        smallSize: 9,
        backgroundColor: const Color(0xFFFF4D55),
        child: Icon(icon, size: 27),
      ),
    );
  }
}
