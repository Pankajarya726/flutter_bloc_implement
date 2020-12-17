import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:test_tekit_solution/Utility.dart';
import 'package:test_tekit_solution/home/bloc/home_bloc.dart';
import 'package:test_tekit_solution/home/bloc/home_event.dart';
import 'package:test_tekit_solution/home/bloc/home_state.dart';

class HomeActivity extends StatefulWidget {
  @override
  _HomeActivityState createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  static const platform = const MethodChannel('com.test_tekit_solution');
  TextEditingController txtDestinationAddress = TextEditingController();
  TextEditingController txtCurrentAddress = TextEditingController();
  GoogleMapController _controller;
  Location location = Location();
  List<LatLng> latLongList = List();
  final pageIndexNotifier = ValueNotifier<int>(0);
  PageController pageController;
  bool serviceRunning = false;

  String currentAddress = "";
  String destinationAddress = "";
  LatLng pickupLatLong;
  LatLng dropLatLong;
  var colorWhite = Colors.white;
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  static LatLng currentLatLog = LatLng(22.744951, 75.896400);
  LatLng latLong;

  _HomeActivityState() {
    checkPermission();
  }

  @override
  void initState() {
    super.initState();
    initData();
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
                          currentAddress = state.address;
                          txtCurrentAddress.text = state.address;
                        }

                        if (state is GetPickupLocationState) {
                          currentAddress = state.address;
                          pickupLatLong = LatLng(state.latitude, state.longitude);
                        }

                        if (state is GetDropLocationState) {
                          txtDestinationAddress.text = state.address;
                          dropLatLong = LatLng(state.latitude, state.longitude);
                          destinationAddress = state.address;
                        }

                        if (state is UpdateLocation) {
                          print("on update location state --->");
                          currentLatLog = LatLng(state.latitude, state.longitude);
                          pickupLatLong = currentLatLog;
                        }

                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    decoration: BoxDecoration(
                                        color: colorWhite, borderRadius: BorderRadius.circular(1), border: Border.all(color: Colors.black, width: 1)),
                                    child: Container(width: screenWidth(context) - 100, child: Text("$currentAddress")),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Destination Location",
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  child: TextFormField(
                                      controller: txtDestinationAddress,
                                      onTap: () {
                                        BlocProvider.of<HomeBloc>(context).add(GetDropLocationEvent(context: context));
                                      },
                                      readOnly: true,
                                      decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)))),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                MaterialButton(
                                  child: Text(
                                    serviceRunning ? "Stop" : "Start",
                                    style: TextStyle(color: Colors.black, fontSize: 16),
                                  ),
                                  height: 35,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), side: BorderSide(width: 1, color: Colors.black)),
                                  onPressed: () {
                                    serviceRunning ? stopService() : startService();
                                  },
                                )
                              ],
                            ),
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

  void startService() async {
    if (txtDestinationAddress.text.trim().isNotEmpty) {
      startBackGroundService();
    }
  }

  Future<void> startBackGroundService() async {
    try {
      var result = await platform.invokeMethod('startService', {"latitude": "${dropLatLong.latitude}", "longitude": "${dropLatLong.longitude}"});

      if (result.toString() == "1") {
        Utility.showToast("Service Started");
        Utility.setBooleanPreference(Utility.IS_SERVICE_RUNNING, true);
        Utility.setStringPreference(Utility.DESTINATION_ADDRESS, destinationAddress);
        Utility.setStringPreference(Utility.PICKUP_ADDRESS, currentAddress);

        serviceRunning = true;
        setState(() {});
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  void initData() async {
    bool service = await Utility.getBooleanPreference(Utility.IS_SERVICE_RUNNING);
    serviceRunning = service;

    String dAddress = await Utility.getStringPreference(Utility.DESTINATION_ADDRESS);
    destinationAddress = dAddress;
    String pAddress = await Utility.getStringPreference(Utility.DESTINATION_ADDRESS);
    currentAddress = dAddress;

    txtCurrentAddress.text = pAddress;
    txtDestinationAddress.text = dAddress;

    setState(() {});
  }

  stopService() {
    stopBackGroundService();
  }

  void stopBackGroundService() async {
    try {
      var result = await platform.invokeMethod('stopService');

      if (result.toString() == "1") {
        Utility.showToast("Service Stoped");
        Utility.setBooleanPreference(Utility.IS_SERVICE_RUNNING, false);
        Utility.setStringPreference(Utility.DESTINATION_ADDRESS, "");
        Utility.setStringPreference(Utility.PICKUP_ADDRESS, "");

        serviceRunning = false;

        setState(() {});
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }
}
