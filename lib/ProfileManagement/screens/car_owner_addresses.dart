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
  bool _isLoading = false; // Loading state variable

  @override
  void initState() {
    super.initState();
    addressService = AddressService();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    final fetchedAddresses = await addressService.fetchAddresses();
    setState(() {
      addresses = fetchedAddresses;
      _isLoading = false; // Stop loading
    });
  }


  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Delete Address',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black45),
              ),
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
              child: Text(
                'Delete',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.orange.shade900),
              ),
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
          backgroundColor: Colors.white,
          title: Text(
            address == null ? 'Add Address' : 'Edit Address',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView( // Wrap the content with SingleChildScrollView
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.9,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Ensure the dialog does not take up unnecessary space
                  children: [
                    TextFormField(
                      controller: houseNumberandStreetController,
                      decoration: const InputDecoration(
                        labelText: 'House Number / Street',
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.black54),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your house number and street';
                        } else if (value.length < 2 || value.length > 30) {
                          return 'Not a valid house number and street';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        CapitalizeEachWordFormatter(),
                      ],
                    ),
                    TextFormField(
                      controller: baranggayController,
                      decoration: const InputDecoration(
                        labelText: 'Barangay',
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.black54),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a barangay';
                        } else if (value.length < 2 || value.length > 30) {
                          return 'Not a valid barangay';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        CapitalizeEachWordFormatter()
                      ],
                    ),
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(
                        labelText: 'City/Municipality',
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.black54),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city/municipality';
                        } else if (value.length < 2 || value.length > 30) {
                          return 'Not a valid city/municipality';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        CapitalizeEachWordFormatter()
                      ],
                    ),
                    TextFormField(
                      controller: provinceController,
                      decoration: const InputDecoration(
                        labelText: 'Province',
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.black54),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a province';
                        }else if (value.length < 2 || value.length > 30) {
                          return 'Not a valid province';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(30),
                        CapitalizeEachWordFormatter()
                      ],
                    ),
                    TextFormField(
                      controller: nearestLandmarkController,
                      decoration: const InputDecoration(
                        labelText: 'Nearest Landmark',
                        labelStyle: TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.black54),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a nearest landmark';
                        } else if (value.length < 2 || value.length > 50) {
                          return 'Not a valid nearest landmark';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(50),
                        CapitalizeEachWordFormatter()
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black45, fontSize: 15),
              ),
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
              child: Text(
                address == null ? 'Add' : 'Update',
                style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: addresses.isEmpty
          ? const Center(child: Text('No addresses. Add a new address.'))
          : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: address.isDefault ? Colors.orange.shade900 : Colors.transparent, // Change 2: Orange border if default
                        width: 2, // Optional: Set the border width
                      ),
                      borderRadius: BorderRadius.circular(8), // Optional: Add rounded corners
                    ),
                    elevation: 8,
                    color: address.isDefault ? Colors.white : Colors.grey.shade200,
                    child: ListTile(
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address.nearestLandmark),
                          Text(address.houseNumberandStreet),
                          Text(address.baranggay),
                          Text(address.city),
                          Text(address.province),

                          if (address.isDefault)
                            Text('Default Address',
                                style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit,
                                color: Colors.grey.shade600, size: 18),
                            onPressed: () {
                              _showAddressDialog(address: address, index: index);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: Colors.grey.shade600, size: 18),
                            onPressed: () {
                              _showDeleteConfirmationDialog(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              address.isDefault ? Icons.star : Icons.star_border,
                              size: 18,
                              color: address.isDefault
                                  ? Colors.orange.shade900
                                  : Colors.grey.shade600,
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
          ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        onPressed: () {
          _showAddressDialog();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
          weight: 20,
        ),
      ),
    );
  }
}
