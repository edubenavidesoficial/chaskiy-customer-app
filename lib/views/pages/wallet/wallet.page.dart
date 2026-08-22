import 'package:flutter/material.dart';
import 'package:chaskiy/view_models/wallet.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_easy_refresh_view.dart';
import 'package:chaskiy/widgets/custom_list_view.dart';
import 'package:chaskiy/widgets/finance/wallet_management.view.dart';
import 'package:chaskiy/widgets/list_items/wallet_transaction.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with WidgetsBindingObserver {
  //
  WalletViewModel? vm;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      vm?.initialise();
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    vm ??= WalletViewModel(context);

    //
    return BasePage(
      title: "Wallet".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<WalletViewModel>.reactive(
        viewModelBuilder: () => vm!,
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return CustomEasyRefreshView(
            refreshOnStart: false,
            onRefresh: () => vm.loadWalletData(),
            onLoad: () => vm.getWalletTransactions(initialLoading: false),
            dataset: [],
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            separator: 0.heightBox,
            loading: vm.isBusy,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: VStack([
                  //
                  WalletManagementView(
                    viewmodel: vm,
                    breif: false,
                    padding: EdgeInsets.zero,
                  ),

                  //transactions list
                  VStack([
                    Row(
                      children: [
                        Expanded(
                          child: MediaQuery.withClampedTextScaling(
                            maxScaleFactor: 1.3,
                            child: Text(
                              "Wallet Transactions".tr(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        Text(
                          '${vm.walletTransactions.length}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    CustomListView(
                      noScrollPhysics: true,
                      isLoading: vm.busy(vm.walletTransactions),
                      dataSet: vm.walletTransactions,
                      itemBuilder: (context, index) {
                        return WalletTransactionListItem(
                          vm.walletTransactions[index],
                        );
                      },
                      separatorBuilder: (_, __) => 10.heightBox,
                    ),
                  ], spacing: 12),
                ], spacing: 24),
              ),
            ),
          );
        },
      ),
    );
  }
}
