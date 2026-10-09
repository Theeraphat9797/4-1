import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/feed/logic/feed_provider.dart';
import 'edit_post_screen.dart';

class MyPostsScreen extends StatelessWidget {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);
    final myItems = feedProvider.myItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('โพสต์ของฉัน'),
        centerTitle: true,
      ),
      body: myItems.isEmpty
          ? const Center(
              child: Text(
                'คุณยังไม่มีโพสต์ที่ลงไว้',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: myItems.length,
              itemBuilder: (context, index) {
                final item = myItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text('${item.status} • ${item.category}'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✏️ ปุ่มแก้ไข
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPostScreen(item: item),
                              ),
                            );
                          },
                        ),
                        // 🗑️ ปุ่มลบ
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('ยืนยันการลบโพสต์'),
                                content: Text('คุณต้องการลบ "${item.title}" ใช่หรือไม่?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('ยกเลิก'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      feedProvider.deleteItem(item.id);
                                    },
                                    child: const Text('ลบโพสต์'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}