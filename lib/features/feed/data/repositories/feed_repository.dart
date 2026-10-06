import '../models/item_model.dart';

class FeedRepository {
  // Mock Data สำหรับทดสอบก่อนดึง API จริง
  List<ItemModel> fetchItems() {
    return [
      ItemModel(
        id: '1',
        title: 'ลืม iPad Air สีสเปซเกรย์',
        description: 'ลืมไว้ที่โรงอาหารกลาง อาคาร C',
        category: 'ไอที/อิเล็กทรอนิกส์',
        locationName: 'โรงอาหารกลาง',
        imageUrl: 'https://picsum.photos/200',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'LOST',
      ),
      ItemModel(
        id: '2',
        title: 'เจอกระเป๋าสตางค์สีดำ',
        description: 'พบบริเวณโต๊ะหินอ่อน คณะวิศวกรรมศาสตร์',
        category: 'กระเป๋า/เป้',
        locationName: 'คณะวิศวกรรมศาสตร์',
        imageUrl: 'https://picsum.photos/201',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'FOUND',
      ),
    ];
  }
}