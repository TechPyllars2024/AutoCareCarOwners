class Service {
  final String name;
  final String imageUrl;

  Service(this.name, this.imageUrl);
}

class CategoryList {
  // Map of categories to services
  static final Map<String, Service> categoryToService = {
    'Electrical Works': Service('Electrical Works',
        'https://i0.wp.com/www.profixautocare.com/wp-content/uploads/2020/05/image-27.png'),
    'Mechanical Works': Service('Mechanical Works',
        'https://static.wixstatic.com/media/24457cc02d954991b6aafb169233cc46.jpg/v1/fill/w_1480,h_986,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/24457cc02d954991b6aafb169233cc46.jpg'),
    'Air-conditioning Services': Service('Air-conditioning Services',
        'https://reddevilradiators.com.au/wp-content/uploads/2019/12/Screen-Shot-2019-12-14-at-1.28.18-pm.png'),
    'Paint and Body Works': Service('Paint and Body Works',
        'https://www.supersybon.com/wp-content/uploads/2023/04/1681353422-Metallic-Black-Car-Paint-The-Ultimate-Guide-for-Car-Enthusiasts.jpg'),
    'Car Wash': Service('Car Wash',
        'https://koronapos.com/wp-content/uploads/2022/01/car-wash-1200x675.png'),
    'Auto Detailing Services': Service('Auto Detailing Services',
        'https://the-car-wash.com/wp-content/uploads/2017/09/intext-cleaning.jpg'),
    'Roadside Assistance Services': Service('Roadside Assistance Services',
        'https://imgcdnblog.carmudi.com.ph/wp-content/uploads/2024/09/12194250/image-1058.jpg?resize=500x333'),
    'Installation of Accessories Services': Service(
        'Installation of Accessories Services',
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRwwc4VlJ71PGy6Fjn9EadMvMN30F4f5OuL3')
  };
}