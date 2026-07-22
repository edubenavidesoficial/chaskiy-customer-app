import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:chaskiy/view_models/profile.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/cards/profile.card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<ProfileViewModel>.reactive(
      viewModelBuilder: () => ProfileViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      disposeViewModel: false,
      builder: (context, model, child) {
        final theme = Theme.of(context);
        final isLight = theme.brightness == Brightness.light;

        return BasePage(
          backgroundColor:
              isLight
                  ? const Color(0xFFF5F8FC)
                  : theme.colorScheme.surfaceContainerLowest,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
                  sliver: SliverList.list(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings'.tr(),
                                  style: theme.textTheme.headlineLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -.8,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Profile & App Settings'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.settings_outlined,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ProfileCard(model),
                      const SizedBox(height: 18),
                      _SecuritySection(model: model),
                      const SizedBox(height: 18),
                      _PreferencesSection(model: model),
                      const SizedBox(height: 18),
                      _HelpSection(model: model),
                      const SizedBox(height: 18),
                      _AccountActionsSection(model: model),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'v${model.appVersionInfo}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      children: [
        SettingsTile(
          icon: HugeIcons.strokeRoundedShield01,
          iconColor: const Color(0xFF12B8A6),
          iconBackgroundColor: const Color(0xFFE2FAF6),
          title: 'Seguridad y privacidad',
          subtitle: 'Controla tu privacidad y permisos',
          onTap: model.openPrivacyPolicy,
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    final adaptiveTheme = AdaptiveTheme.of(context);

    return SettingsSection(
      title: 'Preferencias',
      children: [
        SettingsTile(
          icon:
              adaptiveTheme.mode == AdaptiveThemeMode.dark
                  ? HugeIcons.strokeRoundedMoon02
                  : HugeIcons.strokeRoundedSun03,
          title: 'Theme'.tr(),
          trailing: _ValuePill(adaptiveTheme.mode.name.tr()),
          onTap: adaptiveTheme.toggleThemeMode,
        ),
        SettingsTile(
          icon: HugeIcons.strokeRoundedNotification01,
          title: 'Notifications'.tr(),
          onTap: model.openNotification,
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          childrenPadding: const EdgeInsets.only(bottom: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: .55),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              HugeIcons.strokeRoundedHelpCircle,
              color: theme.colorScheme.primary,
              size: 23,
            ),
          ),
          title: Text(
            'Ayuda e información',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Text(
            'Soporte, preguntas frecuentes y políticas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            const Divider(height: 1, indent: 74),
            SettingsTile(
              icon: HugeIcons.strokeRoundedQuestion,
              title: 'Faqs'.tr(),
              onTap: model.openFaqs,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedBubbleChat,
              title: 'Live Support'.tr(),
              onTap: model.openLearnMoreSupport,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedMail01,
              title: 'Contact Us'.tr(),
              onTap: model.openContactUs,
            ),
            SettingsTile(
              icon: HugeIcons.strokeRoundedStar,
              title: 'Rate & Review'.tr(),
              onTap: model.openReviewApp,
            ),
            _LegalExpansion(model: model),
          ],
        ),
      ),
    );
  }
}

class _AccountActionsSection extends StatelessWidget {
  const _AccountActionsSection({required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
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
    );
  }
}

class _LegalExpansion extends StatelessWidget {
  const _LegalExpansion({required this.model});

  final ProfileViewModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(64, 0, 10, 8),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(HugeIcons.strokeRoundedShield01, size: 21),
        ),
        title: Text(
          'Políticas y términos',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          _LegalTile(
            title: 'Privacy Policy'.tr(),
            onTap: model.openPrivacyPolicy,
          ),
          _LegalTile(title: 'Terms & Conditions'.tr(), onTap: model.openTerms),
          _LegalTile(
            title: 'Refund Policy'.tr(),
            onTap: model.openRefundPolicy,
          ),
          _LegalTile(
            title: 'Cancellation Policy'.tr(),
            onTap: model.openCancellationPolicy,
          ),
          _LegalTile(
            title: 'Delivery/Shipping Policy'.tr(),
            onTap: model.openShippingPolicy,
          ),
        ],
      ),
    );
  }
}

class _LegalTile extends StatelessWidget {
  const _LegalTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: onTap,
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        value,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
