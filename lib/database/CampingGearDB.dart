import 'dart:io';
import 'package:camping_kear/model/CampingGear.dart'; 
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class CampingGearDB { 
  final String dbName;

  CampingGearDB({required this.dbName});

  // ✅ เปิดฐานข้อมูล
  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbLocation = join(appDir.path, dbName);
    DatabaseFactory dbFactory = databaseFactoryIo;
    Database db = await dbFactory.openDatabase(dbLocation);
    return db;
  }

  // ✅ เพิ่มข้อมูลลงฐานข้อมูล (ป้องกัน category เป็น null)
  Future<int> insertDatabase(CampingGear gear) async { 
  var db = await openDatabase();
  var store = intMapStoreFactory.store('camping_gear'); 

  int keyID = await store.add(db, {
    'name': gear.name, 
    'category': gear.category?.trim() ?? "อุปกรณ์อื่นๆ",
    'quantity': gear.quantity,
    'weight': gear.weight,
    'condition': gear.condition?.trim() ?? "ปกติ",  // ✅ Fix condition
    'isFavorite': gear.isFavorite ?? false,
    'isPacked': gear.isPacked ?? false, 
  });

  db.close();
  return keyID;
}


  // ✅ โหลดข้อมูลทั้งหมดจากฐานข้อมูล
  Future<List<CampingGear>> loadAllData() async { 
  var db = await openDatabase();
  var store = intMapStoreFactory.store('camping_gear'); 
  var snapshot = await store.find(db, finder: Finder(sortOrders: [SortOrder('name', true)]));

  List<CampingGear> gears = [];

  for (var record in snapshot) {
    CampingGear gear = CampingGear(
      id: record.key as int,
      name: record['name'].toString(),
      category: (record['category']?.toString() ?? "อุปกรณ์อื่นๆ").trim(), // ✅ Fix category
      quantity: int.parse(record['quantity'].toString()),
      weight: double.parse(record['weight'].toString()),
      condition: record['condition']?.toString() ?? "ปกติ",  // ✅ Ensure condition is not null
      isFavorite: (record['isFavorite'] is bool) ? record['isFavorite'] as bool : false,
      isPacked: (record['isPacked'] is bool) ? record['isPacked'] as bool : false,
    );
    gears.add(gear);
  }

  db.close();
  return gears;
}


  // ✅ ลบข้อมูล
  Future<void> deleteData(CampingGear gear) async { 
    var db = await openDatabase();
    var store = intMapStoreFactory.store('camping_gear');
    await store.delete(db, finder: Finder(filter: Filter.equals(Field.key, gear.id)));
    db.close();
  }

  // ✅ อัปเดตข้อมูลอุปกรณ์
  Future<void> updateData(CampingGear gear) async { 
  var db = await openDatabase();
  var store = intMapStoreFactory.store('camping_gear');

  await store.record(gear.id!).update(db, {
    'name': gear.name, 
    'category': gear.category?.trim() ?? "อุปกรณ์อื่นๆ",
    'quantity': gear.quantity,
    'weight': gear.weight,
    'condition': gear.condition?.trim() ?? "ปกติ",  // ✅ Fix condition
    'isFavorite': gear.isFavorite ?? false,
    'isPacked': gear.isPacked ?? false,
  });

  db.close();
}


  // ✅ อัปเดตข้อมูลเก่าที่มี category เป็น null
  Future<void> fixNullCategories() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('camping_gear');
    var snapshot = await store.find(db);

    for (var record in snapshot) {
      var category = record['category'];
      if (category == null || category.toString().trim().isEmpty) {
        await store.record(record.key).update(db, {
          'category': "อุปกรณ์อื่นๆ",  // ✅ แก้ไขค่า null เป็น default
        });
      }
    }
    db.close();
  }

  // ✅ Debug: พิมพ์ข้อมูลทั้งหมดในฐานข้อมูล
  Future<void> printDatabase() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('camping_gear');
    var snapshot = await store.find(db);

    print("\n🔍 [DEBUG] ข้อมูลอุปกรณ์ทั้งหมดในฐานข้อมูล:");
    for (var record in snapshot) {
      print("ชื่อ: ${record['name']}, หมวดหมู่: ${record['category']}, น้ำหนัก: ${record['weight']}");
    }
    db.close();
  }
}
