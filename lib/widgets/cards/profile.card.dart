import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:chaskiy/constants/app_finance_settings.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/view_models/profile.vm.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/states/empty.state.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard(this.model, {super.key});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.authenticated) {
      return EmptyState(
        auth: true,
        showAction: true,
        actionPressed: model.openLogin,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileHeader(model: model),
        const SizedBox(height: 22),
        SettingsSection(
          title: 'Mi cuenta',
          children: [
            SettingsTile(
              icon: HugeIcons.strokeRoundedUserEdit01,
              title: 'Edit Profile'.tr(),
              subtitle: 'Actualiza tu información personal',
              onTap: model.openEditProfile,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedResetPassword,
              title: 'Change Password'.tr(),
              subtitle: 'Mantén tu cuenta segura',
              onTap: model.openChangePassword,
            ),
            if (AppStrings.enableReferSystem)
              SettingsTile(
                icon: HugeIcons.strokeRoundedShare01,
                title: 'Refer & Earn'.tr(),
                subtitle: 'Realiza acciones y gana beneficios',
                onTap: model.openRefer,
              ),
            if (AppFinanceSettings.enableLoyalty)
              SettingsTile(
                icon: HugeIcons.strokeRoundedGift,
                title: 'Loyalty Points'.tr(),
                subtitle: 'Consulta tus puntos y recompensas',
                onTap: model.openLoyaltyPoint,
              ),
            if (AppUISettings.allowWallet)
              SettingsTile(
                icon: HugeIcons.strokeRoundedWallet01,
                title: 'Wallet'.tr(),
                subtitle: 'Gestiona tus métodos de pago',
                onTap: model.openWallet,
              ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedPinLocation01,
              title: 'Delivery Addresses'.tr(),
              subtitle: 'Administra tus direcciones guardadas',
              onTap: model.openDeliveryAddresses,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = model.currentUser!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: .35),
                        width: 3,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: user.photo,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (_, __, ___) => const BusyIndicator(),
                      errorWidget:
                          (_, __, ___) =>
                              Image.asset(AppImages.user, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16C784),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: .10,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.toLowerCase() == 'client'
                                ? 'Cliente'
                                : user.role,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: .18),
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: IconButton(
                  tooltip: 'Edit Profile'.tr(),
                  onPressed: model.openEditProfile,
                  color: theme.colorScheme.primary,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(HugeIcons.strokeRoundedEdit02, size: 21),
                ),
              ),
            ],
          ),
          if (AppStrings.enableReferSystem) ...[
            const SizedBox(height: 12),
            Material(
              color: theme.colorScheme.primary.withValues(alpha: .055),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: model.shareReferralCode,
                borderRadius: BorderRadius.circular(13),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: .20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedShare08,
                        size: 19,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'Compartir mi código',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({this.title, required this.children, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: .06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .045),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1)
                  Divider(
                    height: 1,
                    indent: 64,
                    color: theme.colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.showChevron = true,
    this.isDestructive = false,
    this.iconColor,
    this.iconBackgroundColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final bool isDestructive;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? theme.colorScheme.errorContainer.withValues(
                            alpha: .55,
                          )
                          : iconBackgroundColor ??
                              theme.colorScheme.primaryContainer.withValues(
                                alpha: .55,
                              ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 23,
                  color:
                      isDestructive
                          ? color
                          : iconColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
              if (showChevron) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
