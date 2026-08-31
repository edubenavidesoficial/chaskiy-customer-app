import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/view_models/wallet.vm.dart';
import 'package:chaskiy/views/pages/wallet/wallet.page.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';

class GojekWalletCard extends StatefulWidget {
  const GojekWalletCard({super.key});

  @override
  State<GojekWalletCard> createState() => _GojekWalletCardState();
}

class _GojekWalletCardState extends State<GojekWalletCard>
    with WidgetsBindingObserver {
  late final WalletViewModel model;

  @override
  void initState() {
    super.initState();
    model = WalletViewModel(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => model.initialise());
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    model.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) model.initialise(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WalletViewModel>.reactive(
      viewModelBuilder: () => model,
      disposeViewModel: false,
      builder:
          (_, vm, __) => StreamBuilder<dynamic>(
            stream: AuthServices.listenToAuthState(),
            builder: (_, snapshot) {
              if (snapshot.data == false) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF052B75), Color(0xFF0874F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x440052BD),
                      blurRadius: 28,
                      offset: Offset(0, 13),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tu saldo Chaskiy',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .86),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (vm.isBusy)
                                    const BusyIndicator()
                                  else
                                    Text(
                                      '${AppStrings.currencySymbol}${vm.wallet?.balance ?? 0.00}'
                                          .currencyFormat(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 29,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  const SizedBox(width: 7),
                                  const Icon(
                                    HugeIcons.strokeRoundedView,
                                    color: Colors.white,
                                    size: 21,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FilledButton.icon(
                                onPressed:
                                    () => context.nextPage(const WalletPage()),
                                style: FilledButton.styleFrom(
                                  foregroundColor: const Color(0xFF06347F),
                                  backgroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  minimumSize: const Size(0, 34),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                ),
                                icon: const Icon(
                                  HugeIcons.strokeRoundedUser,
                                  size: 17,
                                ),
                                label: const Text(
                                  'Mi cuenta',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (AppUISettings.allowWalletTransfer)
                          _WalletAction(
                            icon: HugeIcons.strokeRoundedMoneySend01,
                            label: 'Send'.tr(),
                            onTap: vm.showWalletTransferEntry,
                          ),
                        const SizedBox(width: 10),
                        _WalletAction(
                          icon:
                              AppUISettings.allowWalletTransfer
                                  ? HugeIcons.strokeRoundedMoneyReceive01
                                  : HugeIcons.strokeRoundedMoneyAdd01,
                          label:
                              AppUISettings.allowWalletTransfer
                                  ? 'Receive'.tr()
                                  : 'Top Up'.tr(),
                          onTap:
                              AppUISettings.allowWalletTransfer
                                  ? vm.showMyWalletAddress
                                  : vm.showAmountEntry,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  const _WalletAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: .24),
                  Colors.white.withValues(alpha: .12),
                ],
              ),
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: Colors.white.withValues(alpha: .18)),
            ),
            child: Icon(icon, color: Colors.white, size: 27),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
