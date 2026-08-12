import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

/// Punto único para mensajes de la aplicación.
///
/// Los estados cotidianos usan un aviso flotante superior que no interrumpe la
/// navegación. Los diálogos se reservan para confirmaciones y operaciones que
/// realmente deben bloquear la interfaz.
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

  static _ToastHandle? _currentToast;

  static Future<bool> _showMessage({
    String? title,
    String? text,
    required Color color,
    required IconData icon,
    String? actionLabel,
    Function? onAction,
  }) async {
    final overlay = AppService().navigatorKey.currentState?.overlay;
    if (overlay == null) return false;

    //un solo aviso a la vez: el anterior se va sin animación
    _currentToast?.remove();
    _currentToast = null;

    late final OverlayEntry entry;
    late final _ToastHandle handle;

    entry = OverlayEntry(
      builder:
          (_) => _AppToast(
            title: (title == null || title.isEmpty) ? null : _translated(title),
            text: (text == null || text.isEmpty) ? null : _translated(text),
            color: color,
            icon: icon,
            actionLabel: onAction == null ? null : (actionLabel ?? 'Ok').tr(),
            onAction: onAction,
            onDismissed: () {
              handle.remove();
              if (identical(_currentToast, handle)) _currentToast = null;
            },
          ),
    );
    handle = _ToastHandle(entry);

    _currentToast = handle;
    overlay.insert(entry);
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

/// Referencia al aviso en pantalla, para poder quitarlo una sola vez.
class _ToastHandle {
  _ToastHandle(this._entry);

  final OverlayEntry _entry;
  bool _removed = false;

  void remove() {
    if (_removed) return;
    _removed = true;
    _entry.remove();
  }
}

/// Aviso flotante que baja desde el borde superior.
///
/// Va arriba y no abajo porque en el checkout el borde inferior lo ocupa el
/// botón de pedido: el aviso lo tapaba justo cuando había que leerlo. La barra
/// inferior muestra cuánto le queda antes de irse solo.
class _AppToast extends StatefulWidget {
  const _AppToast({
    required this.color,
    required this.icon,
    required this.onDismissed,
    this.title,
    this.text,
    this.actionLabel,
    this.onAction,
  });

  final Color color;
  final IconData icon;
  final VoidCallback onDismissed;
  final String? title;
  final String? text;
  final String? actionLabel;
  final Function? onAction;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast>
    with SingleTickerProviderStateMixin {
  static const _visibleDuration = Duration(seconds: 5);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInCubic,
  );

  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _autoDismiss = Timer(_visibleDuration, _dismiss);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    _autoDismiss?.cancel();
    if (!mounted) return;
    await _controller.reverse();
    if (!mounted) return;
    widget.onDismissed();
  }

  void _runAction() {
    widget.onAction?.call();
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final topInset = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topInset + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, -1.4),
          end: Offset.zero,
        ).animate(_curve),
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: const ValueKey('app-toast'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismissed(),
              child: _card(theme, scheme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(ThemeData theme, ColorScheme scheme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          widget.color.withValues(alpha: .12),
          scheme.surface,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.color.withValues(alpha: .40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .22),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: .20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _messageText(theme, scheme)),
                  if (widget.actionLabel != null) ...[
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: _runAction,
                      style: TextButton.styleFrom(
                        foregroundColor: widget.color,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(widget.actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
            //cuánto le queda al aviso antes de irse solo
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1, end: 0),
              duration: _visibleDuration,
              builder:
                  (_, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                    color: widget.color.withValues(alpha: .70),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageText(ThemeData theme, ColorScheme scheme) {
    final title = widget.title;
    final text = widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        if (text != null)
          Padding(
            padding: EdgeInsets.only(top: title == null ? 0 : 2),
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.25,
                color: scheme.onSurface.withValues(
                  alpha: title == null ? 1 : .78,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
