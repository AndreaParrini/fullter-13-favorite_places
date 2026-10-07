import 'package:favorite_places/models/place.dart';

import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;

final Geocoding geocoding = Geocoding();

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectPlace});

  final void Function(PlaceLocation location) onSelectPlace;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettinglocation = false;

  Future<List<Placemark>> getLocationAddress(
    double latitude,
    double longitude,
  ) async {
    List<Placemark> placemark = await geocoding.placemarkFromCoordinates(
      latitude,
      longitude,
    );
    return placemark;
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final addressData = await getLocationAddress(latitude, longitude);

    // I campi del Placemark sono nullable (es. punto in mare o senza via) e la
    // lista può essere vuota: si tengono solo le parti presenti, invece di
    // assegnarle a String non nullable con il rischio di errore a runtime.
    var address = 'Unknown address';
    if (addressData.isNotEmpty) {
      final placemark = addressData.first;
      final parts = [
        placemark.street,
        placemark.postalCode,
        placemark.locality,
        placemark.country,
      ].where((part) => part != null && part.isNotEmpty);
      if (parts.isNotEmpty) {
        address = parts.join(', ');
      }
    }

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettinglocation = false;
    });

    widget.onSelectPlace(_pickedLocation!);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettinglocation = true;
    });

    locationData = await location.getLocation();
    final longitude = locationData.longitude;
    final latitude = locationData.latitude;

    /* if (longitude == null || latitude == null) {
      return;
    } */
    _savePlace(latitude, longitude);
  }

  Future<void> _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        // Si passa la location già scelta (null la prima volta) così la mappa
        // si apre centrata su quel punto con il marker già visibile.
        builder: (ctx) => MapScreen(
          location: _pickedLocation,
          isSelecting: true,
        ),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewLocation = Text(
      'No location has been selected yet',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );

    if (_pickedLocation != null) {
      // Niente mapController qui: un controller condiviso conserva la camera
      // della prima mappa e flutter_map usa initialCenter solo se il
      // controller non ha ancora una camera, quindi la preview restava ferma
      // sul primo punto. La key basata sulle coordinate fa invece ricreare la
      // FlutterMap a ogni nuova location, così initialCenter viene riletto.
      previewLocation = FlutterMap(
        key: ValueKey(
          '${_pickedLocation!.latitude}_${_pickedLocation!.longitude}',
        ),
        options: MapOptions(
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
          initialCenter: LatLng(
            _pickedLocation!.latitude,
            _pickedLocation!.longitude,
          ),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
            additionalOptions: const {'hl': 'en'},
            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
            tileProvider: NetworkTileProvider(
              cachingProvider: const DisabledMapCachingProvider(),
            ),
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                  _pickedLocation!.latitude,
                  _pickedLocation!.longitude,
                ),
                child: const Icon(
                  Icons.location_on,
                  size: 25,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_isGettinglocation) {
      previewLocation = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: previewLocation,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              onPressed: _getCurrentLocation,
              label: const Text('Get Current Location'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              onPressed: _selectOnMap,
              label: const Text('Get From Map'),
            ),
          ],
        ),
      ],
    );
  }
}
