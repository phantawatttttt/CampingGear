import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camping_kear/main.dart';

void main() {
  testWidgets('แสดงข้อความ "ไม่มีอุปกรณ์" เมื่อไม่มีข้อมูล', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // ตรวจสอบว่ามีข้อความ "ไม่มีอุปกรณ์"
    expect(find.text('ไม่มีอุปกรณ์'), findsOneWidget);
  });

  testWidgets('สามารถเปิดหน้าเพิ่มอุปกรณ์ได้', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // กดปุ่ม + เพื่อเปิดหน้าเพิ่มอุปกรณ์
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // ตรวจสอบว่ามี TextField ให้กรอกข้อมูล
    expect(find.byType(TextFormField), findsWidgets);
  });
}
