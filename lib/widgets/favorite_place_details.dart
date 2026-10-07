import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FavoritePlaceDetails extends StatefulWidget {
  const FavoritePlaceDetails({super.key, required this.place});

  final Place place;

  @override
  State<FavoritePlaceDetails> createState() => _FavoritePlaceDetailsState();
}

class _FavoritePlaceDetailsState extends State<FavoritePlaceDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.title),
      ),
      body: Stack(
        children: [
          Image.file(
            widget.place.image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(
                      width: 2,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.center,
                  height: 150,
                  width: 150,
                  child: FlutterMap(
                    options: MapOptions(
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                      initialCenter: LatLng(
                        widget.place.location.latitude,
                        widget.place.location.longitude,
                      ),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
                        additionalOptions: const {'hl': 'en'},
                        subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                location: widget.place.location,
                                isSelecting: false,
                              ),
                            ),
                          );
                        },
                        child: MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                widget.place.location.latitude,
                                widget.place.location.longitude,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 25,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black45, Colors.black54],
                      begin: AlignmentGeometry.topCenter,
                      end: AlignmentGeometry.bottomCenter,
                    ),
                  ),
                  child: Text(
                    widget.place.location.address,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
