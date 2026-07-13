import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/app.service.dart';
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
    if (state == AppLifecycleState.resumed) model.initialise();
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
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0753C7), Color(0xFF0866E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x330052BD),
                      blurRadius: 22,
                      offset: Offset(0, 10),
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
                                'Saldo disponible',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .86),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                                        fontSize: 31,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    HugeIcons.strokeRoundedView,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed:
                                    () => context.nextPage(const WalletPage()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Color(0x88FFFFFF),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(
                                  HugeIcons.strokeRoundedUser,
                                  size: 18,
                                ),
                                label: const Text('Mi cuenta'),
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
                        const SizedBox(width: 14),
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
                    const SizedBox(height: 16),
                    Divider(
                      color: Colors.white.withValues(alpha: .22),
                      height: 1,
                    ),
                    InkWell(
                      onTap: () => AppService().homePageIndex.add(3),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Completar verificación (KYC)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                            ),
                          ],
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
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
