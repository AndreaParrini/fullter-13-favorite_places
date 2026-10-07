import 'package:favorite_places/provider/favorite_places_provider.dart';
import 'package:favorite_places/screens/new_place.dart';
import 'package:favorite_places/widgets/favorite_place_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritePlacesScreen extends ConsumerWidget {
  const FavoritePlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget mainContent = Center(
      child: Text(
        'No places yet',
        style: Theme.of(context).textTheme.bodyLarge!
            .copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
    );

    final favoritePlaces = ref.watch(favoritePlacesProvider);

    if (favoritePlaces.isNotEmpty) {
      mainContent = Center(
        child: FavoritePlaceList(
          favoritePlaces: favoritePlaces,
        ),
      );
    }

    void addPlace() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => NewPlace(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Places'),
        actions: [
          IconButton(
            onPressed: addPlace,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: mainContent,
      ),
    );
  }
}
