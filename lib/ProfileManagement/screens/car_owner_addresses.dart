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
          title: const Text('Delete Address', style: TextStyle(fontWeight: FontWeight.w700),),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black45),),
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
              child: Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),),
            ),
          ],
        );
      },
    );
  }

  void _showAddressDialog({CarOwnerAddressModel? address, int? index}) {
    final fullNameController =
    TextEditingController(text: address?.fullName ?? '');
    final phoneNumberController =
    TextEditingController(text: address?.phoneNumber ?? '');
    final streetController = TextEditingController(text: address?.street ?? '');
    final baranggayController =
    TextEditingController(text: address?.baranggay ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final provinceController =
    TextEditingController(text: address?.province ?? '');

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(address == null ? 'Add Address' : 'Edit Address', style: const TextStyle(fontWeight: FontWeight.w700),),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: fullNameController,
                      decoration:  InputDecoration(labelText: 'Full Name',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.orange.shade900),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a full name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration:
                       InputDecoration(labelText: 'Phone Number',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.orange.shade900),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length != 11) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: streetController,
                      decoration:  InputDecoration(labelText: 'Street',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.orange.shade900),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a street';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: baranggayController,
                      decoration:  InputDecoration(labelText: 'Baranggay',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.orange.shade900),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a street';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: cityController,
                      decoration:  InputDecoration(labelText: 'City/Municipality',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.orange.shade900),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: provinceController,
                      decoration:  InputDecoration(labelText: 'Province',
                        labelStyle: const TextStyle(color: Colors.black),
                        floatingLabelStyle: TextStyle(color: Colors.orange.shade900),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black45),
                        ),),
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
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.black45),),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newAddress = CarOwnerAddressModel(
                    fullName: fullNameController.text,
                    phoneNumber: phoneNumberController.text,
                    street: streetController.text,
                    baranggay: baranggayController.text,
                    city: cityController.text,
                    province: provinceController.text,
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
              child: Text(address == null ? 'Add' : 'Update', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold),),
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
        title: const Text('Address', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: addresses.isEmpty
          ? const Center(child: Text('No addresses. Add a new address.'))
          : ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
            child: Card(
              elevation: 8,
              color: address.isDefault ? Colors.white : Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: address.isDefault ? Colors.orange.shade900 : Colors.transparent, // Orange border if default
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                title: Text(address.fullName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phone: ${address.phoneNumber}'),
                    Text('Street: ${address.street}'),
                    Text('City/Municipality: ${address.city}'),
                    Text('Province: ${address.province}'),
                    if (address.isDefault)
                       Text('Default Address',
                          style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        _showAddressDialog(address: address, index: index);
                      },
                    ),
                    const SizedBox(width: 0),

                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        _showDeleteConfirmationDialog(index);
                      },
                    ),
                    const SizedBox(width: 0),
                    IconButton(
                      icon: Icon(
                        address.isDefault
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        onPressed: () {
          _showAddressDialog();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30, weight: 20,),
      ),
    );
  }
}
