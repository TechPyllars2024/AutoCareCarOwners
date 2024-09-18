import 'package:flutter/material.dart';
import '../services/categories_service.dart';
import 'shops_directory.dart';

class Service {
  final String name;
  final String imageUrl;

  Service(this.name, this.imageUrl); // Updated constructor
}

class ServiceDirectoryScreen extends StatefulWidget {
  const ServiceDirectoryScreen({super.key, this.child});

  final Widget? child;

  @override
  State<ServiceDirectoryScreen> createState() => _AutomotiveServicesState();
}

class _AutomotiveServicesState extends State<ServiceDirectoryScreen> {
  final CategoriesService _categoriesService = CategoriesService();
  List<Service> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    List<String> categories = await _categoriesService.fetchServiceCategories();

    setState(() {
      services = categories.map((category) {
        String imageUrl = _getImageUrlForCategory(category);
        return Service(category, imageUrl);
      }).toList();
      isLoading = false;
    });
  }

  String _getImageUrlForCategory(String category) {
    // Replace with appropriate URLs for each category
    switch (category) {
      case 'Electrical Works':
        return 'https://i0.wp.com/www.profixautocare.com/wp-content/uploads/2020/05/image-27.png';
      case 'Mechanical Works':
        return 'https://static.wixstatic.com/media/24457cc02d954991b6aafb169233cc46.jpg/v1/fill/w_1480,h_986,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/24457cc02d954991b6aafb169233cc46.jpg';
      case 'Air-conditioning Services':
        return 'https://reddevilradiators.com.au/wp-content/uploads/2019/12/Screen-Shot-2019-12-14-at-1.28.18-pm.png';
      case 'Paint and Body Works':
        return 'https://www.supersybon.com/wp-content/uploads/2023/04/1681353422-Metallic-Black-Car-Paint-The-Ultimate-Guide-for-Car-Enthusiasts.jpg';
      case 'Car Wash':
        return 'https://koronapos.com/wp-content/uploads/2022/01/car-wash-1200x675.png';
      case 'Auto Detailing Services':
        return 'https://the-car-wash.com/wp-content/uploads/2017/09/intext-cleaning.jpg';
      case 'Roadside Assistance Services':
        return 'https://imgcdnblog.carmudi.com.ph/wp-content/uploads/2024/09/12194250/image-1058.jpg?resize=500x333';
      case 'Installation of Accessories Services':
        return 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRwwc4VlJ71PGy6Fjn9EadMvMN30F4f5OuL3R_QWXdnQ-Va0yDHBOzGQDVEYu106ZTimg&usqp=CAU';
      default:
        return 'https://via.placeholder.com/150'; // Default placeholder image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'Services',
          style:
              TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),
        ),
        backgroundColor: Colors.grey.shade300,
        elevation: 0,
        actions: const [],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            builder: (context) => ShopsDirectory(
                                serviceName: services[index].name),
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
                                borderRadius: const BorderRadius.only(
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
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      services[index].name,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 8.0),
                                  ],
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
