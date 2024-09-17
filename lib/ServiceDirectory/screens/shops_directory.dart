import 'package:flutter/material.dart';


class Shop {
  final String name;
  final String imageUrl;

  Shop(this.name, this.imageUrl); // Updated constructor
}

class ShopsDirectory extends StatefulWidget {
  final String serviceName; // Accept serviceName as a parameter

  const ShopsDirectory({super.key, required this.serviceName});

  @override
  State<ShopsDirectory> createState() => _ShopsDirectoryState();

}

class _ShopsDirectoryState extends State<ShopsDirectory> {

  List<Shop> services = [
    Shop('Electrical Works', 'https://i0.wp.com/www.profixautocare.com/wp-content/uploads/2020/05/image-27.png'),
    Shop('Mechanical Works', 'https://static.wixstatic.com/media/24457cc02d954991b6aafb169233cc46.jpg/v1/fill/w_1480,h_986,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/24457cc02d954991b6aafb169233cc46.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
        title: Text(
          widget.serviceName,
          style:
              TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ), // Use serviceName for the AppBar title
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 8,
                childAspectRatio: 2 / 1, // 2:1 aspect ratio
              ),
              itemCount: services.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  // Navigate to ShopsDirectory with service name as argument
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ShopsDirectory(serviceName: services[index].name),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            bottomLeft: Radius.circular(16.0),
                          ),
                          child: Image.network(
                            services[index].imageUrl,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Expanded(
                      //   flex: 1,
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           services[index].name,
                      //           style: TextStyle(
                      //             fontSize: 25,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.grey[800],
                      //           ),
                      //         ),
                      //         SizedBox(height: 8.0),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
