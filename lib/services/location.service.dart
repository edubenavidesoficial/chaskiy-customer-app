import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/models/delivery_address.dart';
import 'package:chaskiy/services/app.service.dart';
import 'package:chaskiy/services/local_storage.service.dart';
import 'package:chaskiy/widgets/bottomsheets/location_permission.bottomsheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
// import 'package:geocoder/geocoder.dart';
import 'package:rxdart/rxdart.dart';
import 'geocoder.service.dart';

class LocationService {
  //
  static Location location = new Location();

  static bool? serviceEnabled;
  static PermissionStatus? _permissionGranted;
  static LocationData? _locationData;
  static Address? currenctAddress;
  static DeliveryAddress? deliveryaddress;
  static StreamSubscription? currentLocationListener;

  //
  static PublishSubject<Address> currenctAddressSubject =
      PublishSubject<Address>();
  // stream for delivery address
  static PublishSubject<DeliveryAddress> currenctDeliveryAddressSubject =
      PublishSubject<DeliveryAddress>();
  // static Stream<Address> get currenctAddressStream =>
  //     _currenctAddressSubject.stream;

  static Future<void> prepareLocationListener([bool oneTime = false]) async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      //
      bool requestPermission = true;
      if (!Platform.isIOS) {
        requestPermission = await showRequestDialog();
      }
      if (requestPermission) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
    }

    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled == null || serviceEnabled! == false) {
      serviceEnabled = await location.requestService();
      if (serviceEnabled == null || serviceEnabled! == false) {
        return;
      }
    }

    _startLocationListner(oneTime);
  }

  static Future<bool> showRequestDialog() async {
    //
    var requestResult = false;
    //
    await showDialog(
      context: AppService().navigatorKey.currentContext!,
      builder: (context) {
        return LocationPermissionDialog(
          onResult: (result) {
            requestResult = result;
          },
        );
      },
    );

    //
    return requestResult;
  }

  static void _startLocationListner([bool oneTime = false]) async {
    //
    //update location every 100meters
    // await location.changeSettings(distanceFilter: 50);
    // //listen
    // currentLocationListener =
    //     location.onLocationChanged.listen((LocationData currentLocation) {
    //   // Use current location
    //   _locationData = currentLocation;
    //   //
    //   geocodeCurrentLocation(true);
    // });

    //listen
    currentLocationListener = Geolocator.getPositionStream().listen((
      Position currentLocation,
    ) {
      // Use current location
      _locationData = LocationData.fromMap(currentLocation.toJson());
      //
      geocodeCurrentLocation(true);
    });

    //get the current location on send to listeners
    _locationData = await location.getLocation();
    geocodeCurrentLocation(oneTime);
  }

  //
  static Future<void> geocodeCurrentLocation([
    bool closeListener = false,
  ]) async {
    if (_locationData != null) {
      final coordinates = new Coordinates(
        _locationData?.latitude ?? 0.0,
        _locationData?.longitude ?? 0.0,
      );

      try {
        //
        final addresses = await GeocoderService().findAddressesFromCoordinates(
          coordinates,
        );
        //
        currenctAddress =
            addresses.isNotEmpty
                ? addresses.first
                : _coordinateFallback(coordinates);
        //
        if (currenctAddress != null) {
          currenctAddressSubject.add(currenctAddress!);
          //set and save for next time
          final mDeliveryaddress = DeliveryAddress(
            name: currenctAddress!.featureName,
            address: currenctAddress!.addressLine,
            latitude: currenctAddress!.coordinates?.latitude,
            longitude: currenctAddress!.coordinates?.longitude,
          );
          if (deliveryaddress == null) {
            saveSelectedAddressLocally(mDeliveryaddress);
          }
        }
      } catch (error) {
        print("Error get location ==> $error");
        currenctAddress = _coordinateFallback(coordinates);
        currenctAddressSubject.add(currenctAddress!);
        if (deliveryaddress == null) {
          await saveSelectedAddressLocally(
            DeliveryAddress(
              name: 'Ubicación actual',
              address: 'Ubicación actual',
              latitude: coordinates.latitude,
              longitude: coordinates.longitude,
            ),
          );
        }
      }
    }

    //
    if (closeListener) {
      print("Location listener closed");
      currentLocationListener?.cancel();
    }
  }

  //coordinates to address
  static Future<Address?> addressFromCoordinates({
    required double lat,
    required double lng,
  }) async {
    Address? address;
    final coordinates = new Coordinates(lat, lng);

    try {
      //
      final addresses = await GeocoderService().findAddressesFromCoordinates(
        coordinates,
      );
      //
      address =
          addresses.isNotEmpty
              ? addresses.first
              : _coordinateFallback(coordinates);
    } catch (error) {
      print("Issue with addressFromCoordinates ==> $error");
    }
    return address ?? _coordinateFallback(coordinates);
  }

  static Address _coordinateFallback(Coordinates coordinates) => Address(
    coordinates: coordinates,
    addressLine: 'Ubicación actual',
    featureName: 'Ubicación actual',
  );

  //Helper methods

  //get current lat
  static double? get cLat {
    return LocationService.currenctAddress?.coordinates?.latitude;
  }

  //get current lng
  static double? get cLng {
    return LocationService.currenctAddress?.coordinates?.longitude;
  }

  //
  static saveSelectedAddressLocally(DeliveryAddress? mDeliveryaddress) async {
    deliveryaddress = mDeliveryaddress;
    if (mDeliveryaddress != null) {
      final pref = await LocalStorageService.getPrefs();
      await pref.setString(
        "LOCAL_ADDRESS",
        jsonEncode(mDeliveryaddress.toJson()),
      );
      //
      currenctDeliveryAddressSubject.add(mDeliveryaddress);
      //address
      final mAddress = Address(
        coordinates: Coordinates(
          mDeliveryaddress.latLng.latitude,
          mDeliveryaddress.latLng.longitude,
        ),
        addressLine: mDeliveryaddress.address,
        featureName: mDeliveryaddress.name,
        adminArea: mDeliveryaddress.state,
        subAdminArea: mDeliveryaddress.city,
        countryName: mDeliveryaddress.country,
      );
      currenctAddress = mAddress;
      currenctAddressSubject.add(mAddress);
    }
  }

  //
  static Future<DeliveryAddress?> getLocallySaveAddress() async {
    final pref = await LocalStorageService.getPrefs();
    final rawData = pref.getString("LOCAL_ADDRESS");
    if (rawData != null && rawData.isNotNullOrBlank) {
      return DeliveryAddress.fromJson(jsonDecode(rawData));
    }
    return null;
  }

  static Future<DeliveryAddress?> restoreSelectedAddress() async {
    final savedAddress = deliveryaddress ?? await getLocallySaveAddress();
    if (savedAddress == null) {
      return null;
    }

    if (savedAddress.address == 'Current Location') {
      savedAddress.address = 'Ubicación actual';
    }
    if (savedAddress.name == 'Current Location') {
      savedAddress.name = 'Ubicación actual';
    }
    deliveryaddress = savedAddress;
    currenctAddress = Address(
      coordinates: Coordinates(
        savedAddress.latLng.latitude,
        savedAddress.latLng.longitude,
      ),
      addressLine: savedAddress.address,
      featureName: savedAddress.name,
      adminArea: savedAddress.state,
      subAdminArea: savedAddress.city,
      countryName: savedAddress.country,
    );
    return savedAddress;
  }

  //MISC.
  static Future<double?> getFetchByLocationLat() async {
    final address = await restoreSelectedAddress();
    return address?.latitude ??
        LocationService.currenctAddress?.coordinates?.latitude;
  }

  static Future<double?> getFetchByLocationLng() async {
    final address = await restoreSelectedAddress();
    return address?.longitude ??
        LocationService.currenctAddress?.coordinates?.longitude;
  }
}
