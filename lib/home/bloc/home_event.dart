import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => throw UnimplementedError();
}

class GetPickupLocationEvent extends HomeEvent {
  final BuildContext context;

  GetPickupLocationEvent({@required this.context});

  @override
  List<Object> get props => [context];
}

class GetDropLocationEvent extends HomeEvent {
  final BuildContext context;

  GetDropLocationEvent({@required this.context});

  @override
  List<Object> get props => [context];
}

class GetRoutEvent extends HomeEvent {
  final LatLng pickUpLatLong;
  final LatLng dropLatLong;

  GetRoutEvent({@required this.pickUpLatLong, @required this.dropLatLong});

  @override
  // TODO: implement props
  List<Object> get props => [pickUpLatLong, dropLatLong];
}

class BookRideEvent extends HomeEvent {}

class GetDriversEvent extends HomeEvent {
  final String latitude;
  final String longitude;

  GetDriversEvent({@required this.latitude, @required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

class GetDeviceLocationEvent extends HomeEvent {}

class LocationChangeEvent extends HomeEvent {
  final LatLng latLng;

  LocationChangeEvent({@required this.latLng});

  @override
  List<Object> get props => [latLng];
}
