import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:chaskiy/models/api_response.dart';
import 'package:chaskiy/models/user.dart';
import 'package:chaskiy/models/wallet.dart';
import 'package:chaskiy/requests/wallet.request.dart';
import 'package:chaskiy/traits/qrcode_scanner.trait.dart';
import 'package:chaskiy/view_models/payment.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:chaskiy/extensions/context.dart';

class WalletTransferViewModel extends PaymentViewModel with QrcodeScannerTrait {
  //
  WalletTransferViewModel(BuildContext context, this.wallet) {
    this.viewContext = context;
  }

  //
  WalletRequest walletRequest = WalletRequest();
  Wallet? wallet;
  User? selectedUser;
  TextEditingController amountTEC = TextEditingController();
  TextEditingController passwordTEC = TextEditingController();

  //
  Future<List<User>> searchUsers(String keyword) async {
    if (keyword.isEmpty) {
      return [];
    }
    //
    ApiResponse apiResponse = await walletRequest.getWalletAddress(keyword);
    if (apiResponse.allGood) {
      //
      return (apiResponse.body["users"] as List)
          .map((e) => User.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

  void userSelected(suggestion) {
    selectedUser = suggestion;
    notifyListeners();
  }

  scanWalletAddress() async {
    final walletCode = await openScanner(viewContext);
    if (walletCode == null) {
      return;
    }
    try {
      final decoded = jsonDecode(walletCode);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('QR inválido');
      }
      selectedUser = User.fromJson(decoded);
      notifyListeners();
    } catch (_) {
      toastError("El código QR no corresponde a una billetera válida".tr());
    }
  }

  //
  initiateWalletTransfer() async {
    //
    if (selectedUser == null) {
      toastError("Please select reciepent".tr());
      return;
    }
    if (formKey.currentState!.validate()) {
      setBusy(true);
      try {
        //
        ApiResponse apiResponse = await walletRequest.transferWallet(
          amountTEC.text,
          selectedUser!.walletAddress,
          passwordTEC.text,
        );
        //
        if (apiResponse.allGood) {
          toastSuccessful(
            apiResponse.message ?? "Operación realizada correctamente".tr(),
          );
          viewContext.pop(true);
        } else {
          toastError(apiResponse.message ?? "La operación falló".tr());
        }
      } catch (error) {
        toastError("$error");
      }
      setBusy(false);
    }
  }
}
