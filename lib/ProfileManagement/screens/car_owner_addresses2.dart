import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CarOwnerAddress extends StatefulWidget {
  const CarOwnerAddress({Key? key}) : super(key: key);

  @override
  _CarOwnerAddressState createState() => _CarOwnerAddressState();
}

class AddressModel {
  String fullName;
  String phoneNumber;
  String street;
  String city;
  String country;
  bool isDefault;

  AddressModel({
    required this.fullName,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.country,
    this.isDefault = false,
  });
}

class _CarOwnerAddressState extends State<CarOwnerAddress> {
  List<AddressModel> addresses = [
    AddressModel(
      fullName: 'Candace Yu',
      phoneNumber: '0912-345-6789',
      street: 'St. Poblacion Ilawod',
      city: 'Iloilo City',
      country: 'Philippines',
    ),
  ];

  void _editAddress(int index) {
    final address = addresses[index];
    final fullNameController = TextEditingController(text: address.fullName);
    final phoneNumberController = TextEditingController(text: address.phoneNumber);
    final streetController = TextEditingController(text: address.street);
    final cityController = TextEditingController(text: address.city);
    final countryController = TextEditingController(text: address.country);

    final _formKey = GlobalKey<FormState>();

    final phoneNumberFormatter = MaskTextInputFormatter(
      mask: '####-###-####',
      filter: { "#": RegExp(r'[0-9]') },
    );

    phoneNumberController.text = phoneNumberFormatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: address.phoneNumber),
    ).text;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Address'),
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
                        return 'Please fill this section';
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
                        return 'Please fill this section';
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
                        return 'Please fill this section';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill this section';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill this section';
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
                  setState(() {
                    addresses[index] = (AddressModel(
                      fullName: fullNameController.text,
                      phoneNumber: phoneNumberFormatter.getUnmaskedText(),
                      street: streetController.text,
                      city: cityController.text,
                      country: countryController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAddress(int index) {
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
              onPressed: () {
                setState(() {
                  addresses.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _setDefaultAddress(int index) {
    setState(() {
      for (int i = 0; i < addresses.length; i++) {
        addresses[i].isDefault = i == index;
      }
    });
  }

  void _addAddress() {
    final fullNameController = TextEditingController();
    final phoneNumberController = TextEditingController();
    final streetController = TextEditingController();
    final cityController = TextEditingController();
    final countryController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    final phoneNumberFormatter = MaskTextInputFormatter(
    mask: '####-###-####',
    filter: { "#": RegExp(r'[0-9]') },
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Address'),
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
                        return 'Please enter your full name';
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
                        return 'Please enter your street';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: countryController,
                    decoration: const InputDecoration(labelText: 'Country'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your country';
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
                  setState(() {
                    addresses.add(AddressModel(
                      fullName: fullNameController.text,
                      phoneNumber: phoneNumberController.text,
                      street: streetController.text,
                      city: cityController.text,
                      country: countryController.text,
                      isDefault: false,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
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
        title: const Text('Manage Addresses'),
      ),
      body: ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Card(
            child: ListTile(
              title: Text(address.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.phoneNumber),
                  Text(address.street),
                  Text(address.city),
                  Text(address.country),
                  if (address.isDefault) const Text('Default Address', style: TextStyle(color: Colors.green)),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    _editAddress(index);
                  } else if (value == 'Delete') {
                    _deleteAddress(index);
                  } else if (value == 'Set Default') {
                    _setDefaultAddress(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                  const PopupMenuItem(
                    value: 'Set Default',
                    child: Text('Set Default'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAddress,
        child: const Icon(Icons.add),
      ),
    );
  }
}