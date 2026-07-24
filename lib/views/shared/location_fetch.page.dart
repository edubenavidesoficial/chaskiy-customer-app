import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_images.dart';
import 'package:chaskiy/view_models/location_fetch.view_model.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:stacked/stacked.dart';

class LocationFetchPage extends StatelessWidget {
  const LocationFetchPage({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<LocationFetchViewModel>.reactive(
      viewModelBuilder: () => LocationFetchViewModel(context, child),
      disposeViewModel: true,
      onViewModelReady: (vm) => vm.initialise(),
      builder: (ctx, vm, child) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return BasePage(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: vm.loadNextPage,
                      child: Text('Siguiente'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            children: [
                              Container(
                                width: 152,
                                height: 152,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withValues(
                                    alpha: .55,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    AppImages.locationGif,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                vm.showManuallySelection
                                    ? 'Elige dónde recibir tus pedidos'
                                    : 'Buscando tu ubicación',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                vm.showManuallySelection
                                    ? 'No pudimos obtener tu ubicación automáticamente. Puedes elegirla en el mapa o intentarlo nuevamente.'
                                    : 'Esto tomará solo unos segundos.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 26),
                              if (vm.isLocating)
                                const CircularProgressIndicator()
                              else ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: FilledButton.icon(
                                    onPressed: vm.pickFromMap,
                                    icon: const Icon(Icons.map_outlined),
                                    label: const Text('Elegir en el mapa'),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: TextButton.icon(
                                    onPressed: vm.handleFetchCurrentLocation,
                                    icon: const Icon(Icons.my_location_rounded),
                                    label: Text('Intentar nuevamente'),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
