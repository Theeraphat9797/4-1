import 'package:flutter/material.dart';
import '../data/models/item_model.dart';
import '../data/repositories/feed_repository.dart';

class FeedProvider extends ChangeNotifier {
  final FeedRepository _repository = FeedRepository();

  List<ItemModel> _items = [];
  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';
  String _selectedStatus = 'ทั้งหมด';

  List<ItemModel> get items => _items;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;

  void fetchItems() {
    _items = _repository.fetchItems();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  List<ItemModel> get filteredItems {
    return _items.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.locationName.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'ทั้งหมด' || item.category == _selectedCategory;
      final matchesStatus = _selectedStatus == 'ทั้งหมด' || item.status == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }
}