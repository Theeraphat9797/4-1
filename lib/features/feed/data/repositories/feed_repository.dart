import '../models/item_model.dart';

class FeedRepository {
  List<ItemModel> getMockItems() {
    return [
      ItemModel(
        id: '1',
        title: 'กระเป๋าสตางค์สีดำ',
        description: 'ตกบริเวณโรงอาหารกลาง',
        category: 'กระเป๋า/กระเป๋าสตางค์',
        locationName: 'โรงอาหารกลาง',
        imageUrl: '',
        createdAt: DateTime.now(),
        status: 'ของหาย',
        userId: 'mock_user_1',
        isResolved: false,
        isMine: false,
      ),
      ItemModel(
        id: '2',
        title: 'กุญแจรถยนต์',
        description: 'พบบริเวณลานจอดรถ',
        category: 'กุญแจ',
        locationName: 'ลานจอดรถ A',
        imageUrl: '',
        createdAt: DateTime.now(),
        status: 'พบของ',
        userId: 'mock_user_2',
        isResolved: false,
        isMine: false,
      ),
    ];
  }
}