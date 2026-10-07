import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/widgets/favorite_place_details.dart';
import 'package:flutter/material.dart';

class FavoritePlaceList extends StatelessWidget {
  const FavoritePlaceList({super.key, required this.favoritePlaces});

  final List<Place> favoritePlaces;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favoritePlaces.length,
      itemBuilder: (ctx, index) => ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundImage: FileImage(favoritePlaces[index].image),
        ),
        title: Text(
          favoritePlaces[index].title,
          style: Theme.of(context).textTheme.titleMedium!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  FavoritePlaceDetails(place: favoritePlaces[index]),
            ),
          );
        },
      ),
    );
  }
}
