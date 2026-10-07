import 'package:favorite_places/widgets/form_new_place.dart';
import 'package:flutter/material.dart';

class NewPlace extends StatelessWidget {
  const NewPlace({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FormNewPlace(),
      ),
    );
  }
}
