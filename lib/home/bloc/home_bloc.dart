import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_tekit_solution/home/bloc/home_event.dart';
import 'package:test_tekit_solution/home/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  static HomeState get initialState => HomeEmptyState();

  HomeBloc() : super(initialState);

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is GetDeviceLocationEvent) {
      yield* getDeviceLocation();
    }

    if (event is GetDropLocationEvent) {
      yield* getDropLocation(event);
    }

    // if (event is LocationChangeEvent) {
    //   yield* updateLocation(event);
    // }
  }

  // Stream<HomeState> updateLocation(LocationChangeEvent event) async* {
  //   try {
  //     var addresses =
  //         await Geocoder.local.findAddressesFromCoordinates(Coordinates(event.latLng.latitude, event.latLng.longitude));
  //     var first = addresses.first;
  //     print("${first.featureName} : ${first.addressLine}");
  //     String address = first.addressLine;
  //     yield UpdateLocation(latitude: event.latLng.latitude, longitude: event.latLng.longitude, address: address);
  //   } catch (exception) {
  //     yield ExceptionState(exception: exception.toString());
  //   }
  // }

  Stream<HomeState> getDeviceLocation() async* {
    try {
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(Coordinates(position.latitude, position.longitude));
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");
      String address = first.addressLine;
      yield GetDeviceLocationState(latitude: position.latitude, longitude: position.longitude, address: address);
    } catch (exception) {
      yield ExceptionState(exception: exception.toString());
    }
  }

  Stream<HomeState> getPickUpLocation(GetPickupLocationEvent event) async* {
    try {
      print("GetPickupLocationEvent --->");
      LocationResult result = await showLocationPicker(
        event.context,
        "AIzaSyDrTlGfUnTMOyXDd2yq_0Y_RhWASLTOpGw",
        initialCenter: LatLng(22.744951, 75.896400),
        automaticallyAnimateToCurrentLocation: true,
        myLocationButtonEnabled: true,
        layersButtonEnabled: true,
      ).catchError((onError) {
        print("error -->" + onError.toString());
      });
      print("result = $result");
      var addresses = await Geocoder.local
          .findAddressesFromCoordinates(Coordinates(result.latLng.latitude, result.latLng.longitude));
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");
      // String address = first.addressLine;
      String address = result.address;

      yield GetPickupLocationState(
          latitude: result.latLng.latitude, longitude: result.latLng.longitude, address: address);
    } catch (exception) {
      yield ExceptionState(exception: exception.toString());
    }
  }

  Stream<HomeState> getDropLocation(GetDropLocationEvent event) async* {
    try {
      print("GetPickupLocationEvent --->");
      LocationResult result = await showLocationPicker(event.context, "AIzaSyDrTlGfUnTMOyXDd2yq_0Y_RhWASLTOpGw",
              initialCenter: LatLng(22.744951, 75.896400),
              automaticallyAnimateToCurrentLocation: true,
              myLocationButtonEnabled: true,
              layersButtonEnabled: true,
              hintText: "search place",
              appBarColor: Colors.black,
              initialZoom: 14.0,
              requiredGPS: false,
              mapStylePath: "unknown",
              resultCardAlignment: Alignment.bottomCenter,
              resultCardConfirmIcon: Icon(Icons.check),
              resultCardPadding: EdgeInsets.all(5),
              searchBarBoxDecoration:
                  BoxDecoration(color: Colors.blue, border: Border.all(color: Colors.white, width: 1)))
          .catchError((onError) {
        print("error -->" + onError.toString());
      });

      print("result = $result");
      var addresses = await Geocoder.local
          .findAddressesFromCoordinates(Coordinates(result.latLng.latitude, result.latLng.longitude));
      var first = addresses.first;
      print("${first.featureName} : ${first.addressLine}");
      String address = first.addressLine;

      yield GetDropLocationState(
          latitude: result.latLng.latitude, longitude: result.latLng.longitude, address: address);
    } catch (exception) {
      yield ExceptionState(exception: exception.toString());
    }
  }
}
