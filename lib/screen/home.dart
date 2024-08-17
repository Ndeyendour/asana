import 'package:asana/ProfilePage.dart';
import 'package:asana/screen/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importer le package Firebase Auth
import 'package:asana/const/colors.dart';
import 'package:asana/screen/add_note_screen.dart';
import 'package:asana/widgets/stream_note.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://todo-3aa81-default-rtdb.firebaseio.com/');

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  final _auth = FirebaseAuth.instance;
  User? _user;
  String? _fullName;
  bool show = true;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    if (_user != null) {
      _loadUserFullName();
    }
  }

  Future<void> _loadUserFullName() async {
    DatabaseReference userRef = rtdb.ref().child('users').child(_user!.uid);
    DataSnapshot snapshot = await userRef.get();
    if (snapshot.exists) {
      Map<dynamic, dynamic>? userData = snapshot.value as Map?;
      setState(() {
        _fullName = userData?['name'] ?? 'User';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColors,
      floatingActionButton: Visibility(
        visible: show,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const Add_creen(),
            ));
          },
          backgroundColor: custom_green,
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: _user?.photoURL != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(_user!.photoURL!),
                )
              : const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ProfilePage(),
            ));
          },
        ),
        title: _user != null
            ? Text(
                'Welcome, ${_fullName ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
        backgroundColor: custom_green,
      ),
      body: SafeArea(
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction == ScrollDirection.forward) {
              setState(() {
                show = true;
              });
            }
            if (notification.direction == ScrollDirection.reverse) {
              setState(() {
                show = false;
              });
            }
            return true;
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stream_note(false),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'isDone',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Stream_note(true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
