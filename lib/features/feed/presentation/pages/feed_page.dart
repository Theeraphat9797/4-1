import 'package:flutter/material.dart';
import 'chat_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String searchQuery = '';
  String selectedCategory = 'ทั้งหมด';
  String selectedStatus = 'ทั้งหมด';

  final TextEditingController _searchController = TextEditingController();
  final Set<int> bookmarkedPostIds = {};

  final List<String> categories = [
    'ทั้งหมด',
    'กระเป๋า/ของใช้',
    'ไอที/อิเล็กทรอนิกส์',
    'กุญแจ/บัตร',
    'เอกสาร/หนังสือ',
  ];

  final List<Map<String, dynamic>> allPosts = [
    {
      'id': 1,
      'title': 'กระเป๋าสตางค์หนังสีดำ หายแถวตึกเรียนรวม',
      'type': 'lost',
      'category': 'กระเป๋า/ของใช้',
      'location': 'ตึก ECC, สจล.',
      'time': '10 นาทีที่แล้ว',
      'imageUrl': 'https://picsum.photos/400/200?random=1',
      'isResolved': false,
    },
    {
      'id': 2,
      'title': 'พบพวงกุญแจโดราเอมอน ตกอยู่หน้าคาเฟ่',
      'type': 'found',
      'category': 'กุญแจ/บัตร',
      'location': 'โรงกะทะ, สจล.',
      'time': '1 ชั่วโมงที่แล้ว',
      'imageUrl': 'https://picsum.photos/400/200?random=2',
      'isResolved': true,
    },
    {
      'id': 3,
      'title': 'หูฟัง AirPods Pro พร้อมเคสสีเขียว',
      'type': 'lost',
      'category': 'ไอที/อิเล็กทรอนิกส์',
      'location': 'สำนักหอสมุดกลาง',
      'time': '3 ชั่วโมงที่แล้ว',
      'imageUrl': 'https://picsum.photos/400/200?random=3',
      'isResolved': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredPosts = allPosts.where((post) {
      final title = post['title'].toString().toLowerCase();
      final location = post['location'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      final matchesSearch = title.contains(query) || location.contains(query);

      final matchesCategory = selectedCategory == 'ทั้งหมด' ||
          post['category'] == selectedCategory;

      final matchesStatus = selectedStatus == 'ทั้งหมด' ||
          (selectedStatus == 'ของหาย' && post['type'] == 'lost') ||
          (selectedStatus == 'พบของ' && post['type'] == 'found');

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('คุณบันทึกไว้ทั้งหมด ${bookmarkedPostIds.length} รายการ')),
                  );
                },
              ),
              if (bookmarkedPostIds.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      '${bookmarkedPostIds.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่อของ สถานที่ หรือคำสำคัญ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
          ),

          // 2. Choice Chips (สถานะ)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: ['ทั้งหมด', 'ของหาย', 'พบของ'].map((status) {
                final isSelected = selectedStatus == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => selectedStatus = status),
                  ),
                );
              }).toList(),
            ),
          ),

          // 3. Filter Chips (หมวดหมู่)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple.shade100,
                    checkmarkColor: Colors.deepPurple,
                    onSelected: (_) {
                      setState(() {
                        if (selectedCategory == category && category != 'ทั้งหมด') {
                          selectedCategory = 'ทั้งหมด';
                        } else {
                          selectedCategory = category;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // 4. Feed List
          Expanded(
            child: RefreshIndicator(
              color: Colors.deepPurple,
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                setState(() {});
              },
              child: filteredPosts.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 72, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'ไม่พบรายการที่คุณค้นหา',
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        final isLost = post['type'] == 'lost';
                        final isBookmarked = bookmarkedPostIds.contains(post['id']);
                        final isResolved = post['isResolved'] ?? false;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      post['imageUrl'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isResolved
                                            ? Colors.grey.shade700
                                            : (isLost ? Colors.redAccent : Colors.green),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isResolved
                                            ? 'ส่งคืนแล้ว'
                                            : (isLost ? 'ของหาย' : 'พบของ'),
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 50,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        post['category'],
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white.withOpacity(0.85),
                                      radius: 18,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(
                                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                          color: isBookmarked ? Colors.deepPurple : Colors.grey.shade700,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isBookmarked) {
                                              bookmarkedPostIds.remove(post['id']);
                                            } else {
                                              bookmarkedPostIds.add(post['id']);
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post['title'],
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(post['location'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                        const Spacer(),
                                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(post['time'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChatPage(
                                                  postTitle: post['title'],
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                          label: const Text('ติดต่อเจ้าของ'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.deepPurple,
                                            side: const BorderSide(color: Colors.deepPurple),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กำลังเปิดหน้าสร้างโพสต์...')),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('โพสต์ตามหา', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}