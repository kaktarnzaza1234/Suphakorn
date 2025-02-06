import 'package:finalprojectsuphakorn/howto.dart';
import 'package:finalprojectsuphakorn/share.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'profilesetup.dart';

void main() {
  runApp(MyApp());
}

//Class state less สงั่ แสดงผลหนา้จอ
class MyApp extends StatelessWidget {
  const MyApp({super.key});
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '...',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(239, 245, 188, 2)),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  static const String routeName = '/homepage';
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  late DatabaseReference _userRef;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _selectedIndex = 0; // Track selected tab

  // List of widgets to display for each tab
  final List<Widget> _pages = [
    Center(child: Text('Home Screen')), // First tab (Home)
    Center(child: Text('Profile Screen')), // Second tab (Profile)
    Center(child: Text('Settings Screen')), // Third tab (Settings)
  ];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _userRef =
          FirebaseDatabase.instance.ref().child('userssuphakorn/${user.uid}');
      _fetchUserData();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      final snapshot = await _userRef.get();
      if (snapshot.exists) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      } else {
        setState(() {
          _userData = null;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _userData = null;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToProfileSetup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profilesetup(
          userData: _userData,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _fetchUserData(); // Refresh data after successful update
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('หน้าแรก: Home Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _userData?['prefix'] != null
                    ? '${_userData!['prefix']} ${_userData!['firstName']}${_userData!['lastName']}'
                    : 'ผู้ใช้: User',
              ),
              accountEmail: Text(_auth.currentUser?.email ?? 'อีเมล: Email'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _userData?['profileImage'] != null
                    ? NetworkImage(
                        _userData!['profileImage']) // URL รูปภาพจาก Firebase
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                child: _userData?['profileImage'] == null
                    ? Icon(Icons.camera_alt)
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home), // ไอคอนของเมนู
              title: Text('หน้าแรก:Home'),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('แก้ไขประวัติ: Update Profile'),
              onTap: () {
                _navigateToProfileSetup(); // Navigate to profile setup
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('ออกจากระบบ: Logout'),
              onTap: () async {
                await _auth.signOut(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[
          _selectedIndex], // Display the corresponding page based on selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
