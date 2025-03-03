import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:camping_kear/provider/CampingGearProvider.dart';
import 'package:camping_kear/screens/formScreen.dart';
import 'package:camping_kear/screens/editScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CampingGearProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Camping Gear Manager',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const MyHomePage(title: 'Camping Gear '),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ตัวแปร Filter และ Sorting
  String _selectedCategory = 'ทั้งหมด';
  String _selectedSort = 'ชื่อ (A-Z)';

  // ตัวแปรเก็บผลคำนวณน้ำหนักของอุปกรณ์ที่เตรียมแล้ว
  double _packedTotalWeight = 0;
  Map<String, double> _packedCategoryWeights = {};

  // กำหนดค่าน้ำหนักสูงสุดที่ยอมรับได้ (ตัวอย่าง 50 kg)
  final double maxWeight = 50;

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลจาก Provider
    Provider.of<CampingGearProvider>(context, listen: false).initData();
  }

  // ฟังก์ชันคำนวณน้ำหนักเฉพาะอุปกรณ์ที่เตรียมแล้ว (isPacked == true)
  void _calculatePackedWeight() {
    var provider = Provider.of<CampingGearProvider>(context, listen: false);
    var packedGears =
        provider.getGearList().where((gear) => gear.isPacked).toList();

    double total = 0;
    Map<String, double> catWeights = {};
    for (var gear in packedGears) {
      double gearTotal = gear.weight * gear.quantity;
      total += gearTotal;
      catWeights.update(gear.category, (value) => value + gearTotal,
          ifAbsent: () => gearTotal);
    }
    setState(() {
      _packedTotalWeight = total;
      _packedCategoryWeights = catWeights;
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CampingGearProvider>(context);
    var allGears = provider.getGearList();

    // 1. Filter ตามหมวดหมู่
    var filteredGears = _selectedCategory == 'ทั้งหมด'
        ? allGears
        : allGears.where((gear) => gear.category == _selectedCategory).toList();

    // 2. Sort ตามเงื่อนไขที่เลือก พร้อมนำ Favorite ขึ้นมาก่อน
    switch (_selectedSort) {
      case 'ชื่อ (A-Z)':
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case 'ชื่อ (Z-A)':
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
      case 'น้ำหนัก (มาก->น้อย)':
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return b.weight.compareTo(a.weight);
        });
        break;
      case 'น้ำหนัก (น้อย->มาก)':
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return a.weight.compareTo(b.weight);
        });
        break;
      case 'จำนวน (มาก->น้อย)':
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return b.quantity.compareTo(a.quantity);
        });
        break;
      case 'จำนวน (น้อย->มาก)':
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return a.quantity.compareTo(b.quantity);
        });
        break;
      default:
        filteredGears.sort((a, b) {
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }
          return 0;
        });
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          // ใส่ภาพพื้นหลังธีมเดินป่า
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              'assets/images/bgfr.jpg', // เปลี่ยนเป็นภาพของคุณ
              fit: BoxFit.cover,
            ),
          ),
          // ชั้นโปร่งใส
          Container(color: Colors.black.withOpacity(0.3)),
          // ส่วนแสดงเนื้อหา
          SafeArea(
            child: Column(
              children: [
                // ส่วนหัว Custom
                buildCustomHeader(allGears),
                // Dropdown Filter & Sort
                buildFilterSortRow(),
                // แสดงรายการอุปกรณ์
                Expanded(
                  child: filteredGears.isEmpty
                      ? Center(
                          child: Text(
                            'ไม่มีอุปกรณ์',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredGears.length,
                          itemBuilder: (context, index) {
                            var gear = filteredGears[index];
                            return buildGearCard(gear, provider);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      // FAB เพิ่มอุปกรณ์
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
        },
      ),
      // BottomNavigationBar สำหรับแสดงปุ่มคำนวณและผลลัพธ์น้ำหนักสัมภาระ
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white.withOpacity(0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _calculatePackedWeight,
              child: const Text("คำนวณน้ำหนักของอุปกรณ์ที่เตรียมแล้ว"),
            ),
            // แสดงผลลัพธ์เฉพาะเมื่อมีการคำนวณแล้ว (_packedTotalWeight > 0)
            if (_packedTotalWeight > 0) ...[
              Text("น้ำหนักสัมภาระทั้งหมด: ${_packedTotalWeight.toStringAsFixed(2)} kg",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ..._packedCategoryWeights.entries.map((entry) => Text(
                  "${entry.key}: ${entry.value.toStringAsFixed(2)} kg",
                  style: GoogleFonts.poppins())),
              if (_packedTotalWeight > maxWeight)
                Text("คำเตือน: น้ำหนักเกินกำหนด!",
                    style: GoogleFonts.poppins(
                        color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  // Header + ปุ่ม Search
  Widget buildCustomHeader(List allGears) {
    return Container(
      color: Colors.green.withOpacity(0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // ถ้ามี Drawer สามารถใส่ callback ได้
            },
          ),
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: GearSearchDelegate(allGears),
              );
            },
          ),
        ],
      ),
    );
  }

  // Row สำหรับ Filter & Sort
  Widget buildFilterSortRow() {
    return Container(
      color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedCategory,
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 255, 253, 253)),
              dropdownColor: const Color.fromARGB(255, 82, 82, 82),
              items: <String>[
                'ทั้งหมด',
                'เต็นท์และที่นอน',
                'กระเป๋า',
                'อาหารและน้ำ',
                'ไฟ',
                'อุปกรณ์อื่นๆ'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedSort,
              icon: const Icon(Icons.arrow_drop_down),
              isExpanded: true,
              style: GoogleFonts.poppins(fontSize: 14, color: const Color.fromARGB(255, 255, 255, 255)),
              dropdownColor: const Color.fromARGB(255, 66, 66, 66),
              items: <String>[
                'ชื่อ (A-Z)',
                'ชื่อ (Z-A)',
                'น้ำหนัก (มาก->น้อย)',
                'น้ำหนัก (น้อย->มาก)',
                'จำนวน (มาก->น้อย)',
                'จำนวน (น้อย->มาก)'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins()),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSort = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // การ์ดแสดงอุปกรณ์ที่รวมเช็คลิสต์ (isPacked) และปุ่มแก้ไข
  Widget buildGearCard(gear, CampingGearProvider provider) {
    return Dismissible(
      key: Key(gear.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        provider.deleteGear(gear);
      },
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: Colors.white70,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: ListTile(
          // Favorite
          leading: IconButton(
            icon: Icon(
              gear.isFavorite == true ? Icons.star : Icons.star_border,
              color: Colors.yellow[700],
            ),
            onPressed: () {
              gear.isFavorite = !gear.isFavorite;
              provider.updateGear(gear);
            },
          ),
          title: Text(
            gear.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'หมวด: ${gear.category} | จำนวน: ${gear.quantity} | น้ำหนัก: ${gear.weight} kg',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          // Row ที่มี Checkbox สำหรับเช็คลิสต์ (isPacked) และปุ่มแก้ไข
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: gear.isPacked,
                onChanged: (value) {
                  gear.isPacked = value!;
                  provider.updateGear(gear);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditScreen(gear: gear)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔍 Search Delegate
class GearSearchDelegate extends SearchDelegate {
  final List gearList;
  GearSearchDelegate(this.gearList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var results = gearList.where((gear) {
      return gear.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'ไม่พบข้อมูล',
          style: GoogleFonts.poppins(),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var gear = results[index];
        return ListTile(
          title: Text(gear.name),
          subtitle:
              Text('จำนวน: ${gear.quantity} | น้ำหนัก: ${gear.weight} kg'),
          onTap: () {
            close(context, gear);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
