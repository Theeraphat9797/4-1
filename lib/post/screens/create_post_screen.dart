// # หน้าฟอร์มสร้างโพสต์หลัก
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/image_picker_widget.dart';
import 'select_location_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _category = 'ทั่วไป';
  Uint8List? _postImage; // ประเภท Uint8List รองรับการรันบน Desktop/Web
  String _postType = 'LOST'; // 'LOST' (ตามหาของ) หรือ 'FOUND' (แจ้งเจอของ)
  LatLng? _selectedLocation; // เพิ่มตัวแปรเก็บพิกัดสถานที่ที่เลือก

  final List<String> _categories = [
    'ทั่วไป',
    'อุปกรณ์ไอที/อิเล็กทรอนิกส์',
    'กระเป๋า/กระเป๋าสตางค์',
    'เอกสาร/บัตรประจำตัว',
    'กุญแจ',
    'เสื้อผ้า/เครื่องแต่งกาย',
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // ดึงค่ามาใช้งานเพื่อทดสอบ
      debugPrint('ประเภท: $_postType');
      debugPrint('ชื่อเรื่อง: $_title');
      debugPrint('หมวดหมู่: $_category');
      debugPrint('รายละเอียด: $_description');
      debugPrint('มีรูปภาพแนบ: ${_postImage != null}');
      debugPrint('พิกัดตำแหน่ง: $_selectedLocation');

      // TODO: ส่งข้อมูลไปยัง Backend / Firebase หรือ State Management
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('กำลังบันทึกโพสต์: $_title')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างประกาศแจ้งของหาย/พบเจอ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ประเภทประกาศ (ตามหาของ vs เจอของ)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'LOST', label: Text('ตามหาของหาย')),
                  ButtonSegment(value: 'FOUND', label: Text('พบเจอของ')),
                ],
                selected: {_postType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _postType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // อัปโหลดรูปภาพ
              ImagePickerWidget(
                onImageSelected: (bytes, name) {
                  setState(() {
                    _postImage = bytes;
                  });
                },
              ),
              const SizedBox(height: 16),

              // ชื่อสิ่งของ
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'ชื่อสิ่งของ *',
                  hintText: 'เช่น พวงกุญแจหมี, หูฟังไร้สาย',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อสิ่งของ';
                  }
                  return null;
                },
                onSaved: (value) => _title = value ?? '',
              ),
              const SizedBox(height: 16),

              // เลือกหมวดหมู่
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 16),

              // รายละเอียด
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียดเพิ่มเติม',
                  hintText: 'ระบุจุดสังเกต สี หรือบริเวณที่ทำหาย/พบเจอ...',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _description = value ?? '',
              ),
              const SizedBox(height: 16),

              // ปุ่มปักหมุดสถานที่
              OutlinedButton.icon(
                onPressed: () async {
                  // เปิดหน้า SelectLocationScreen และรอรับพิกัดกลับมา
                  final LatLng? location = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectLocationScreen(),
                    ),
                  );

                  if (location != null) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  }
                },
                icon: Icon(
                  Icons.location_on,
                  color: _selectedLocation != null ? Colors.green : Colors.red,
                ),
                label: Text(
                  _selectedLocation != null
                      ? 'เลือกตำแหน่งแล้ว (${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)})'
                      : 'ระบุ/ปักหมุดสถานที่บนแผนที่',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่มโพสต์
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ลงประกาศ', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
