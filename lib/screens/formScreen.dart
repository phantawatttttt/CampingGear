import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camping_kear/provider/CampingGearProvider.dart';
import 'package:camping_kear/model/CampingGear.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final weightController = TextEditingController();
  final conditionController = TextEditingController();

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
    selectedCategory =
        categories.first; // กำหนดค่าหมวดหมู่เริ่มต้นให้เป็นตัวแรก
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
          'เพิ่มอุปกรณ์เดินป่า',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        // ป้องกัน UI ล้น
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField(nameController, 'ชื่ออุปกรณ์', Icons.backpack),
              buildDropdownField(), // ใช้ Dropdown แทน TextField สำหรับหมวดหมู่
              buildTextField(quantityController, 'จำนวน', Icons.numbers,
                  keyboardType: TextInputType.number),
              buildTextField(weightController, 'น้ำหนัก (kg)', Icons.scale,
                  keyboardType: TextInputType.number),
              buildTextField(
                  conditionController, 'สภาพของอุปกรณ์', Icons.info_outline),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('เพิ่มอุปกรณ์'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      var provider = Provider.of<CampingGearProvider>(context,
                          listen: false);
                      CampingGear gear = CampingGear(
                        name: nameController.text,
                        category: selectedCategory ??
                            categories.first, // ใช้ค่าหมวดหมู่ที่เลือก
                        quantity: int.parse(quantityController.text),
                        weight: double.parse(weightController.text),
                        condition: conditionController.text,
                      );
                      provider.addGear(gear);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget สำหรับสร้าง TextField ปกติ
  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
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
        decoration: InputDecoration(
          labelText: 'หมวดหมู่',
          prefixIcon: const Icon(Icons.category, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: selectedCategory, // กำหนดค่าที่เลือกเริ่มต้น
        items: categories.map((category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
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
