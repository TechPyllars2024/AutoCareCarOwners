import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CarOwnerAddress extends StatefulWidget {
  @override
  _CarOwnerAddressState createState() => _CarOwnerAddressState();
}

class _CarOwnerAddressState extends State<CarOwnerAddress> {
  List<CarOwnerAddressModel> addresses = [];
  late CollectionReference addressCollection;

  @override
  void initState() {
    super.initState();
    _initializeFirestore();
    _fetchAddresses();
  }

  void _initializeFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      addressCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses');
    }
  }

  Future<void> _fetchAddresses() async {
    final snapshot = await addressCollection.get();
    setState(() {
      addresses = snapshot.docs.map((doc) => CarOwnerAddressModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> _addAddress(CarOwnerAddressModel address) async {
    await addressCollection.add(address.toMap());
    _fetchAddresses();
  }

  Future<void> _editAddress(int index, CarOwnerAddressModel address) async {
    final docId = (await addressCollection.get()).docs[index].id;
    await addressCollection.doc(docId).update(address.toMap());
    _fetchAddresses();
  }

  Future<void> _deleteAddress(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final docId = (await addressCollection.get()).docs[index].id;
                await addressCollection.doc(docId).delete();
                _fetchAddresses();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultAddress(int index) async {
    setState(() {
      for (int i = 0; i < addresses.length; i++) {
        addresses[i].isDefault = i == index;
      }
    });
    
    final snapshot = await addressCollection.get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      final docId = snapshot.docs[i].id;
      await addressCollection.doc(docId).update({
        'isDefault': i == index,
      });
    }
  }
  void _showAddressDialog({CarOwnerAddressModel? address, int? index}) {
    final fullNameController = TextEditingController(text: address?.fullName ?? '');
    final phoneNumberController = TextEditingController(text: address?.phoneNumber ?? '');
    final streetController = TextEditingController(text: address?.street ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final countryController = TextEditingController(text: address?.country ?? '');

    final _formKey = GlobalKey<FormState>();

    final phoneNumberFormatter = MaskTextInputFormatter(
      mask: '####-###-####',
      filter: { "#": RegExp(r'[0-9]') },
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(address == null ? 'Add Address' : 'Edit Address'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a full name';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Phone Number'),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneNumberFormatter],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!phoneNumberFormatter.isFill()) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: streetController,
                    decoration: const InputDecoration(labelText: 'Street'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a street';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a city';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a country';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newAddress = CarOwnerAddressModel(
                    fullName: fullNameController.text,
                    phoneNumber: phoneNumberController.text,
                    street: streetController.text,
                    city: cityController.text,
                    country: countryController.text,
                    isDefault: address?.isDefault ?? false,
                  );

                  if (index == null) {
                    _addAddress(newAddress);
                  } else {
                    _editAddress(index, newAddress);
                  }

                  Navigator.of(context).pop();
                }
              },
              child: Text(address == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
      ),
      body: addresses.isEmpty
          ? const Center(child: Text('No addresses. Add a new address.'))
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  child: ListTile(
                    title: Text(address.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: ${address.phoneNumber}'),
                        Text('Street: ${address.street}'),
                        Text('City: ${address.city}'),
                        Text('Country: ${address.country}'),
                        if (address.isDefault) const Text('Default Address', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showAddressDialog(address: address, index: index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteAddress(index);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.star),
                          onPressed: () {
                            _setDefaultAddress(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddressDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CarOwnerAddress(),
  ));
}