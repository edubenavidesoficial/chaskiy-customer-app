import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/app_ui_settings.dart';
import 'package:chaskiy/constants/sizes.dart';
import 'package:chaskiy/extensions/string.dart';
import 'package:chaskiy/services/auth.service.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/utils/utils.dart';
import 'package:chaskiy/view_models/wallet.vm.dart';
import 'package:chaskiy/views/pages/wallet/wallet.page.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletManagementView extends StatefulWidget {
  const WalletManagementView({
    this.viewmodel,
    this.padding,
    this.breif = true,
    Key? key,
  }) : super(key: key);

  final WalletViewModel? viewmodel;
  final EdgeInsetsGeometry? padding;
  final bool breif;

  @override
  State<WalletManagementView> createState() => _WalletManagementViewState();
}

class _WalletManagementViewState extends State<WalletManagementView>
    with WidgetsBindingObserver {
  WalletViewModel? mViewmodel;
  @override
  void initState() {
    super.initState();

    mViewmodel = widget.viewmodel;
    mViewmodel ??= WalletViewModel(context);
    if (widget.breif) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //
        mViewmodel?.initialise();
      });
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (widget.breif) {
        mViewmodel?.initialise();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final bgColor = Colors.grey.shade200;
    Color bgColor = context.cardColor;
    final textColor = Utils.textColorByColor(bgColor);
    //
    return Padding(
      padding:
          widget.padding ??
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ViewModelBuilder<WalletViewModel>.reactive(
        viewModelBuilder: () => mViewmodel!,
        disposeViewModel: widget.viewmodel == null,
        builder: (context, vm, child) {
          return StreamBuilder(
            stream: AuthServices.listenToAuthState(),
            builder: (ctx, snapshot) {
              //
              if (!snapshot.hasData && widget.breif) {
                return UiSpacer.emptySpace();
              }
              //view for full info
              if (!widget.breif) {
                final colorScheme = Theme.of(context).colorScheme;
                final primary = AppColor.primaryColor;
                final balance =
                    "${AppStrings.currencySymbol} ${vm.wallet?.balance ?? 0.00}"
                        .currencyFormat();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      if (vm.isBusy) ...[
                        const SizedBox(height: 2),
                        BusyIndicator(),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        'Saldo disponible'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        balance,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (!vm.isBusy)
                        Row(
                          children: [
                            if (AppUISettings.allowWalletTransfer) ...[
                              Expanded(
                                child: _WalletAction(
                                  icon: HugeIcons.strokeRoundedMoneySend01,
                                  label: 'Send'.tr(),
                                  color: primary,
                                  onTap: vm.showWalletTransferEntry,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: _WalletAction(
                                icon: HugeIcons.strokeRoundedMoneyAdd01,
                                label: 'Top Up'.tr(),
                                color: primary,
                                onTap: vm.showAmountEntry,
                              ),
                            ),
                            if (AppUISettings.allowWalletTransfer) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: _WalletAction(
                                  icon: HugeIcons.strokeRoundedMoneyReceive01,
                                  label: 'Receive'.tr(),
                                  color: primary,
                                  onTap: vm.showMyWalletAddress,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                );
              }

              return VStack([
                    HStack([
                      //loading
                      if (vm.isBusy) BusyIndicator(),
                      //
                      VStack(
                        [
                          //
                          "${AppStrings.currencySymbol} ${vm.wallet != null ? vm.wallet?.balance : 0.00}"
                              .currencyFormat()
                              .text
                              .color(textColor)
                              .xl3
                              .semiBold
                              .make(),
                          2.heightBox,
                          "Wallet Balance".tr().text.color(textColor).make(),
                        ],
                        crossAlignment: CrossAxisAlignment.start,
                        alignment: MainAxisAlignment.start,
                      ).expand(),

                      // top-up button
                      CustomButton(
                        shapeRadius: 12,
                        onPressed: vm.showAmountEntry,
                        padding: EdgeInsets.all(2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: HStack(
                            [
                              // //
                              // "Top-Up"
                              //     .tr()
                              //     .text
                              //     .lg
                              //     .semiBold
                              //     .color(Utils.textColorByPrimaryColor())
                              //     .make(),
                              Icon(
                                // Icons.add,
                                HugeIcons.strokeRoundedMoneyAdd01,
                                color: Utils.textColorByPrimaryColor(),
                              ),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                            alignment: MainAxisAlignment.center,
                            spacing: 6,
                          ),
                        ),
                      ),
                    ], spacing: 20),
                    "Tap for more info/action"
                        .tr()
                        .text
                        .color(textColor)
                        .sm
                        .makeCentered(),
                  ], spacing: 3)
                  .p12()
                  .box
                  .shadowXs
                  .color(bgColor)
                  .withRounded(value: Sizes.radiusSmall)
                  .make()
                  .wFull(context)
                  .onInkTap(() {
                    context.nextPage(WalletPage());
                  });
            },
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
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
