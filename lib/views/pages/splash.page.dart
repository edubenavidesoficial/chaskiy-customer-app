import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/view_models/splash.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final VideoPlayerController _videoController;
  bool _videoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(
      'assets/videos/splash.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _prepareVideo();
  }

  Future<void> _prepareVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setVolume(0);
      await _videoController.setLooping(true);
      if (!mounted) return;
      setState(() => _videoReady = true);
      await _videoController.play();
    } catch (_) {
      if (mounted) setState(() => _videoFailed = true);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      backgroundColor: colorScheme.surface,
      body: ViewModelBuilder<SplashViewModel>.reactive(
        viewModelBuilder: () => SplashViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          final hasStartupError = model.hasError && !model.isBusy;
          return SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: FractionallySizedBox(
                    widthFactor: .64,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child:
                              _videoReady && !_videoFailed
                                  ? ShaderMask(
                                    key: const ValueKey('splash-video'),
                                    blendMode: BlendMode.dstIn,
                                    shaderCallback: (bounds) {
                                      return const RadialGradient(
                                        colors: [
                                          Colors.white,
                                          Colors.white,
                                          Color(0xCCFFFFFF),
                                          Colors.transparent,
                                        ],
                                        stops: [0, .68, .84, 1],
                                      ).createShader(bounds);
                                    },
                                    child: VideoPlayer(_videoController),
                                  )
                                  : Center(
                                    key: const ValueKey('splash-fallback'),
                                    child: Image.asset(
                                      AppImages.appLogo,
                                      width: 112,
                                      height: 112,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasStartupError)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No pudimos conectar con Chaskiy. Revisa tu conexión e inténtalo nuevamente.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: model.loadAppSettings,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(48, 16, 48, 24),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: colorScheme.onSurface.withValues(
                          alpha: .1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
