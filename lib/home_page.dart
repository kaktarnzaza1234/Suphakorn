import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';

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
              leading: Icon(Icons.logout),
              title: Text('ออกจากระบบ: Logout'),
              onTap: () async {
                await _auth.signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'ยินดีต้อนรับ: Welcome, ${_userData?['firstName'] ?? 'ผู้ใช้: User'}!',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
