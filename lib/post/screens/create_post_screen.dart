import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../features/feed/data/models/item_model.dart';
import '../../features/feed/logic/feed_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _title = '';
  String _description = '';
  String _category = 'ทั่วไป';
  Uint8List? _postImage;
  String _postType = 'LOST';
  LatLng? _selectedLocation;

  final List<String> _categories = [
    'ทั่วไป',
    'อุปกรณ์ไอที/อิเล็กทรอนิกส์',
    'กระเป๋า/กระเป๋าสตางค์',
    'เอกสาร/บัตรประจำตัว',
    'กุญแจ',
    'เสื้อผ้า/เครื่องแต่งกาย',
  ];

  // 📷 ฟังก์ชันเลือกรูปภาพจากเครื่อง
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List imageBytes = await image.readAsBytes();
        setState(() {
          _postImage = imageBytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เลือกรูปภาพไม่สำเร็จ: $e')),
      );
    }
  }

  // 📍 ฟังก์ชันเปิดหน้าต่างปักหมุดบนแผนที่ (ปรับปรุงแก้ไขการทำงาน)
  Future<void> _pickLocationOnMap() async {
    LatLng currentPin = _selectedLocation ?? const LatLng(13.7563, 100.5018); // พิกัดเริ่มต้น (กทม.)
    GoogleMapController? mapController;

    final LatLng? result = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('แตะบนแผนที่เพื่อปักหมุด'),
              contentPadding: const EdgeInsets.all(8),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPin,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  onTap: (LatLng location) {
                    setDialogState(() {
                      currentPin = location;
                    });
                    // เลื่อนกล้องไปยังตำแหน่งที่ปักหมุดใหม่
                    mapController?.animateCamera(
                      CameraUpdate.newLatLng(location),
                    );
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected_pin'),
                      position: currentPin,
                      draggable: true,
                      onDragEnd: (newPosition) {
                        setDialogState(() {
                          currentPin = newPosition;
                        });
                      },
                    ),
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, currentPin),
                  child: const Text('ตกลง'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      final newItem = ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title,
        description: _description,
        category: _category,
        status: _postType == 'LOST' ? 'ของหาย' : 'พบของ',
        locationName: _selectedLocation != null
            ? 'ละติจูด: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ลองจิจูด: ${_selectedLocation!.longitude.toStringAsFixed(4)}'
            : 'ไม่ระบุสถานที่',
        imageUrl: _postImage != null
            ? 'https://picsum.photos/400/200?random=${DateTime.now().second}'
            : '',
        createdAt: DateTime.now(),
        userId: currentUserId,
        isMine: true,
        isResolved: false,
      );

      Provider.of<FeedProvider>(context, listen: false).addItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลงประกาศ "$_title" เรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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

              // 📷 ส่วนกดเลือกรูปภาพ
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _postImage != null
                      ? Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                _postImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _postImage = null;
                                });
                              },
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('กดเพื่อแนบรูปภาพสิ่งของ (ไม่บังคับ)',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

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

              // 📍 ปุ่มปักหมุดสถานที่
              OutlinedButton.icon(
                onPressed: _pickLocationOnMap,
                icon: Icon(
                  Icons.location_on,
                  color: _selectedLocation != null ? Colors.green : Colors.red,
                ),
                label: Text(
                  _selectedLocation != null
                      ? 'ปักหมุดแล้ว (${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)})'
                      : 'ระบุ/ปักหมุดสถานที่บนแผนที่',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),

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