import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/provider/favorite_places_provider.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerStatefulWidget (e non ConsumerWidget): i dati inseriti devono
// sopravvivere ai rebuild. Prima erano variabili locali di build() e venivano
// azzerate (insieme alla GlobalKey del form) a ogni ricostruzione del widget.
class FormNewPlace extends ConsumerStatefulWidget {
  const FormNewPlace({super.key});

  @override
  ConsumerState<FormNewPlace> createState() {
    return _FormNewPlaceState();
  }
}

class _FormNewPlaceState extends ConsumerState<FormNewPlace> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  File? _selectedImage;
  PlaceLocation? _selectedLocation;

  void _savePlace() {
    if (_formKey.currentState!.validate() &&
        _selectedImage != null &&
        _selectedLocation != null) {
      _formKey.currentState!.save();

      ref
          .read(favoritePlacesProvider.notifier)
          .addPlace(
            Place(
              title: _enteredTitle,
              image: _selectedImage!,
              location: _selectedLocation!,
            ),
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: _enteredTitle,
            maxLength: 50,
            style: TextTheme.of(context).titleMedium,
            decoration: InputDecoration(
              label: const Text('Title'),
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.trim().length <= 1 ||
                  value.trim().length > 50) {
                return 'Must be between 1 and 50 characters.';
              }
              return null;
            },
            onSaved: (newValue) {
              _enteredTitle = newValue!;
            },
          ),
          const SizedBox(
            height: 12,
          ),
          ImageInput(
            onPickImage: (image) {
              _selectedImage = image;
            },
          ),
          const SizedBox(
            height: 12,
          ),
          LocationInput(
            // LocationInput restituisce già un PlaceLocation completo di
            // indirizzo: non serve rifare il geocoding qui. Prima veniva
            // rifatto in modo asincrono e non atteso, quindi premendo subito
            // "Add Place" la location poteva risultare ancora null.
            onSelectPlace: (location) {
              _selectedLocation = location;
            },
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              ElevatedButton(
                onPressed: _savePlace,
                child: const Text('Add Place'),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
