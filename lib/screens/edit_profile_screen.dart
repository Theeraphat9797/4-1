import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  // ========================================
  // Firebase
  // ========================================

  final AuthService _authService = AuthService();

  // ========================================
  // ตัวเลือกรูปภาพ
  // ========================================

  final ImagePicker picker = ImagePicker();

  File? profileImage;

  // ========================================
  // Controller
  // ========================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  // ========================================
  // ตัวแปร Email
  // ========================================

  String email = '';

  // ========================================
  // Loading
  // ========================================

  bool isLoading = true;
  bool isSaving = false;

  // ========================================
  // เริ่มต้นหน้า
  // ========================================

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  // ========================================
  // โหลดข้อมูลจาก Firestore
  // ========================================

  Future<void> loadProfile() async {

    try {

      final data =
          await _authService.getUserProfile();

      final currentUser =
          _authService.currentUser;

      if (!mounted) return;

      setState(() {

        // ชื่อ
        nameController.text =
            data?['name'] ?? '';

        // เบอร์
        phoneController.text =
            data?['phone'] ?? '';

        // Email
        email =
            data?['email'] ??
            currentUser?.email ??
            '';

        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'โหลดข้อมูลไม่สำเร็จ: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ========================================
  // เลือกรูปจาก Gallery
  // ========================================

  Future<void> pickImage() async {

    final XFile? image =
        await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {

      setState(() {

        profileImage =
            File(image.path);
      });
    }
  }

  // ========================================
  // บันทึกข้อมูล
  // ========================================

  Future<void> saveProfile() async {

    // ตรวจสอบชื่อ
    if (nameController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกชื่อ-นามสกุล',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ตรวจสอบเบอร์
    if (phoneController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกเบอร์โทรศัพท์',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {

      // ====================================
      // บันทึกข้อมูลลง Firestore
      // ====================================

      await _authService.updateProfile(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (!mounted) return;

      // ====================================
      // แจ้งเตือน
      // ====================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'บันทึกข้อมูลสำเร็จ',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // ====================================
      // กลับหน้า Profile
      // ====================================

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'บันทึกข้อมูลไม่สำเร็จ: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ========================================
  // ทำลาย Controller
  // ========================================

  @override
  void dispose() {

    nameController.dispose();

    phoneController.dispose();

    super.dispose();
  }

  // ========================================
  // UI
  // ========================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ======================================
      // AppBar
      // ======================================

      appBar: AppBar(

        title: const Text(
          'แก้ไขโปรไฟล์',

          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        centerTitle: true,
      ),

      // ======================================
      // Body
      // ======================================

      body: isLoading

          // ==================================
          // Loading
          // ==================================

          ? const Center(
              child: CircularProgressIndicator(),
            )

          // ==================================
          // ข้อมูล
          // ==================================

          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(20),

              child: Column(
                children: [

                  // ==================================
                  // รูปโปรไฟล์
                  // ==================================

                  GestureDetector(

                    onTap: pickImage,

                    child: Stack(
                      children: [

                        CircleAvatar(

                          radius: 65,

                          backgroundImage:
                              profileImage != null
                                  ? FileImage(
                                      profileImage!,
                                    )
                                  : null,

                          child:
                              profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 70,
                                    )
                                  : null,
                        ),

                        // ปุ่มกล้อง
                        Positioned(
                          right: 0,
                          bottom: 0,

                          child: Container(

                            width: 42,
                            height: 42,

                            decoration:
                                const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ข้อความใต้รูป
                  const Text(
                    'แตะรูปเพื่อเปลี่ยนรูป',

                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================
                  // ชื่อ
                  // ==================================

                  TextField(

                    controller:
                        nameController,

                    decoration:
                        const InputDecoration(

                      labelText:
                          'ชื่อ-นามสกุล',

                      border:
                          OutlineInputBorder(),

                      prefixIcon:
                          Icon(
                        Icons.person,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================
                  // Email
                  // ==================================

                  TextField(

                    enabled: false,

                    controller:
                        TextEditingController(
                      text: email,
                    ),

                    decoration:
                        const InputDecoration(

                      labelText:
                          'อีเมล',

                      border:
                          OutlineInputBorder(),

                      prefixIcon:
                          Icon(
                        Icons.email,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================
                  // เบอร์โทรศัพท์
                  // ==================================

                  TextField(

                    controller:
                        phoneController,

                    keyboardType:
                        TextInputType.phone,

                    decoration:
                        const InputDecoration(

                      labelText:
                          'เบอร์โทรศัพท์',

                      border:
                          OutlineInputBorder(),

                      prefixIcon:
                          Icon(
                        Icons.phone,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================
                  // ปุ่มบันทึก
                  // ==================================

                  SizedBox(

                    width:
                        double.infinity,

                    height: 50,

                    child:
                        ElevatedButton.icon(

                      onPressed:
                          isSaving
                              ? null
                              : saveProfile,

                      icon:
                          isSaving

                              ? const SizedBox(
                                  width: 20,
                                  height: 20,

                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )

                              : const Icon(
                                  Icons.save,
                                ),

                      label:
                          Text(

                        isSaving
                            ? 'กำลังบันทึก...'
                            : 'บันทึก',

                        style:
                            const TextStyle(
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