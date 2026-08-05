import 'package:flutter/material.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/requests/delivery_address.request.dart';
import 'package:chaskiy/services/geocoder.service.dart';
import 'package:chaskiy/view_models/base.view_model.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:what3words/what3words.dart' hide Coordinates;
import 'package:velocity_x/velocity_x.dart';

class BaseDeliveryAddressesViewModel extends MyBaseViewModel {
  //
  DeliveryAddressRequest deliveryAddressRequest = DeliveryAddressRequest();
  TextEditingController nameTEC = TextEditingController();
  TextEditingController placeSearchTEC = TextEditingController();
  TextEditingController addressTEC = TextEditingController();
  TextEditingController what3wordsTEC = TextEditingController();
  bool isDefault = false;
  DeliveryAddress? deliveryAddress;
  What3WordsV3 what3WordsV3Api = What3WordsV3(AppStrings.what3wordsApiKey);

  /// Se abre directamente el mapa (con su buscador integrado, que ya prioriza
  /// la zona del usuario). Antes se mostraba una hoja con un buscador global
  /// que podía devolver una dirección sin coordenadas.
  openLocationPicker() async {
    await showAddressLocationPicker();
  }

  /// El servidor no acepta direcciones sin coordenadas.
  bool get hasValidCoordinates {
    final latitude = deliveryAddress?.latitude;
    final longitude = deliveryAddress?.longitude;
    return latitude != null &&
        longitude != null &&
        !(latitude == 0 && longitude == 0);
  }

  //
  showAddressLocationPicker() {}

  //
  validateWhat3words(String value) async {
    //
    var coordinates =
        await what3WordsV3Api.convertToCoordinates(value).execute();

    //
    if (coordinates.isSuccessful()) {
      // print('Coordinates ${coordinates.toJson()}');
      addressTEC.text = coordinates.data()?.toJson()["nearestPlace"];
      deliveryAddress?.address = coordinates.data()?.toJson()["nearestPlace"];
      deliveryAddress?.latitude =
          coordinates.data()?.toJson()["coordinates"]["lat"];
      deliveryAddress?.longitude =
          coordinates.data()?.toJson()["coordinates"]["lng"];
      // From coordinates
      setBusy(true);
      final locationCoordinates = new Coordinates(
        deliveryAddress!.latitude!,
        deliveryAddress!.longitude!,
      );
      //
      final addresses = await GeocoderService().findAddressesFromCoordinates(
        locationCoordinates,
      );
      deliveryAddress?.city = addresses.first.locality;
      setBusy(false);
    } else {
      //
      var error = coordinates.error();
      if (error == null) {
        return;
      }
      viewContext.showToast(msg: error.message!, bgColor: Colors.red);
      if (error == What3WordsError.BAD_WORDS) {
        // The three word address provided is invalid
        print('BadWords: ${error.message}');
      } else if (error == What3WordsError.INTERNAL_SERVER_ERROR) {
        // Server Error
        print('InternalServerError: ${error.message}');
      } else if (error == What3WordsError.NETWORK_ERROR) {
        // Network Error
        print('NetworkError: ${error.message}');
      } else {
        print('${error.code} : ${error.message}');
      }
    }
  }

  void shareWhat3words() {
    launchUrlString("https://what3words.com/");
  }
}
