import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:invit/shared/constants/colors.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition =
      LatLng(3.1724594201815997, 101.72063982955007);
  static const LatLng _KLCC = LatLng(3.1578000518488785, 101.7121404025525);

  late GoogleMapController _mapController;
  TextEditingController _searchController = TextEditingController();
  final String _apiKey = 'AIzaSyCLwwftYIJ2lIkQnglwj6Mi0KDqUM5eUjc';
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: MarkerId('initialPosition'),
        position: _initialPosition,
        infoWindow: InfoWindow(title: 'Initial Position'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _goToCurrentLocation() {
    // Placeholder function to be implemented with actual location logic
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      const CameraPosition(target: _initialPosition, zoom: 16),
    ));
  }

  Future<void> _searchPlaces(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final results = jsonResponse['results'];

      if (results.isNotEmpty) {
        final firstResult = results[0];
        final LatLng location = LatLng(
          firstResult['geometry']['location']['lat'],
          firstResult['geometry']['location']['lng'],
        );

        _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 14),
        ));

        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId(firstResult['place_id']),
              position: location,
              infoWindow: InfoWindow(title: firstResult['name']),
            ),
          );
          _markers.add(
            Marker(
              markerId: MarkerId('initialPosition'),
              position: _initialPosition,
              infoWindow: InfoWindow(title: 'Initial Position'),
            ),
          );
        });
      }
    } else {
      throw Exception('Failed to load places');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                const CameraPosition(target: _initialPosition, zoom: 14),
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,
            markers: _markers,
          ),
          Positioned(
            top: 10.0,
            left: 15.0,
            right: 15.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600]),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Find for food or restaurant...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _searchPlaces(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            right: 15.0,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: button1,
              child: const Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
