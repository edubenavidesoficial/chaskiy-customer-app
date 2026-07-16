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
              onTap: model.openEditProfile,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedResetPassword,
              title: 'Change Password'.tr(),
              onTap: model.openChangePassword,
            ),
            if (AppStrings.enableReferSystem)
              SettingsTile(
                icon: HugeIcons.strokeRoundedShare01,
                title: 'Refer & Earn'.tr(),
                onTap: model.openRefer,
              ),
            if (AppFinanceSettings.enableLoyalty)
              SettingsTile(
                icon: HugeIcons.strokeRoundedGift,
                title: 'Loyalty Points'.tr(),
                onTap: model.openLoyaltyPoint,
              ),
            if (AppUISettings.allowWallet)
              SettingsTile(
                icon: HugeIcons.strokeRoundedWallet01,
                title: 'Wallet'.tr(),
                onTap: model.openWallet,
              ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedPinLocation01,
              title: 'Delivery Addresses'.tr(),
              onTap: model.openDeliveryAddresses,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedFavourite,
              title: 'Favourites'.tr(),
              onTap: model.openFavourites,
            ),
          ],
        ),
        const SizedBox(height: 22),
        SettingsSection(
          children: [
            SettingsTile(
              icon: HugeIcons.strokeRoundedLogout01,
              title: 'Logout'.tr(),
              onTap: model.logoutPressed,
              showChevron: false,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedDelete01,
              title: 'Delete Account'.tr(),
              onTap: model.deleteAccount,
              showChevron: false,
              isDestructive: true,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: .18),
                width: 3,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: user.photo,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (_, __, ___) => const BusyIndicator(),
              errorWidget:
                  (_, __, ___) =>
                      Image.asset(AppImages.user, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (AppStrings.enableReferSystem) ...[
                  const SizedBox(height: 10),
                  ActionChip(
                    avatar: Icon(
                      HugeIcons.strokeRoundedShare08,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text('Share referral code'.tr()),
                    onPressed: model.shareReferralCode,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: .22),
                    ),
                    backgroundColor: theme.colorScheme.primaryContainer
                        .withValues(alpha: .35),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit Profile'.tr(),
            onPressed: model.openEditProfile,
            icon: const Icon(HugeIcons.strokeRoundedEdit02),
          ),
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
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.colorScheme.outlineVariant),
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
    this.trailing,
    this.showChevron = true,
    this.isDestructive = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;
  final bool isDestructive;

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      isDestructive
                          ? theme.colorScheme.errorContainer.withValues(
                            alpha: .55,
                          )
                          : theme.colorScheme.primaryContainer.withValues(
                            alpha: .55,
                          ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 21, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
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
