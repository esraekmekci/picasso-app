import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'package:intl/intl.dart';

class AddArtworkPage extends StatefulWidget {
  @override
  _AddArtworkPageState createState() => _AddArtworkPageState();
}

class _AddArtworkPageState extends State<AddArtworkPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<DropdownMenuItem<String>> _artistItems = [];
  List<DropdownMenuItem<String>> _museumItems = [];
  List<DropdownMenuItem<String>> _movementItems = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }




Future<void> _loadDropdownData() async {
  try {
    // Load artists
    var artistQuery = await _db.collection('artists').get();
    var artistItems = artistQuery.docs.map((doc) {
      if (doc.exists && doc.data().containsKey('name')) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc.data()['name']),
        );
      }
      return null;
    }).where((item) => item != null).cast<DropdownMenuItem<String>>().toList();

    // Load museums
    var museumQuery = await _db.collection('museums').get();
    var museumItems = museumQuery.docs.map((doc) {
      if (doc.exists && doc.data().containsKey('name')) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc.data()['name']),
        );
      }
      return null;
    }).where((item) => item != null).cast<DropdownMenuItem<String>>().toList();

    // Load movements
    var movementQuery = await _db.collection('movements').get();
    var movementItems = movementQuery.docs.map((doc) {
      if (doc.exists && doc.data().containsKey('name')) {
        return DropdownMenuItem<String>(
          value: doc.id,
          child: Text(doc.data()['name']),
        );
      }
      return null;
    }).where((item) => item != null).cast<DropdownMenuItem<String>>().toList();

    setState(() {
      _artistItems = artistItems;
      _museumItems = museumItems;
      _movementItems = movementItems;
    });
  } catch (e) {
    print('Error loading dropdown data: $e');
    // Optionally, show a user-friendly error message or perform additional error handling
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Artwork'),
      ),
      body: FormBuilder(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(labelText: 'Artwork Name'),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                validator: FormBuilderValidators.required(),
              ),
              FormBuilderTextField(
                name: 'framedImage',
                decoration: InputDecoration(labelText: 'FramedImage URL'),
              ),
              FormBuilderTextField(
                name: 'image',
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              FormBuilderDateTimePicker(
                name: 'publishdate',
                inputType: InputType.date,
                format: DateFormat('yyyy-MM-dd'),
                decoration: InputDecoration(labelText: 'Publication Date'),
              ),
              FormBuilderDropdown(
                name: 'artist',
                decoration: InputDecoration(labelText: 'Artist'),
                items: _artistItems,
              ),
              FormBuilderDropdown(
                name: 'museum',
                decoration: InputDecoration(labelText: 'Museum'),
                items: _museumItems,
              ),
              FormBuilderFilterChip(
                name: 'movements',
                decoration: InputDecoration(labelText: 'Movements'),
                options: _movementItems.map((item) => FormBuilderChipOption(
                  value: item.value, 
                  child: item.child,
                )).toList(),
              ),
              FormBuilderTextField(
                name: 'year',
                decoration: InputDecoration(labelText: 'Year'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final formData = _formKey.currentState!.value;
      _db.collection('artworks').add({
        'name': formData['name'],
        'description': formData['description'],
        'framedImage': formData['framedImage'],
        'image': formData['image'],
        'publishdate': (formData['publishdate'] as DateTime?),
        'artist': _db.doc('artists/${formData['artist']}'),
        'museum': _db.doc('museums/${formData['museum']}'),
        'movements': (formData['movements'] as List<String?>).map((e) => _db.doc('movements/$e')).toList(),
        'year': int.tryParse(formData['year']),
      }).then((result) {
        print('Artwork Added');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Artwork successfully added!')));
        _formKey.currentState!.reset();
      }).catchError((error) {
        print('Failed to add artwork: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add artwork: $error')));
      });
    }
  }
}
