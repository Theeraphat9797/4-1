import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/item_model.dart';
import 'chat_page.dart';

class PostDetailPage extends StatefulWidget {
  final ItemModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  // ฟังก์ชันส่งความคิดเห็นลง Firestore
  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || currentUser == null || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
            'text': text,
            'userId': currentUser!.uid,
            'userName':
                currentUser!.displayName ??
                currentUser!.email?.split('@').first ??
                'ผู้ใช้งาน',
            'createdAt': FieldValue.serverTimestamp(),
          });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งความคิดเห็น: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLost =
        widget.post.status == 'ของหาย' || widget.post.status == 'LOST';
    final hasImage =
        widget.post.imageUrl.isNotEmpty &&
        !widget.post.imageUrl.contains('picsum.photos');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายละเอียดโพสต์',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // ส่วนแสดงรายละเอียดโพสต์ + คอมเมนต์
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. รูปภาพโพสต์ (ถ้ามี)
                  if (hasImage)
                    Image.network(
                      widget.post.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),

                  // 2. ข้อมูลรายละเอียดโพสต์
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: widget.post.isResolved
                                    ? Colors.grey.shade700
                                    : (isLost
                                          ? Colors.redAccent
                                          : Colors.green),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.post.isResolved
                                    ? 'ส่งคืนแล้ว'
                                    : (isLost ? 'ของหาย' : 'พบของ'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.post.category,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.post.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.post.description,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.post.locationName,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    postTitle: widget.post.title,
                                    postUserId: widget.post.userId,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.chat_bubble_outline,
                              size: 16,
                            ),
                            label: const Text('แชทติดต่อเจ้าของ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(color: Colors.deepPurple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 8, color: Color(0xFFF0F0F0)),

                  // 3. หัวข้อส่วนความคิดเห็น
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'ความคิดเห็น',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 4. รายการคอมเมนต์ (ดึงจาก StreamBuilder)
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(widget.post.id)
                        .collection('comments')
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'ยังไม่มีความคิดเห็น มาเป็นคนแรกกันเลย!',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final data =
                              comments[index].data() as Map<String, dynamic>;
                          final commentUserId = data['userId'] ?? '';
                          final commentUserName =
                              data['userName'] ?? 'ผู้ใช้งาน';
                          final commentText = data['text'] ?? '';

                          // 👈 เช็คว่าเป็นเจ้าของโพสต์หรือไม่
                          final bool isPostOwner =
                              commentUserId == widget.post.userId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isPostOwner
                                      ? Colors.deepPurple
                                      : Colors.grey.shade300,
                                  child: Icon(
                                    Icons.person,
                                    size: 20,
                                    color: isPostOwner
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: isPostOwner
                                          ? Colors.deepPurple.shade50
                                          : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isPostOwner
                                          ? Border.all(
                                              color: Colors.deepPurple.shade200,
                                            )
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              commentUserName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isPostOwner
                                                    ? Colors.deepPurple
                                                    : Colors.black87,
                                              ),
                                            ),
                                            // 👈 ถ้าเป็นเจ้าของโพสต์ จะแสดงป้ายระบุ
                                            if (isPostOwner) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Text(
                                                  'เจ้าของโพสต์',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          commentText,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ช่องพิมพ์ส่งคอมเมนต์ด้านล่าง
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'เขียนความคิดเห็น...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.deepPurple,
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.deepPurple,
                          ),
                    onPressed: _sendComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
