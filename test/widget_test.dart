import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_4minus1/features/feed/presentation/pages/feed_page.dart';

void main() {
  testWidgets('FeedPage smoke test', (WidgetTester tester) async {
    // โหลดหน้า FeedPage สำหรับทดสอบ
    await tester.pumpWidget(
      const MaterialApp(
        home: FeedPage(),
      ),
    );

    // ตรวจสอบว่ามีชื่อแอปแสดงบน AppBar หรือไม่
    expect(find.text('Lost & Found Tracker'), findsOneWidget);
  });
}