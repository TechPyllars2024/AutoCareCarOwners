import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:autocare_carowners/ProfileManagement/services/addresses_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarOwnerAddress extends StatefulWidget {
  const CarOwnerAddress({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerAddress> createState() => _CarOwnerAddressState();
}

class _CarOwnerAddressState extends State<CarOwnerAddress> {
  List<CarOwnerAddressModel> addresses = [];
  late AddressService addressService;

  @override
  void initState() {
    super.initState();
    addressService = AddressService();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final fetchedAddresses = await addressService.fetchAddresses();
    setState(() {
      addresses = fetchedAddresses;
    });
  }

  void _showDeleteConfirmationDialog(int index) {
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
                Navigator.of(context).pop();
                final docId = (await addressService.addressCollection.get())
                    .docs[index]
                    .id;
                await addressService.deleteAddress(docId);
                _fetchAddresses();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddressDialog({CarOwnerAddressModel? address, int? index}) {
    final houseNumberandStreetController =
        TextEditingController(text: address?.houseNumberandStreet ?? '');
    final baranggayController =
        TextEditingController(text: address?.baranggay ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final provinceController =
        TextEditingController(text: address?.province ?? '');
    final nearestLandmarkController =
    TextEditingController(text: address?.nearestLandmark ?? '');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(address == null ? 'Add Address' : 'Edit Address'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: houseNumberandStreetController,
                    decoration: const InputDecoration(
                        labelText: 'House Number / Street'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your house number and street';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: baranggayController,
                    decoration: const InputDecoration(labelText: 'Baranggay'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a street';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration:
                        const InputDecoration(labelText: 'City/Municipality'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a city';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: provinceController,
                    decoration: const InputDecoration(labelText: 'Province'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a country';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nearestLandmarkController,
                    decoration:
                        const InputDecoration(labelText: 'Nearest Landmark'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a nearest landmark';
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newAddress = CarOwnerAddressModel(
                    houseNumberandStreet: houseNumberandStreetController.text,
                    baranggay: baranggayController.text,
                    city: cityController.text,
                    province: provinceController.text,
                    nearestLandmark: nearestLandmarkController.text,
                    isDefault: address?.isDefault ?? false,
                  );

                  if (address == null) {
                    await addressService.addAddress(newAddress);
                  } else {
                    final docId = (await addressService.addressCollection.get())
                        .docs[index!]
                        .id;
                    await addressService.editAddress(docId, newAddress);
                  }
                  _fetchAddresses();
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('House Number / Street: ${address.houseNumberandStreet}'),
                        Text('Phone: ${address.houseNumberandStreet}'),
                        Text('City/Municipality: ${address.city}'),
                        Text('Province: ${address.province}'),
                        Text('Nearest Landmark: ${address.nearestLandmark}'),
                        if (address.isDefault)
                          const Text('Default Address',
                              style: TextStyle(color: Colors.green)),
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
                            _showDeleteConfirmationDialog(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            address.isDefault ? Icons.star : Icons.star_border,
                          ),
                          onPressed: () async {
                            setState(() {
                              for (int i = 0; i < addresses.length; i++) {
                                addresses[i].isDefault = i == index;
                              }
                            });
                            await addressService.setDefaultAddress(
                                index, addresses);
                            _fetchAddresses();
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
