import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:chaskiy/constants/app_map_settings.dart';
import 'package:chaskiy/constants/app_strings.dart';
import 'package:chaskiy/constants/input.styles.dart';
import 'package:chaskiy/models/address.dart';
import 'package:chaskiy/utils/ui_spacer.dart';
import 'package:chaskiy/widgets/busy_indicator.dart';
import 'package:chaskiy/widgets/buttons/custom_button.dart';
import 'package:chaskiy/widgets/cards/custom.visibility.dart';
import 'package:chaskiy/widgets/filters/ops_autocomplete.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:chaskiy/extensions/context.dart';

class AddressSearchView extends StatefulWidget {
  const AddressSearchView(
    this.vm, {
    Key? key,
    this.addressSelected,
    this.selectOnMap,
  }) : super(key: key);

  //
  final dynamic vm;
  final Function(dynamic)? addressSelected;
  final Function? selectOnMap;

  @override
  _AddressSearchViewState createState() => _AddressSearchViewState();
}

class _AddressSearchViewState extends State<AddressSearchView> {
  //
  bool isLoading = false;

  //
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //search bar
        CustomVisibilty(
          visible: AppMapSettings.useGoogleOnApp,
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: widget.vm.placeSearchTEC,
            googleAPIKey: AppStrings.googleMapApiKey,
            inputDecoration: InputDecoration(
              // labelText: "Address",
              hintText: "Enter your address...".tr(),
              enabledBorder: InputStyles.inputUnderlineEnabledBorder(),
              errorBorder: InputStyles.inputUnderlineEnabledBorder(),
              focusedErrorBorder: InputStyles.inputUnderlineFocusBorder(),
              focusedBorder: InputStyles.inputUnderlineFocusBorder(),
              prefixIcon: Icon(
                FlutterIcons.search_fea,
                size: 18,
              ),
              // suffixIcon: ,
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              contentPadding: EdgeInsets.all(10),
            ),
            debounceTime: 800, // default 600 ms,
            // countries: (AppStrings.countryCode != null &&
            //         AppStrings.countryCode.isNotBlank)
            //     ? [AppStrings.countryCode]
            //     : null,
            countries: null, // optional by default null is set
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) {
              // this method will return latlng with place detail
              setState(() {
                isLoading = false;
              });
              context.pop();
              if (widget.addressSelected != null) {
                widget.addressSelected!(prediction);
              }

              widget.vm.placeSearchTEC.clear();
            }, // this callback is called when isLatLngRequired is true
            itemClick: (Prediction prediction) {
              // //
              widget.vm.placeSearchTEC.text = prediction.description;
              widget.vm.placeSearchTEC.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
              //
              setState(() {
                isLoading = true;
              });
            },
          ),
        ),
        //search bar from server
        CustomVisibilty(
          visible: !AppMapSettings.useGoogleOnApp,
          child: OPSAutocompleteTextField(
            textEditingController: widget.vm.placeSearchTEC,
            inputDecoration: InputDecoration(
              hintText: "Enter your address...".tr(),
              enabledBorder: InputStyles.inputUnderlineEnabledBorder(),
              errorBorder: InputStyles.inputUnderlineEnabledBorder(),
              focusedErrorBorder: InputStyles.inputUnderlineFocusBorder(),
              focusedBorder: InputStyles.inputUnderlineFocusBorder(),
              prefixIcon: Icon(
                FlutterIcons.search_fea,
                size: 18,
              ),
              // suffixIcon: ,
              labelStyle: Theme.of(context).textTheme.bodyLarge,
              contentPadding: EdgeInsets.all(10),
            ),
            debounceTime: 800,
            onselected: (Address prediction) {
              if (widget.addressSelected != null) {
                widget.addressSelected!(prediction);
              }
              context.pop();
            },
          ),
        ),
        //
        isLoading ? BusyIndicator().centered().p20() : UiSpacer.emptySpace(),
        //
        UiSpacer.expandedSpace(),
        //
        CustomButton(
          title: "Pick On Map".tr(),
          onPressed: () {
            print("done");
            context.pop();
            if (widget.selectOnMap != null) {
              widget.selectOnMap!();
            }
          },
        ),
      ],
    ).p20().h(context.percentHeight * 90).scrollVertical();
  }
}
