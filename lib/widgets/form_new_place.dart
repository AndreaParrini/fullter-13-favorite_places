import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/provider/favorite_places_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormNewPlace extends ConsumerWidget {
  const FormNewPlace({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    var enteredTitle = '';

    void savePlace() {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();

        ref
            .read(favoritePlacesProvider.notifier)
            .addPlace(Place(title: enteredTitle));

        Navigator.of(context).pop();
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: enteredTitle,
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
              enteredTitle = newValue!;
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
                onPressed: savePlace,
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
