import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:test_tekit_solution/home/bloc/home_bloc.dart';
import 'package:test_tekit_solution/home/bloc/home_event.dart';
import 'package:test_tekit_solution/home/bloc/home_state.dart';

class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  TextEditingController txtDropAddress = TextEditingController();
  TextEditingController txtPickupAddress = TextEditingController();
  GoogleMapController _controller;
  Location location = Location();
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pickUpLocationIcon;
  Set<Polyline> _polyline = {};
  List<LatLng> latLongList = List();
  Set<Marker> _markers = {};
  final pageIndexNotifier = ValueNotifier<int>(0);
  PageController pageController;

  String pickupAddress = "";
  String dropAddress = "";

  LatLng pickupLatLong;
  LatLng dropLatLong;
  var colorWhite = Colors.white;

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  static LatLng currentLatLog = LatLng(22.744951, 75.896400);

  LatLng latLong;
  CameraPosition _cameraPosition;

  _HomeActivityState() {
    checkPermission();
  }

  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(target: LatLng(22.744951, 75.896400), zoom: 10.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc(),
      child: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeEmptyState) {}

          if (state is GetDeviceLocationState) {
            // print("GetDeviceLocationState");
            // location.onLocationChanged.listen((event) {
            //   print("location changed ---> $event");
            //   BlocProvider.of<HomeBloc>(context).add(LocationChangeEvent(latLng: LatLng(event.latitude, event.longitude)));
            // });
          }
        },
        child: WillPopScope(
          onWillPop: exitApp,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: colorWhite,
              appBar: AppBar(
                backgroundColor: colorWhite,
                elevation: 0,
                centerTitle: true,
                titleSpacing: 0,
                title: Text(
                  "Home",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                leading: InkWell(
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 25,
                  ),
                  onTap: () {
                    // Navigator.push(context, RouteTransition(widget: NavigationScreen()));
                  },
                ),
              ),
              body: Container(
                width: screenWidth(context),
                height: screenHeight(context),
                child: Stack(
                  children: <Widget>[
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        if (state is HomeEmptyState) {
                          BlocProvider.of<HomeBloc>(context).add(GetDeviceLocationEvent());
                        }

                        if (state is GetDeviceLocationState) {
                          currentLatLog = LatLng(state.latitude, state.longitude);
                          pickupLatLong = currentLatLog;
                          pickupAddress = state.address;
                          txtPickupAddress.text = state.address;
                          _cameraPosition = CameraPosition(target: currentLatLog, zoom: 16.0);
                        }

                        if (state is GetPickupLocationState) {
                          pickupAddress = state.address;
                          pickupLatLong = LatLng(state.latitude, state.longitude);
                          _cameraPosition = CameraPosition(target: pickupLatLong, zoom: 16.0);
                        }

                        if (state is GetDropLocationState) {
                          txtDropAddress.text = state.address;
                          dropLatLong = LatLng(state.latitude, state.longitude);
                          dropAddress = state.address;
                          _cameraPosition = CameraPosition(target: dropLatLong, zoom: 8.0);
                        }

                        if (state is UpdateLocation) {
                          print("on update location state --->");
                          currentLatLog = LatLng(state.latitude, state.longitude);
                          pickupLatLong = currentLatLog;
                          _cameraPosition = CameraPosition(target: currentLatLog, zoom: 16.0);
                        }

                        return Center(
                          child: Column(
                            children: [
                              Text(
                                "Current Location",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              GestureDetector(
                                onTap: () {
                                  BlocProvider.of<HomeBloc>(context).add(GetPickupLocationEvent(context: context));
                                },
                                child: Container(
                                  width: screenWidth(context),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  margin: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: BorderRadius.circular(1),
                                      border: Border.all(color: Colors.black, width: 1)),
                                  child: Container(width: screenWidth(context) - 100, child: Text("$pickupAddress")),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20, right: 20),
                                child: TextFormField(
                                    controller: txtDropAddress,
                                    onTap: () {
                                      BlocProvider.of<HomeBloc>(context).add(GetPickupLocationEvent(context: context));
                                    },
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)))),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Destination Location",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20, right: 20),
                                child: TextFormField(
                                    controller: txtDropAddress,
                                    onTap: () {
                                      BlocProvider.of<HomeBloc>(context).add(GetDropLocationEvent(context: context));
                                    },
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)))),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              MaterialButton(
                                child: Text(
                                  "Start",
                                  style: TextStyle(color: Colors.black, fontSize: 16),
                                ),
                                height: 35,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(width: 1, color: Colors.black)),
                                onPressed: () {},
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void checkPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<bool> exitApp() async {
    exit(0);
  }

  double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
