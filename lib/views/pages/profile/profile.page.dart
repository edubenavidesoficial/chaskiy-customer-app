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
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                  sliver: SliverList.list(
                    children: [
                      Text(
                        'Settings'.tr(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profile & App Settings'.tr(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ProfileCard(model),
                      const SizedBox(height: 22),
                      _PreferencesSection(model: model),
                      const SizedBox(height: 22),
                      _HelpSection(model: model),
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
    return SettingsSection(
      title: 'Ayuda e información',
      children: [
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
