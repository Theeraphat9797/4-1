import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/item_model.dart';

class FeedProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ItemModel> _items = [];
  String _searchQuery = '';
  String _selectedCategory = 'ทั้งหมด';
  String _selectedStatus = 'ทั้งหมด';

  List<ItemModel> get items => _items;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;

  void fetchItems() {
    final currentUserId = _auth.currentUser?.uid ?? '';

    _firestore.collection('posts').snapshots().listen((snapshot) {
      try {
        final loadedItems = snapshot.docs.map((doc) {
          final data = doc.data();
          return ItemModel.fromMap(data, doc.id, currentUserId);
        }).toList();

        loadedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _items = loadedItems;
        notifyListeners();
      } catch (e) {
        debugPrint('Error mapping items: $e');
      }
    }, onError: (error) {
      debugPrint('Firestore Listen Error: $error');
    });
  }

  List<ItemModel> get myItems {
    final currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return [];
    return _items.where((item) => item.userId == currentUserId).toList();
  }

  // ➕ เพิ่มโพสต์
  Future<void> addItem(ItemModel newItem) async {
    final currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    final data = newItem.toMap(currentUserId);
    data['createdAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('posts').add(data);
  }

  // ✏️ แก้ไขโพสต์ (เฉพาะเจ้าของ)
  Future<void> updateItem(String docId, ItemModel updatedItem) async {
    final currentUserId = _auth.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) return;

    final data = updatedItem.toMap(currentUserId);
    data.remove('createdAt'); // ไม่ทับเวลาสร้างเดิม

    await _firestore.collection('posts').doc(docId).update(data);
  }

  // 🗑️ ลบโพสต์ (เฉพาะเจ้าของ)
  Future<void> deleteItem(String docId) async {
    await _firestore.collection('posts').doc(docId).delete();
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