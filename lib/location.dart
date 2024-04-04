import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
void main() {
  runApp(MyLocation());
}
enum AppType { Zomato, Swiggy, GoogleMaps, Ola, Uber }
class MyLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Location Example'),
        ),
        body: Center(
          child: LocationWidget(),
        ),
      ),
    );
  }
}

class LocationWidget extends StatefulWidget {
  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  LocationData? currentLocation;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status == permission_handler.PermissionStatus.granted) {
      getLocation();
    } else {
      print("Location permission denied");
    }
  }

  Future<void> getLocation() async {
    try {
      var location = Location();
      currentLocation = await location.getLocation();
      setState(() {});
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Latitude: ${currentLocation?.latitude ?? "Not available"}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Longitude: ${currentLocation?.longitude ?? "Not available"}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            getLocation();
          },
          child: Text('Get Location'),
        ),
        ElevatedButton(
          onPressed: () {
            openAppWithCoordinates(AppType.Zomato, 12.971598, 77.594562);
          },
          child: Text('Open Zomato'),
        ),
        ElevatedButton(
          onPressed: () {
            openAppWithCoordinates(AppType.Swiggy, 12.971598, 77.594562);
          },
          child: Text('Open Swiggy'),
        ),
        ElevatedButton(
          onPressed: () {
            openAppWithCoordinates(AppType.GoogleMaps, 12.971598, 77.594562);
          },
          child: Text('Open Google Maps'),
        ),
        ElevatedButton(
          onPressed: () {
            openAppWithCoordinates(AppType.Ola, 12.971598, 77.594562);
          },
          child: Text('Open Ola'),
        ),
        ElevatedButton(
          onPressed: () {
            openAppWithCoordinates(AppType.Uber, 37.7749, -122.4194);
          },
          child: Text('Open Uber'),
        ),
      ],
    );
  }



  void openAppWithCoordinates(AppType appType, double latitude, double longitude) async {
  String appUrl;

  switch (appType) {
  case AppType.Zomato:
  appUrl = 'zomato://?lat=$latitude&lon=$longitude';
  break;
  case AppType.Swiggy:
  appUrl = 'swiggy://?lat=$latitude&lon=$longitude';
  break;
  case AppType.GoogleMaps:
  appUrl = 'google.navigation:q=$latitude,$longitude';
  break;
  case AppType.Ola:
  appUrl = 'olacabs://app/launch?lat=$latitude&lng=$longitude';
  break;
  case AppType.Uber:
  appUrl = 'uber://?action=setPickup&pickup=my_location&dropoff[latitude]=$latitude&dropoff[longitude]=$longitude';
  break;
  }

  if (await canLaunchUrlString(appUrl)) {
  await launchUrlString(appUrl);
  } else {
  print('${appType.toString()} app is not installed.');
  }
  }

}
