import 'package:asana/const/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

final firebaseApp = Firebase.app();
final rtdb = FirebaseDatabase.instanceFor(
    app: firebaseApp,
    databaseURL: 'https://todo-3aa81-default-rtdb.firebaseio.com/');

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;

  User? user;
  DatabaseReference? userRef;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = rtdb.ref().child('users').child(user!.uid);
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (userRef != null) {
      DataSnapshot snapshot = await userRef!.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic>? userData = snapshot.value as Map?;
        if (userData != null) {
          _nameController.text = userData['name'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _profileImageUrl = userData['profileImageUrl'];
          setState(() {});
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    try {
      if (user != null) {
        if (_emailController.text.isNotEmpty) {
          await user!.updateEmail(_emailController.text);
        }
        if (_passwordController.text.isNotEmpty) {
          await user!.updatePassword(_passwordController.text);
        }

        String? profileImageUrl;
        if (_profileImage != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images/${user!.uid}.jpg');
          await storageRef.putFile(_profileImage!);
          profileImageUrl = await storageRef.getDownloadURL();
        }

        await userRef!.update({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil mis à jour avec succès !')),
        );
      }
    } catch (e) {
      print('Échec de la mise à jour du profil : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la mise à jour du profil : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        centerTitle: true,
        backgroundColor: custom_green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                  child: _profileImageUrl == null && _profileImage == null
                      ? Icon(Icons.account_circle, size: 100, color: Colors.grey)
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.photo_camera, color: Colors.blue),
                  onPressed: _pickImage,
                  iconSize: 30,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom Complet',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de Téléphone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de Passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _updateProfile(context),
              child: const Text('Sauvegarder les Modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
