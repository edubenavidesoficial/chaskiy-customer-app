import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/models/notification.dart';
import 'package:chaskiy/view_models/notifications.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/states/empty.state.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationsViewModel>.reactive(
      viewModelBuilder: () => NotificationsViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        final theme = Theme.of(context);

        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Notifications".tr(),
          appBarColor: theme.colorScheme.surface,
          appBarItemColor: theme.colorScheme.onSurface,
          elevation: 0,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          body: SafeArea(
            top: false,
            child: CustomListView(
              dataSet: model.notifications,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              emptyWidget: EmptyState(
                title: "Sin notificaciones".tr(),
                description:
                    "Aún no tienes notificaciones. Cuando recibas una, aparecerá aquí"
                        .tr(),
              ),
              itemBuilder: (context, index) {
                final notification = model.notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onPressed: () => model.showNotificationDetails(notification),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 10),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onPressed,
  });

  final NotificationModel notification;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isUnread = !(notification.read ?? false);
    final accent = _accentColor(notification);

    return Material(
      color: isUnread ? accent.withValues(alpha: 0.07) : scheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isUnread
                      ? accent.withValues(alpha: 0.28)
                      : scheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(_icon(notification), color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title?.trim().isNotEmpty == true
                                ? notification.title!.trim()
                                : 'Chaskiy',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notification.formattedTimeStamp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification.body?.trim().isNotEmpty == true
                          ? notification.body!.trim()
                          : 'Tienes una nueva actualización'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _content(NotificationModel value) =>
      '${value.title ?? ''} ${value.body ?? ''}'.toLowerCase();

  IconData _icon(NotificationModel value) {
    final content = _content(value);
    if (content.contains('complet') || content.contains('termin')) {
      return Icons.check_circle_outline_rounded;
    }
    if (content.contains('conductor') || content.contains('viaje')) {
      return Icons.local_taxi_outlined;
    }
    if (content.contains('pedido') || content.contains('orden')) {
      return Icons.receipt_long_outlined;
    }
    return Icons.notifications_none_rounded;
  }

  Color _accentColor(NotificationModel value) {
    final content = _content(value);
    if (content.contains('complet') || content.contains('termin')) {
      return const Color(0xFF16805C);
    }
    if (content.contains('cancel') || content.contains('fall')) {
      return const Color(0xFFB33A3A);
    }
    return AppColor.primaryColor;
  }
}
