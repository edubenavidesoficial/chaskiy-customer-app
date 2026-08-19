import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SafetyView extends StatelessWidget {
  const SafetyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        IconButton.filled(
          tooltip: 'Safety'.tr(),
          onPressed: () {
            launchUrlString('tel:${AppStrings.emergencyContact}');
          },
          icon: const Icon(Icons.shield_outlined),
          style: IconButton.styleFrom(
            fixedSize: const Size(46, 46),
            backgroundColor: theme.colorScheme.errorContainer,
            foregroundColor: theme.colorScheme.onErrorContainer,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Safety'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
