import 'package:flutter/material.dart';
import 'shops_directory.dart';

class Service {
  final String name;
  final String imageUrl;

  Service(this.name, this.imageUrl);
}

class ServiceDirectoryScreen extends StatefulWidget {
  const ServiceDirectoryScreen({super.key, this.child});

  final Widget? child;

  @override
  State<ServiceDirectoryScreen> createState() => _AutomotiveServicesState();
}

class _AutomotiveServicesState extends State<ServiceDirectoryScreen> {
  List<Service> services = [
    Service('Electrical Works',
        'https://i0.wp.com/www.profixautocare.com/wp-content/uploads/2020/05/image-27.png'),
    Service('Mechanical Works',
        'https://static.wixstatic.com/media/24457cc02d954991b6aafb169233cc46.jpg/v1/fill/w_1480,h_986,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/24457cc02d954991b6aafb169233cc46.jpg'),
    Service('Air-conditioning Services',
        'https://reddevilradiators.com.au/wp-content/uploads/2019/12/Screen-Shot-2019-12-14-at-1.28.18-pm.png'),
    Service('Paint and Body Works',
        'https://www.supersybon.com/wp-content/uploads/2023/04/1681353422-Metallic-Black-Car-Paint-The-Ultimate-Guide-for-Car-Enthusiasts.jpg'),
    Service('Car Wash',
        'https://koronapos.com/wp-content/uploads/2022/01/car-wash-1200x675.png'),
    Service('Auto Detailing Services',
        'https://the-car-wash.com/wp-content/uploads/2017/09/intext-cleaning.jpg'),
    Service('Roadside Assistance Services',
        'https://imgcdnblog.carmudi.com.ph/wp-content/uploads/2024/09/12194250/image-1058.jpg?resize=500x333'),
    Service('Installation of Accessories Services',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRwwc4VlJ71PGy6Fjn9EadMvMN30F4f5OuL3R_QWXdnQ-Va0yDHBOzGQDVEYu106ZTimg&usqp=CAU')
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          'Services',
          style:
          TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        elevation: 0,
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 1.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 5,
                mainAxisSpacing: 8,
                childAspectRatio: 2 / 1,
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
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          child: Image.network(
                            services[index].imageUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            services[index].name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ),
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
