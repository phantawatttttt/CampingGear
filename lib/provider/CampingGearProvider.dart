import 'package:camping_kear/model/CampingGear.dart'; 
import 'package:flutter/foundation.dart';
import 'package:camping_kear/database/CampingGearDB.dart'; 

class CampingGearProvider with ChangeNotifier {
  List<CampingGear> gears = []; 

  List<CampingGear> getGearList() { 
    return gears;
  }

 void initData() async {
  var db = CampingGearDB(dbName: 'camping_gear.db');
  gears = await db.loadAllData();
  
  // Debug: ตรวจสอบว่าหมวดหมู่ที่โหลดมาเป็นอะไร
  for (var gear in gears) {
    print("ชื่ออุปกรณ์: ${gear.name}, หมวดหมู่: ${gear.category}");
  }

  notifyListeners();
}


  void addGear(CampingGear gear) async { 
    var db = CampingGearDB(dbName: 'camping_gear.db');

    await db.insertDatabase(gear);
    gears = await db.loadAllData();
    notifyListeners();
  }

  void deleteGear(CampingGear gear) async { 
    var db = CampingGearDB(dbName: 'camping_gear.db');

    await db.deleteData(gear);
    gears = await db.loadAllData();
    notifyListeners();
  }

  void updateGear(CampingGear gear) async { 
    var db = CampingGearDB(dbName: 'camping_gear.db');

    await db.updateData(gear);
    gears = await db.loadAllData();
    notifyListeners();
  }
}
