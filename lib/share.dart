import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean Energy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: sharepage(),
    );
  }
}

class sharepage extends StatefulWidget {
  @override
  State<sharepage> createState() => _SharePageState();
}

class _SharePageState extends State<sharepage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController energynameController = TextEditingController();
  final TextEditingController energydesController = TextEditingController();
  final categories = ['Wind', 'Water', 'Fire', 'Earth'];
  String? selectedCategory;
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _uploadedImageUrl;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> saveEnergyToDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      DatabaseReference _dbRef =
          FirebaseDatabase.instance.ref('cleanenergysuphakorn');
      String newKey = _dbRef.push().key ?? '';

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(newKey);
      }

      Map<String, dynamic> energyData = {
        'name': energynameController.text,
        'description': energydesController.text,
        'category': selectedCategory,
        'imageUrl': imageUrl ?? '',
      };

      await _dbRef.child(newKey).set(energyData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
      );

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  Future<String?> _uploadImage(String key) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cleanenergyimagessuphakorn/$key.jpg');

      if (kIsWeb) {
        Uint8List imageData = await _selectedImage!.readAsBytes();
        await storageRef.putData(imageData);
      } else {
        File imageFile = File(_selectedImage!.path);
        await storageRef.putFile(imageFile);
      }

      return await storageRef.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      energynameController.clear();
      energydesController.clear();
      selectedCategory = null;
      _selectedImage = null;
      _uploadedImageUrl = null;
    });
  }

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('เพิ่มข้อมูลพลังงานสะอาด'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: energynameController,
                    decoration: InputDecoration(labelText: 'ชื่อพลังงาน'),
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกชื่อพลังงาน' : null,
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(labelText: 'ประเภทพลังงาน'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                          value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedCategory = value),
                    validator: (value) =>
                        value == null ? 'กรุณาเลือกประเภทพลังงาน' : null,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: energydesController,
                    decoration: InputDecoration(labelText: 'รายละเอียดพลังงาน'),
                    validator: (value) =>
                        value!.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('ถ่ายรูป: Take a Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text(
                                  'เลือกรูปจากแกลอรี่: Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(File(_selectedImage!.path))
                          : (_uploadedImageUrl != null
                              ? NetworkImage(_uploadedImageUrl!)
                              : null),
                      child: _selectedImage == null && _uploadedImageUrl == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: saveEnergyToDatabase,
                    child: Text('บันทึกข้อมูล'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> cleanenergysuphakorn = [];

  DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('cleanenergysuphakorn');

  Future<void> fetchProducts() async {
    try {
      // ดึงข้อมูลจาก Realtime Database
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedCleanenergy = [];
        // วนลูปเพื่อแปลงข้อมูลเป็น Map
        snapshot.children.forEach((child) {
          Map<String, dynamic> cleanenergysuphakorn =
              Map<String, dynamic>.from(child.value as Map);
          cleanenergysuphakorn['key'] =
              child.key; // เก็บ key สําหรับการอ้างอิง (เช่นการแก้ไข/ลบ)
          loadedCleanenergy.add(cleanenergysuphakorn);
        });
        // อัปเดต state เพื่อแสดงข้อมูล
        setState(() {
          cleanenergysuphakorn = loadedCleanenergy;
        });
        print(
            "จํานวนรายการสินค้าทั้งหมด: ${cleanenergysuphakorn.length} รายการ"); // Debugging
      } else {
        print("ไม่พบรายการสินค้าในฐานข้อมูล"); // กรณีไม่มีข้อมูล
      }
    } catch (e) {
      print("Error loading products: $e"); // แสดงข้อผิดพลาดทาง Console
      // แสดง Snackbar เพื่อแจ้งเตือนผู้ใช้
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(); // เรียกใช้เมื่อ Widget ถูกสร้าง
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clean Energy')),
      body: cleanenergysuphakorn.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cleanenergysuphakorn.length,
              itemBuilder: (context, index) {
                final product = cleanenergysuphakorn[index];
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product['imageUrl'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      product['name'],
                    ),
                    subtitle: Text(
                      product['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // รอใส่โค้ดเมื่อกด
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
