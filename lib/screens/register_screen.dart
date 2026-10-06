import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // เรียกใช้ AuthService
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ป้องกันการกดปุ่มสมัครซ้ำระหว่างกำลังสมัคร
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================
  // สมัครสมาชิก
  // ==========================================
  Future<void> _register() async {
    // ตรวจสอบข้อมูลใน Form ก่อน
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // เริ่ม Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // เรียก Firebase สมัครสมาชิก
      await _authService.register(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      // ตรวจสอบว่า Widget ยังอยู่บนหน้าจอ
      if (!mounted) return;

      // แจ้งว่าสมัครสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สมัครสมาชิกสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );

      // กลับไปหน้า Login
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      // เอาข้อความ Exception ออกมาแสดง
      String message = e.toString();

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
      // หยุด Loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิก'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ==========================================
                // โลโก้
                // ==========================================
                Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.search,
                      size: 80,
                      color: Colors.blue,
                    );
                  },
                ),

                const SizedBox(height: 10),

                const Text(
                  'สร้างบัญชี Lost & Found',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'กรอกข้อมูลเพื่อสมัครสมาชิก',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================
                // ชื่อ
                // ==========================================
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ-นามสกุล',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อ-นามสกุล';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==========================================
                // Email
                // ==========================================
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'อีเมลมหาวิทยาลัย',
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

                // ==========================================
                // เบอร์โทร
                // ==========================================
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'เบอร์โทรศัพท์',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกเบอร์โทรศัพท์';
                    }

                    if (value.trim().length < 9) {
                      return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ==========================================
                // Password
                // ==========================================
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
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

                const SizedBox(height: 16),

                // ==========================================
                // ยืนยัน Password
                // ==========================================
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'ยืนยันรหัสผ่าน',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณายืนยันรหัสผ่าน';
                    }

                    if (value != _passwordController.text) {
                      return 'รหัสผ่านไม่ตรงกัน';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // ==========================================
                // ปุ่มสมัครสมาชิก
                // ==========================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'สมัครสมาชิก',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==========================================
                // กลับหน้า Login
                // ==========================================
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'มีบัญชีอยู่แล้ว? เข้าสู่ระบบ',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}