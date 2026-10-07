import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({
    super.key,
    this.location,
    this.isSelecting = true,
  });

  // Location già selezionata da mostrare all'apertura; null se l'utente non
  // ne ha ancora scelta una (prima c'era un default fisso su Oulu, che faceva
  // aprire la mappa sempre lì).
  final PlaceLocation? location;
  final bool isSelecting;

  @override
  ConsumerState<MapScreen> createState() {
    return _MapScreenState();
  }
}

class _MapScreenState extends ConsumerState<MapScreen> {
  LatLng? _pickedLocation;

  // Se arriva una location la si usa come punto selezionato iniziale: il
  // marker è subito visibile e premendo salva senza toccare la mappa si
  // restituisce quel punto invece di null.
  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _pickedLocation = LatLng(
        widget.location!.latitude,
        widget.location!.longitude,
      );
    }
  }

  void _selectLocation(dynamic tapPosn, LatLng posn) {
    setState(() {
      _pickedLocation = posn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelecting ? 'Pick your Location' : 'Your Location',
        ),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                Navigator.of(context).pop(_pickedLocation);
              },
            ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          // initialCenter viene letto solo alla creazione della mappa: si
          // parte dal punto selezionato o, in mancanza, da un centro di default.
          initialCenter: _pickedLocation ?? const LatLng(65.01236, 25.46816),
          initialZoom: 15.0,
          onTap: widget.isSelecting ? _selectLocation : null,
        ),
        children: [
          TileLayer(
            // Tile di OpenStreetMap, il server consigliato da flutter_map. L'URL
            // mt*.google.com/vt non è un servizio pubblico per app di terze parti e
            // a volte risponde 500, mandando in errore il caricamento delle tile.
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            // Richiesto dalla policy di OpenStreetMap per identificare l'app:
            // senza, le richieste possono essere bloccate.
            userAgentPackageName: 'com.example.favorite_places',
            tileProvider: NetworkTileProvider(
              cachingProvider: const DisabledMapCachingProvider(),
              // Una tile che non arriva resta vuota invece di lanciare
              // un'eccezione: in debug l'eccezione fermava il debugger sul thread
              // principale e Android mostrava "isn't responding".
              silenceExceptions: true,
            ),
          ),
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pickedLocation!,
                  child: const Icon(
                    Icons.location_on,
                    size: 25,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
