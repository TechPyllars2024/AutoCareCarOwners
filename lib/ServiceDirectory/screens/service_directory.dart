import 'package:flutter/material.dart';
import 'package:autocare_carowners/ServiceDirectory/widgets/text_field.dart';

class Service {
  final String name;
  final String imageUrl;

  Service(this.name, this.imageUrl); // Updated constructor
}

class ServiceDirectory extends StatefulWidget {
  const ServiceDirectory({super.key});

  @override
  State<ServiceDirectory> createState() => _AutomotiveServicesState();
}

class _AutomotiveServicesState extends State<ServiceDirectory> {
  List<Service> services = [
    Service('Car Wash', 'https://cardetailexpress.net/cdn/shop/articles/Man_Cleaning_a_Car.jpg'),
    Service('Oil Change', 'https://parkers-images.bauersecure.com/wp-images/177357/gettyimages-adding-engine-oil.jpg'),
    Service('Tire Service', 'https://tyretreaders.co.uk/wp-content/uploads/2022/02/tyre-fitting.jpg'),
    Service('Battery Check', 'https://tontio.com/wp-content/uploads/2019/03/car-battery-testing-multimeter_M.jpg'),
  ];







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'Services',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        actions: [

        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 2 / 1, // 2:1 aspect ratio
            ),
            itemCount: services.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => MaterialPageRoute,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    // Expanded(
                    //   flex: 1,
                    //   child: ClipRRect(
                    //     borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(16.0),
                    //       bottomLeft: Radius.circular(16.0),
                    //     ),
                    //     child: Image.network(
                    //       services[index].imageUrl,
                    //       height: double.infinity,
                    //       fit: BoxFit.cover,
                    //     ),
                    //   ),
                    // ),
                   // Expanded(
                    //  flex: 1,
                      // child: Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       // Text(
                      //       //   services[index].name,
                      //       //   style: TextStyle(
                      //       //     fontSize: 25,
                      //       //     fontWeight: FontWeight.bold,
                      //       //     color: Colors.grey[800],
                      //       //   ),
                      //       // ),
                      //       // SizedBox(height: 8.0),
                      //
                      //     ],
                      //   ),
                      // ),
                 //   ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
