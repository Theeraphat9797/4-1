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
          _name = data['name'] ?? data['displayName'] ?? 'ผู้ใช้งาน';
          _email = data['email'] ?? _authService.currentUser?.email ?? '-';
          _phone = data['phone'] ?? '-';
          _isLoading = false;
        });
      } else {
        setState(() {
          _name = _authService.currentUser?.displayName ?? 'ผู้ใช้งาน';
          _email = _authService.currentUser?.email ?? '-';
          _phone = '-';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _name = _authService.currentUser?.displayName ?? 'ผู้ใช้งาน';
        _email = _authService.currentUser?.email ?? '-';
        _phone = '-';
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
          content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เบอร์โทร: $_phone',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        _loadProfile();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'แก้ไขโปรไฟล์',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyPostsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.article),
                      label: const Text(
                        'โพสต์ของฉัน',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}