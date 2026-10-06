import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'my_posts_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  String _name = 'กำลังโหลด...';
  String _email = 'กำลังโหลด...';
  String _phone = '-';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // ==========================================
  // โหลดข้อมูล Profile จาก Firestore
  // ==========================================
  Future<void> _loadProfile() async {
    try {
      final data = await _authService.getUserProfile();

      if (!mounted) return;

      if (data != null) {
        setState(() {
          _name = data['name'] ?? '-';
          _email = data['email'] ?? '-';
          _phone = data['phone'] ?? '-';

          _isLoading = false;
        });
      } else {
        setState(() {
          _name = '-';
          _email = _authService.currentUser?.email ?? '-';
          _phone = '-';

          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('โหลดข้อมูลไม่สำเร็จ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // ออกจากระบบ
  // ==========================================
  Future<void> _logout() async {
    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ออกจากระบบไม่สำเร็จ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================
  // Dialog ยืนยัน Logout
  // ==========================================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ออกจากระบบ'),
          content: const Text(
            'คุณต้องการออกจากระบบหรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              child: const Text('ออกจากระบบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'โปรไฟล์',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ==========================================
                  // รูปโปรไฟล์
                  // ==========================================
                  const CircleAvatar(
                    radius: 65,
                    child: Icon(
                      Icons.person,
                      size: 70,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==========================================
                  // ชื่อ
                  // ==========================================
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==========================================
                  // Email
                  // ==========================================
                  Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==========================================
                  // เบอร์โทร
                  // ==========================================
                  Text(
                    _phone,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ==========================================
                  // แก้ไขโปรไฟล์
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const EditProfileScreen(),
                          ),
                        );

                        // กลับจากหน้าแก้ไขแล้วโหลดข้อมูลใหม่
                        _loadProfile();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'แก้ไขโปรไฟล์',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // โพสต์ของฉัน
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MyPostsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.article),
                      label: const Text(
                        'โพสต์ของฉัน',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==========================================
                  // Logout
                  // ==========================================
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}