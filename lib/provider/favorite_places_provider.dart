import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/legacy.dart';

class FavoritePlacesNotifier extends StateNotifier<List<Place>> {
  FavoritePlacesNotifier() : super([]);

  void addPlace(Place place) {
    state = [...state, place];
  }
}

final favoritePlacesProvider =
    StateNotifierProvider<FavoritePlacesNotifier, List<Place>>((
      ref,
    ) {
      return FavoritePlacesNotifier();
    });
