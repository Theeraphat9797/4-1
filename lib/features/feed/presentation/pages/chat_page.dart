import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String postTitle;
  final String postUserId; // รับ ID เจ้าของโพสต์เข้ามาเช็ค

  const ChatPage({
    super.key,
    required this.postTitle,
    required this.postUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  // เช็คว่าผู้ใช้ปัจจุบันคือเจ้าของโพสต์หรือไม่
  bool get _isOwner {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return currentUserId != null && currentUserId == widget.postUserId;
  }

  void _sendMessage() {
    if (_isOwner) return; // บล็อกการส่งหากเป็นเจ้าของโพสต์
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isMe': true,
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('แชทติดต่อเจ้าของ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.postTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      _isOwner
                          ? 'คุณไม่สามารถส่งข้อความหาตัวเองได้'
                          : 'เริ่มต้นบทสนทนาเกี่ยวกับ\n"${widget.postTitle}"',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['isMe'] as bool;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                isMe ? Colors.deepPurple : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            msg['text'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // 🛑 ส่วนส่งข้อความ / แจ้งเตือนกรณีเป็นเจ้าของโพสต์
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _isOwner
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(
                        child: Text(
                          'นี่คือประกาศของคุณเอง ไม่สามารถส่งข้อความหาตัวเองได้',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'พิมพ์ข้อความ...',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.send, color: Colors.deepPurple),
                          onPressed: _sendMessage,
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