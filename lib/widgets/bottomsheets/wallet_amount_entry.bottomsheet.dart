import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chaskiy/models/bank_transfer_account.dart';
import 'package:chaskiy/requests/bank_transfer.request.dart';
import 'package:chaskiy/services/validator.service.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletAmountEntryBottomSheet extends StatefulWidget {
  WalletAmountEntryBottomSheet({required this.onSubmit, Key? key})
    : super(key: key);

  final Function(String) onSubmit;
  @override
  _WalletAmountEntryBottomSheetState createState() =>
      _WalletAmountEntryBottomSheetState();
}

class _WalletAmountEntryBottomSheetState
    extends State<WalletAmountEntryBottomSheet> {
  //
  final formKey = GlobalKey<FormState>();
  final amountTEC = TextEditingController();
  late Future<List<BankTransferAccount>> accountsFuture;

  @override
  void initState() {
    super.initState();
    accountsFuture = BankTransferRequest().accounts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
      child:
          VStack([
                //
                20.heightBox,
                //
                "Top-Up Wallet".tr().text.xl2.semiBold.make(),
                "Enter amount to top-up wallet with".tr().text.make(),
                FutureBuilder<List<BankTransferAccount>>(
                  future: accountsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return VStack([
                      'Puedes recargar por transferencia bancaria'
                          .tr()
                          .text
                          .semiBold
                          .make(),
                      ...snapshot.data!.map(
                        (account) =>
                            HStack([
                                  VStack([
                                    account.name.text.semiBold.make(),
                                    account.number.text.sm.make(),
                                    if (account.instructions?.isNotEmpty ==
                                        true)
                                      account.instructions!.text.xs.make(),
                                  ]).expand(),
                                  IconButton(
                                    tooltip: 'Copiar número de cuenta'.tr(),
                                    icon: const Icon(Icons.copy_outlined),
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(text: account.number),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Número de cuenta copiado'.tr(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ])
                                .p12()
                                .box
                                .roundedSM
                                .color(
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerLow,
                                )
                                .make(),
                      ),
                    ]).py12();
                  },
                ),
                Form(
                  key: formKey,
                  child: CustomTextFormField(
                    labelText: "Amount".tr(),
                    textEditingController: amountTEC,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator:
                        (value) => FormValidator.validateEmpty(
                          value,
                          errorTitle: "Amount".tr(),
                        ),
                  ),
                ).py12(),
                //
                CustomButton(
                  title: "TOP-UP".tr(),
                  onPressed: () {
                    //
                    if (formKey.currentState!.validate()) {
                      widget.onSubmit(amountTEC.text);
                    }
                  },
                ),
                //
                20.heightBox,
              ])
              .p20()
              .scrollVertical()
              .hOneThird(context)
              .box
              .color(context.theme.colorScheme.surface)
              .topRounded(value: 10)
              .make(),
    );
  }
}
