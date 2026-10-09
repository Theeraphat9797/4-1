import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/feed/data/models/item_model.dart';
import '../features/feed/logic/feed_provider.dart';

class EditPostScreen extends StatefulWidget {
  final ItemModel item;

  const EditPostScreen({super.key, required this.item});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _description;
  late String _category;
  late String _status;

  final List<String> _categories = [
    'ทั่วไป',
    'อุปกรณ์ไอที/อิเล็กทรอนิกส์',
    'กระเป๋า/กระเป๋าสตางค์',
    'เอกสาร/บัตรประจำตัว',
    'กุญแจ',
    'เสื้อผ้า/เครื่องแต่งกาย',
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.item.title;
    _description = widget.item.description;
    _category = widget.item.category;
    _status = widget.item.status;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedItem = ItemModel(
        id: widget.item.id,
        title: _title,
        description: _description,
        category: _category,
        status: _status,
        locationName: widget.item.locationName,
        imageUrl: widget.item.imageUrl,
        createdAt: widget.item.createdAt,
        userId: widget.item.userId,
        isMine: widget.item.isMine,
        isResolved: widget.item.isResolved,
      );

      await Provider.of<FeedProvider>(
        context,
        listen: false,
      ).updateItem(widget.item.id, updatedItem);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อัปเดตโพสต์เรียบร้อยแล้ว'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขโพสต์')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'ชื่อสิ่งของ *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'กรุณากรอกชื่อสิ่งของ'
                    : null,
                onSaved: (val) => _title = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : 'ทั่วไป',
                decoration: const InputDecoration(
                  labelText: 'หมวดหมู่',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'สถานะ',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ของหาย', child: Text('ของหาย')),
                  DropdownMenuItem(value: 'พบของ', child: Text('พบของ')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียดเพิ่มเติม',
                  border: OutlineInputBorder(),
                ),
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'บันทึกการแก้ไข',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
