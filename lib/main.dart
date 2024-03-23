import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the file where usersProvider is defined
import 'second.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentPosition = position;
      _currentAddress = placemarks.isNotEmpty
          ? '${placemarks[0].subThoroughfare} ${placemarks[0].thoroughfare}, ${placemarks[0].locality}, ${placemarks[0].administrativeArea}'
          : 'Address not found';
    });

    // Move camera to user's location and show marker
    _moveToUserLocation();
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Location Permission Denied"),
          content:
              const Text("Please grant location permission to use this app."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  void _onCameraMove(CameraPosition position) async {
    // You can add additional logic here if needed
  }

  void _moveToUserLocation() {
    if (_controller != null && _currentPosition != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
        ),
      );
    }
  }

  void _continueButtonPressed() {
    if (_currentPosition != null && _currentAddress != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondScreen(
            address: _currentAddress!,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
          ),
        ),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      bool? exit = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: const Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
      return exit ?? false;
    },
    child: Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  _currentPosition?.latitude ?? 0.0,
                  _currentPosition?.longitude ?? 0.0,
                ),
                zoom: 14.0,
              ),
              markers: _currentPosition != null
                  ? {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        position: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                      ),
                    }
                  : <Marker>{},
            ),
            Positioned(
              top: 30.0,
              left: 20.0,
              right: 20.0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _currentAddress ?? 'Fetching address...',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20.0, // Adjust the bottom margin as needed
              left: MediaQuery.of(context).size.width / 2 - 90, // Align horizontally to center
              child: SizedBox(
                width: 180.0, // Fixed width of 180
                child: ElevatedButton(
                  onPressed: _continueButtonPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust the vertical padding
                    textStyle: const TextStyle(fontSize: 12.0), // Adjust the font size
                  ),
                  child: const Text('Continue',),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _moveToUserLocation,
        tooltip: 'My Location',
        child: const Icon(Icons.location_searching),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    ),
  );
}

}
