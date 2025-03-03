class CampingGear {
  int? id;
  String name;       // ชื่ออุปกรณ์
  String category;   // หมวดหมู่ เช่น เต็นท์, กระเป๋า, ไฟฉาย
  int quantity;      // จำนวนที่มี
  double weight;     // น้ำหนัก (กิโลกรัม)
  String condition;  // สภาพของอุปกรณ์ เช่น ใหม่, ใช้งานได้, เสียหาย
  bool isFavorite;
  bool isPacked;  

  CampingGear({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.weight,
    required this.condition,
    this.isFavorite = false,
    this.isPacked = false,
  });


  // ตรวจสอบว่าข้อมูลถูกต้องก่อนแปลงเป็น JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category ?? "อุปกรณ์อื่นๆ", // ถ้า category เป็น null ให้ใช้ค่า default
      'quantity': quantity,
      'weight': weight,
      'isFavorite': isFavorite ? 1 : 0,
      'isPacked': isPacked,
    };
  }

 factory CampingGear.fromMap(Map<String, dynamic> map) {
    return CampingGear(
      id: map['id'],
      name: map['name'],
      category: map['category'] ?? "อุปกรณ์อื่นๆ", // ป้องกันค่า null
      quantity: map['quantity'],
      weight: map['weight'],
      condition: map['condition'] ?? "ปกติ", // เพิ่ม condition และกำหนดค่าเริ่มต้น
      isFavorite: (map['isFavorite'] is bool) ? map['isFavorite'] as bool : false,
      isPacked: (map['isPacked'] is bool) ? map['isPacked'] as bool : false, // ➜ ADDED: อ่านค่าสถานะ isPacked
    );
}

}