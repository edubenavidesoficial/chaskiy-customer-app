import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Punto único para mensajes de la aplicación.
///
/// Los estados cotidianos usan SnackBar y no interrumpen la navegación. Los
/// diálogos se reservan para confirmaciones y operaciones que realmente deben
/// bloquear la interfaz.
class AlertService {
  static String? _translated(String? value) => value?.tr();

  static BuildContext? get _context => AppService().navigatorKey.currentContext;

  static Future<bool> showConfirm({
    String? title,
    String? text,
    String cancelBtnText = 'Cancel',
    String confirmBtnText = 'Ok',
    bool closeOnConfirmBtnTap = true,
    Function? onConfirm,
  }) async {
    final context = _context;
    if (context == null) return false;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: title == null ? null : Text(_translated(title)!),
                content: text == null ? null : Text(_translated(text)!),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(cancelBtnText.tr()),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(confirmBtnText.tr()),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed && onConfirm != null) onConfirm();
    return confirmed;
  }

  static Future<bool> confirm({
    String? title,
    String? text,
    String cancelBtnText = 'Cancel',
    String confirmBtnText = 'Ok',
    Function? onConfirm,
  }) => showConfirm(
    title: title,
    text: text,
    cancelBtnText: cancelBtnText,
    confirmBtnText: confirmBtnText,
    onConfirm: onConfirm,
  );

  static Future<bool> success({
    String? title,
    String? text,
    String cancelBtnText = 'Cancel',
    String confirmBtnText = 'Ok',
    bool barrierDismissible = true,
    bool closeOnConfirmBtnTap = true,
    Function? onConfirm,
    result,
  }) => _showMessage(
    title: title,
    text: text,
    color: const Color(0xFF16865A),
    icon: Icons.check_circle_outline_rounded,
    actionLabel: onConfirm == null ? null : confirmBtnText,
    onAction: onConfirm,
  );

  static Future<bool> error({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    Function? onConfirm,
  }) => _showMessage(
    title: title,
    text: text,
    color: const Color(0xFFB3261E),
    icon: Icons.error_outline_rounded,
    actionLabel: onConfirm == null ? null : confirmBtnText,
    onAction: onConfirm,
  );

  static Future<bool> warning({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    Function? onConfirm,
  }) => _showMessage(
    title: title,
    text: text,
    color: const Color(0xFF8A5A00),
    icon: Icons.warning_amber_rounded,
    actionLabel: onConfirm == null ? null : confirmBtnText,
    onAction: onConfirm,
  );

  static Future<bool> custom({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    String? cancelBtnText = 'Cancel',
    AlertType? type,
    Function? onConfirm,
    TextStyle? confirmBtnTextStyle,
    TextStyle? cancelBtnTextStyle,
    String? customAsset,
  }) => _showInformationDialog(
    title: title,
    text: text,
    confirmBtnText: confirmBtnText,
    cancelBtnText: cancelBtnText,
    onConfirm: onConfirm,
  );

  static Future<bool> dynamic({
    String? title,
    String? text,
    String confirmBtnText = 'Ok',
    String? cancelBtnText = 'Close',
    AlertType? type,
    Function? onConfirm,
  }) => _showInformationDialog(
    title: title,
    text: text,
    confirmBtnText: confirmBtnText,
    cancelBtnText: cancelBtnText,
    onConfirm: onConfirm,
  );

  static Future<bool> _showMessage({
    String? title,
    String? text,
    required Color color,
    required IconData icon,
    String? actionLabel,
    Function? onAction,
  }) async {
    final context = _context;
    if (context == null) return false;

    final message = [
      if (title != null && title.isNotEmpty) _translated(title),
      if (text != null && text.isNotEmpty) _translated(text),
    ].whereType<String>().join(': ');

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action:
            onAction == null
                ? null
                : SnackBarAction(
                  label: (actionLabel ?? 'Ok').tr(),
                  textColor: Colors.white,
                  onPressed: () => onAction(),
                ),
      ),
    );
    return true;
  }

  static Future<bool> _showInformationDialog({
    String? title,
    String? text,
    required String confirmBtnText,
    String? cancelBtnText,
    Function? onConfirm,
  }) async {
    final context = _context;
    if (context == null) return false;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (dialogContext) => AlertDialog(
                title: title == null ? null : Text(_translated(title)!),
                content: text == null ? null : Text(_translated(text)!),
                actions: [
                  if ((cancelBtnText ?? '').isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(cancelBtnText!.tr()),
                    ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: Text(confirmBtnText.tr()),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed && onConfirm != null) onConfirm();
    return confirmed;
  }

  static void showLoading() => loading();

  static void loading({
    bool barrierDismissible = false,
    String? title,
    String? text,
  }) {
    final context = _context;
    if (context == null) return;
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder:
          (_) => PopScope(
            canPop: barrierDismissible,
            child: AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(color: AppColor.primaryColor),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      _translated(text ?? 'Processing. Please wait...')!,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  static void stopLoading() {
    final context = _context;
    if (context != null && Navigator.canPop(context)) Navigator.pop(context);
  }
}

enum AlertType { success, error, warning, confirm, info, loading, custom }
