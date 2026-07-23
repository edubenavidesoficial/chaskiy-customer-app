import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/constants/home_screen.config.dart';
import 'package:chaskiy/view_models/welcome.vm.dart';
import 'package:chaskiy/widgets/base.page.dart';
import 'package:chaskiy/widgets/custom_easy_refresh_view.dart';
import 'package:stacked/stacked.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with AutomaticKeepAliveClientMixin<WelcomePage>, WidgetsBindingObserver {
  WelcomeViewModel? _viewModel;

  @override
  bool get wantKeepAlive => true;

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
      _viewModel?.initialise(initial: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BasePage(
      body: ViewModelBuilder<WelcomeViewModel>.reactive(
        viewModelBuilder: () => WelcomeViewModel(context),
        onViewModelReady: (vm) {
          _viewModel = vm;
          vm.initialise();
        },
        disposeViewModel: false,
        builder: (context, vm, child) {
          return CustomEasyRefreshView(
            headerView: MaterialHeader(),
            onRefresh: () => vm.initialise(initial: false),
            child: HomeScreenConfig.homeScreen(vm, vm.pageKey),
          );
        },
      ),
    );
  }
}
