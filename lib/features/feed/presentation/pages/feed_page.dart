import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/item_model.dart';
import '../../logic/feed_provider.dart';
import '../../../../screens/profile_screen.dart';
import '../../../../post/screens/create_post_screen.dart';
import 'chat_page.dart';
import 'post_detail_page.dart'; // 👈 นำเข้าไฟล์หน้ารายละเอียดโพสต์

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> bookmarkedPostIds = {};

  // 👈 แก้ไขหมวดหมู่ตรงนี้ให้ตรงกับหน้าสร้างโพสต์
  final List<String> categories = [
    'ทั่วไป',
    'อุปกรณ์ไอที/อิเล็กทรอนิกส์',
    'กระเป๋า/กระเป๋าสตางค์',
    'เอกสาร/บัตรประจำตัว',
    'กุญแจ',
    'เสื้อผ้า/เครื่องแต่งกาย',
  ];
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost & Found Feed', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'โปรไฟล์ของฉัน',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
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
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          final filteredPosts = feedProvider.filteredItems;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => feedProvider.setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อของ สถานที่ หรือคำสำคัญ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: feedProvider.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              feedProvider.setSearchQuery('');
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: ['ทั้งหมด', 'ของหาย', 'พบของ'].map((status) {
                    final isSelected = feedProvider.selectedStatus == status;
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
                        onSelected: (_) => feedProvider.setStatus(status),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: categories.map((category) {
                    final isSelected = feedProvider.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        selectedColor: Colors.deepPurple.shade100,
                        checkmarkColor: Colors.deepPurple,
                        onSelected: (_) {
                          if (isSelected && category != 'ทั้งหมด') {
                            feedProvider.setCategory('ทั้งหมด');
                          } else {
                            feedProvider.setCategory(category);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: RefreshIndicator(
                  color: Colors.deepPurple,
                  onRefresh: () async {
                    feedProvider.fetchItems();
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
                            final isLost = post.status == 'ของหาย' || post.status == 'LOST';
                            final isBookmarked = bookmarkedPostIds.contains(post.id);
                            final hasImage = post.imageUrl.isNotEmpty && !post.imageUrl.contains('picsum.photos');

                            // 👈 เพิ่ม InkWell ครอบ Card เมื่อกดจะเปิดไปยังหน้ารายละเอียดและคอมเมนต์
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailPage(post: post),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hasImage)
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                            child: Image.network(
                                              post.imageUrl,
                                              height: 180,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: post.isResolved
                                                    ? Colors.grey.shade700
                                                    : (isLost ? Colors.redAccent : Colors.green),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                post.isResolved ? 'ส่งคืนแล้ว' : (isLost ? 'ของหาย' : 'พบของ'),
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
                                                post.category,
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
                                                      bookmarkedPostIds.remove(post.id);
                                                    } else {
                                                      bookmarkedPostIds.add(post.id);
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
                                          if (!hasImage) ...[
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: post.isResolved
                                                        ? Colors.grey.shade700
                                                        : (isLost ? Colors.redAccent : Colors.green),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    post.isResolved ? 'ส่งคืนแล้ว' : (isLost ? 'ของหาย' : 'พบของ'),
                                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    post.category,
                                                    style: const TextStyle(color: Colors.black87, fontSize: 11),
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon: Icon(
                                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                                    color: isBookmarked ? Colors.deepPurple : Colors.grey.shade700,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (isBookmarked) {
                                                        bookmarkedPostIds.remove(post.id);
                                                      } else {
                                                        bookmarkedPostIds.add(post.id);
                                                      }
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          Text(
                                            post.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          if (post.description.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              post.description,
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  post.locationName,
                                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
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
                                                        postTitle: post.title,
                                                        postUserId: post.userId,
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
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('โพสต์ตามหา', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}