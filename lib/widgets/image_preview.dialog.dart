import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

/// Abre la(s) imagen(es) en un visor centrado sobre la misma pantalla.
/// Se cierra tocando fuera, con la X o deslizando hacia abajo.
Future<void> showImagePreview(
  BuildContext context, {
  required List<String> images,
  int initialIndex = 0,
}) {
  final urls = images.where((url) => url.trim().isNotEmpty).toList();
  if (urls.isEmpty) return Future.value();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(.75),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder:
        (_, _, _) =>
            ImagePreviewDialog(images: urls, initialIndex: initialIndex),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class ImagePreviewDialog extends StatefulWidget {
  const ImagePreviewDialog({
    required this.images,
    this.initialIndex = 0,
    Key? key,
  }) : super(key: key);

  final List<String> images;
  final int initialIndex;

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Material(
        type: MaterialType.transparency,
        // tocar el fondo cierra el visor
        child: GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          // deslizar hacia abajo también cierra
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 300) {
              Navigator.of(context).maybePop();
            }
          },
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 70,
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (value) => setState(() => _index = value),
                      itemBuilder:
                          (context, index) => _image(widget.images[index]),
                    ),
                  ),
                ),

                //cerrar
                Positioned(
                  top: 8,
                  right: 16,
                  child: _CircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),

                //indicador de página
                if (widget.images.length > 1)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(widget.images.length, (i) {
                        final selected = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: selected ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              selected ? .95 : .45,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _image(String url) {
    // absorbe el toque para que hacer zoom no cierre el visor
    return GestureDetector(
      onTap: () {},
      child: PinchZoom(
        maxScale: 5,
        child: CachedNetworkImage(
          imageUrl: url.trim(),
          fit: BoxFit.contain,
          progressIndicatorBuilder:
              (context, url, progress) =>
                  Center(child: BusyIndicator(color: Colors.white)),
          errorWidget:
              (context, url, _) => Opacity(
                opacity: .5,
                child: Image.asset(AppImages.appLogo, fit: BoxFit.contain),
              ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.black.withOpacity(.35),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(icon, size: 22, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
