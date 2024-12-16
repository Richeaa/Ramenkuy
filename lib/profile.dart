import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'menu.dart';
import 'order.dart';
import 'setaddress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finalmobileprogramming/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  String? username;
  String? profileImageBase64;
  String? userAddress;
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserAddress();
    user = _auth.currentUser;
    if (user != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? '';
          usernameController.text = username ?? 'Set Username';
          profileImageBase64 = userDoc['profileImageBase64'];
        });
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to load user data')),
      // );
    }
  }

  Future<void> _fetchUserAddress() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    
    setState(() {
      userAddress = userDoc.get('address');
    });
  } catch (e) {
    print("Error fetching user address: $e");
  }
}

  Future<void> _saveUsername() async {
  if (usernameController.text.isNotEmpty) {
    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .set({'username': usernameController.text}, SetOptions(merge: true));
      setState(() {
        username = usernameController.text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username saved successfully!')),
      );

      // Navigate back to MainRamen with the updated username
      Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainRamen(username: usernameController.text)),
      (route) => false,
      );

    } catch (e) {
      print('Error saving username: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save username')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username cannot be empty')),
    );
  }
}

  Future<void> _logout() async {
  await _auth.signOut();

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout Successful'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'You have been successfully logged out.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Continue'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      );
    },
  );
}

  Future<String> compressAndEncode(File imageFile) async {
    final image = img.decodeImage(await imageFile.readAsBytes());
    final resizedImage = img.copyResize(image!, width: 300);
    return base64Encode(img.encodeJpg(resizedImage));
  }

  Future<void> _saveProfilePicture(File imageFile) async {
    try {
      if (user == null) throw Exception('No user logged in');
      if (!imageFile.existsSync()) throw Exception('Image file does not exist');

      String base64Image = await compressAndEncode(imageFile);

      await _firestore
          .collection('users')
          .doc(user!.uid)
          .update({'profileImageBase64': base64Image});

      setState(() {
        profileImageBase64 = base64Image;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? photo =
                      await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    await _saveProfilePicture(File(photo.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? galleryImage =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (galleryImage != null) {
                    await _saveProfilePicture(File(galleryImage.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      // Confirm account deletion
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: TextStyle(color: Colors.red),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        },
      );

      // If user doesn't confirm, exit the method
      if (confirmDelete != true) return;

      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(currentUser.uid).delete();

      // Delete the user from Firebase Authentication
      await currentUser.delete();

      // Show success dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Account Deleted'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 80,
                ),
                SizedBox(height: 16),
                Text(
                  'Your account has been permanently deleted.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Continue'),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle any errors during account deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

    Future<bool> _showExitConfirmation(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Do you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay in the app
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Exit the app
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
    return shouldExit ?? false;
  }

  ButtonStyle commonButtonStyle(Color color) {
  return ElevatedButton.styleFrom(
    backgroundColor: color,
    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmation(context);
        return shouldExit; // Prevent exiting unless user confirms
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey,
                        backgroundImage: profileImageBase64 != null
                            ? MemoryImage(base64Decode(profileImageBase64!))
                            : null,
                        child: profileImageBase64 == null
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            // onTap: _pickImage,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5, // Adjust positioning as needed
                        right: 5,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            height: 45,
                            width: 45,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),  
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    hintText: 'Set Username',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    hintText: user?.email ?? 'email@gmail.com',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                    hintText: userAddress ?? 'Set Address', // Add a userAddress variable
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () {
                    // Navigate to SetAddressPage when tapped
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => SetAddressPage())
                    ).then((_) {
                      _fetchUserAddress();
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveUsername,
                  style: commonButtonStyle(Color(0xFF003366)),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _logout,
                  style: commonButtonStyle(Colors.red),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _deleteAccount,
                  style: commonButtonStyle(Colors.red),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color.fromARGB(255, 10, 60, 100),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
            Navigator.pushAndRemoveUntil(
              context,
                PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500), // Durasi animasi
                pageBuilder: (context, animation, secondaryAnimation) => MainRamen(username: username),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                opacity: animation,
                child: child,
              );
              },
              ),
              (route) => false, // Hapus semua halaman sebelumnya
            );
              break;
            case 1:
              Navigator.pushAndRemoveUntil(
              context,
                PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500), // Durasi animasi
                pageBuilder: (context, animation, secondaryAnimation) => const OrderPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                opacity: animation,
                child: child,
              );
              },
              ),
              (route) => false, // Hapus semua halaman sebelumnya
            );
              break;
            case 2:
              break;
          }
        },
      ),
      ),
    );
  }
}