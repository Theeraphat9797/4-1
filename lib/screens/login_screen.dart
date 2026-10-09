import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/feed/logic/feed_provider.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // เรียกใช้ AuthService
  final AuthService _authService = AuthService();

  // แสดง/ซ่อนรหัสผ่าน
  bool _obscurePassword = true;

  // สถานะกำลัง Login
  bool _isLoading = false;

  // ==========================================
  // Login
  // ==========================================
  Future<void> _login() async {
    // ตรวจสอบข้อมูลก่อน
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // เริ่ม Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Login ด้วย Firebase Authentication
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      // 2. สั่งให้ FeedProvider รีโหลดข้อมูลของ User คนใหม่ทันที
      Provider.of<FeedProvider>(context, listen: false).fetchItems();

      // 3. ล็อกอินสำเร็จ -> นำทางไปหน้า FeedPage (เอา const ออกเพื่อรองรับ Dynamic State)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const FeedPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();

      // เอาคำว่า Exception: ออก
      if (message.startsWith('Exception: ')) {
        message = message.replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เข้าสู่ระบบ'),
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 30),

                // =========================
                // LOGO
                // =========================
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.contain,

                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.search,
                        size: 100,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // =========================
                // ชื่อแอป
                // =========================
                const Text(
                  'Lost & Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'ระบบแจ้งเตือนและติดตามของหาย',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 35),

                // =========================
                // EMAIL
                // =========================
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,

                  decoration: const InputDecoration(
                    labelText: 'อีเมลมหาวิทยาลัย',
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    }

                    if (!value.contains('@')) {
                      return 'รูปแบบอีเมลไม่ถูกต้อง';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =========================
                // PASSWORD
                // =========================
                TextFormField(
                  controller: _passwordController,

                  obscureText: _obscurePassword,

                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    hintText: 'กรอกรหัสผ่าน',

                    border: const OutlineInputBorder(),

                    prefixIcon: const Icon(Icons.lock),

                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),

                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }

                    if (value.length < 6) {
                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // =========================
                // ปุ่มเข้าสู่ระบบ
                // =========================
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,

                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'เข้าสู่ระบบ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 10),

                // =========================
                // สมัครสมาชิก
                // =========================
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegisterScreen(),
                            ),
                          );
                        },

                  child: const Text(
                    'ยังไม่มีบัญชี? สมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}