import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camping_kear/provider/CampingGearProvider.dart';
import 'package:camping_kear/model/CampingGear.dart';

class EditScreen extends StatefulWidget {
  final CampingGear gear;

  const EditScreen({super.key, required this.gear});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController quantityController;
  late TextEditingController weightController;
  late TextEditingController conditionController;
  String? selectedCategory; // ตัวแปรเก็บค่าหมวดหมู่ที่เลือก

  // รายการหมวดหมู่ที่ให้เลือก
  final List<String> categories = [
    'เต็นท์และที่นอน',
    'กระเป๋า',
    'อาหารและน้ำ',
    'ไฟ',
    'อุปกรณ์อื่นๆ'
  ];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.gear.name);
    selectedCategory = widget.gear.category; // กำหนดค่าหมวดหมู่เริ่มต้น
    quantityController = TextEditingController(text: widget.gear.quantity.toString());
    weightController = TextEditingController(text: widget.gear.weight.toString());
    conditionController = TextEditingController(text: widget.gear.condition);
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    weightController.dispose();
    conditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขอุปกรณ์',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              buildTextField(nameController, 'ชื่ออุปกรณ์', Icons.backpack),
              buildDropdownField(), // เพิ่ม Dropdown สำหรับเลือกหมวดหมู่
              buildTextField(quantityController, 'จำนวน', Icons.numbers, keyboardType: TextInputType.number),
              buildTextField(weightController, 'น้ำหนัก (kg)', Icons.scale, keyboardType: TextInputType.number),
              buildTextField(conditionController, 'สภาพของอุปกรณ์', Icons.info_outline),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.update),
                label: const Text('อัปเดตอุปกรณ์'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    var updatedGear = CampingGear(
                      id: widget.gear.id,
                      name: nameController.text,
                      category: selectedCategory!,
                      quantity: int.parse(quantityController.text),
                      weight: double.parse(weightController.text),
                      condition: conditionController.text,
                      isFavorite: widget.gear.isFavorite, // Preserve the isFavorite status
                      isPacked: widget.gear.isPacked, // Preserve the isPacked status
                    );
                    Provider.of<CampingGearProvider>(context, listen: false).updateGear(updatedGear);
                    Navigator.pop(context); // กลับไปยังหน้าหลักหลังจากบันทึกข้อมูลแล้ว
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณากรอก$label';
          }
          return null;
        },
      ),
    );
  }

  // Widget สำหรับ Dropdown เลือกหมวดหมู่
  Widget buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        decoration: InputDecoration(
          labelText: 'หมวดหมู่',
          prefixIcon: Icon(Icons.category, color: Colors.orange),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedCategory = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณาเลือกหมวดหมู่';
          }
          return null;
        },
      ),
    );
  }
}