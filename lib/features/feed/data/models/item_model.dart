class ItemModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String locationName;
  final String imageUrl;
  final DateTime createdAt;
  final String status; // 'LOST' หรือ 'FOUND'

  ItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.locationName,
    required this.imageUrl,
    required this.createdAt,
    required this.status,
  });
}