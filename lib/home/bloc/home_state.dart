import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class HomeState extends Equatable {
  HomeState();

  @override
  List<Object> get props => [];
}

class HomeEmptyState extends HomeState {}

class GetDeviceLocationState extends HomeState {
  final double latitude;
  final double longitude;
  final String address;

  GetDeviceLocationState({@required this.latitude, @required this.longitude, @required this.address});

  @override
  List<Object> get props => [latitude, longitude, address];
}

class UpdateLocation extends HomeState {
  final double latitude;
  final double longitude;
  final String address;

  UpdateLocation({@required this.latitude, @required this.longitude, @required this.address});

  @override
  List<Object> get props => [latitude, longitude, address];
}

class GetPickupLocationState extends HomeState {
  final double latitude;
  final double longitude;
  final String address;

  GetPickupLocationState({@required this.latitude, @required this.longitude, @required this.address});

  @override
  List<Object> get props => [latitude, longitude, address];
}

class GetDropLocationState extends HomeState {
  final double latitude;
  final double longitude;
  final String address;

  GetDropLocationState({@required this.latitude, @required this.longitude, @required this.address});

  @override
  List<Object> get props => [latitude, longitude, address];
}

class ExceptionState extends HomeState {
  final String exception;

  ExceptionState({this.exception});

  @override
  List<Object> get props => [exception];
}

class FailureState extends HomeState {
  final String message;

  FailureState({this.message});

  @override
  List<Object> get props => [message];
}
