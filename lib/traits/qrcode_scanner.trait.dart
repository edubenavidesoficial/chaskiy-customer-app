import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:chaskiy/extensions/context.dart';

mixin QrcodeScannerTrait {
  //scanning
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool flashEnabled = false;

  //
  Future<String?> openScanner(BuildContext viewContext) async {
    final result = await showDialog(
      context: viewContext,
      builder: (context) {
        var hasResult = false;
        return Dialog(
          child: VStack([
            //qr code preview
            QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController controller) {
                this.controller = controller;
                controller.scannedDataStream.listen((scanData) {
                  if (hasResult ||
                      scanData.code == null ||
                      scanData.code!.isEmpty) {
                    return;
                  }
                  hasResult = true;
                  controller.pauseCamera();
                  Navigator.of(context).pop(scanData.code);
                });
              },
            ).h48(context),
            //
            HStack([
              "Toggle Flash".tr().text.make().expand(),
              Switch(
                value: flashEnabled,
                onChanged: (value) {
                  flashEnabled = value;
                  controller?.toggleFlash();
                },
              ),
            ]).px20(),
          ]),
        );
      },

      //
    );

    //
    print("Results ==> $result");
    controller?.stopCamera();
    //
    FocusScope.of(viewContext).requestFocus(FocusNode());
    return result;
  }
}
