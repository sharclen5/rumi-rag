import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rumi/models/user.dart';
import 'package:provider/provider.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/shared/bottomnavbar.dart';

class ProfileDetail extends StatefulWidget {
  final UserProfile user;
  final Function(int) onTabTapped;

  const ProfileDetail({
    super.key,
    required this.user,
    required this.onTabTapped,
  });

  @override
  State<ProfileDetail> createState() => _ProfileDetailState();
}

class _ProfileDetailState extends State<ProfileDetail> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  String? _selectedGender;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedGender = widget.user.gender.isEmpty ? null : widget.user.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveUpdate(String uid) async {
    setState(() => _isLoading = true);
    try {
      if (_imageFile != null) {
        final compressed = await FlutterImageCompress.compressWithFile(
          _imageFile!.path,
          minWidth: 600,
          minHeight: 600,
          quality: 90, // tambah kalau gambarnya pecah
        );
        if (compressed != null) {
          final base64Image =
              'data:image/jpg;base64,${base64Encode(compressed)}';
          await DatabaseService(uid: uid).updateProfilePicture(base64Image);
        }
      }
      await DatabaseService(uid: uid).updateUserProfile(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneController.text.trim(),
        _selectedGender ?? '',
        _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Loading();
    final user = Provider.of<User?>(context, listen: false);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 113, 222, 255),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 0, 138, 218),
        foregroundColor: Colors.white,
        title: const Text("Update Profile"),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 113, 222, 255), // ✏️ top color
              Color.fromARGB(255, 220, 235, 240),
            ],
            stops: [0.0, 1.0],
          ),
        ),

        child: SingleChildScrollView(
          // padding: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            children: [
              ProfileDetailPic(
                imageFile: _imageFile,
                photoUrl: widget.user.photoUrl,
                imageUploadBtnPress: _showImageSourcePicker,
              ),
              const Divider(),
              Form(
                child: Column(
                  children: [
                    SizedBox(height: 20.0),
                    UserInfoEditField(
                      text: "First Name",
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    UserInfoEditField(
                      text: "Last Name",
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    UserInfoEditField(
                      text: "Email",
                      child: TextFormField(
                        controller: _emailController,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    UserInfoEditField(
                      text: "Phone",
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration(),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    UserInfoEditField(
                      text: "Gender",
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: _inputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedGender = value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F6F9),
                        foregroundColor: const Color(0xFF757575),
                        minimumSize: const Size(double.infinity, 48),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 0, 138, 218),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        if (user != null) _saveUpdate(user.uid);
                      },
                      child: const Text("Save Update"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          Navigator.pop(context);
          widget.onTabTapped(index);
        },
        photoUrl: widget.user.photoUrl,
      ),
    );
  }
}

class ProfileDetailPic extends StatelessWidget {
  const ProfileDetailPic({
    super.key,
    this.imageUploadBtnPress,
    this.imageFile,
    this.photoUrl,
  });

  final File? imageFile;
  final String? photoUrl;
  final VoidCallback? imageUploadBtnPress;

  @override
  Widget build(BuildContext context) {
    ImageProvider _resolveImage() {
      if (imageFile != null) return FileImage(imageFile!);
      if (photoUrl != null && photoUrl!.startsWith('data:image')) {
        return MemoryImage(base64Decode(photoUrl!.split(',').last));
      }
      if (photoUrl != null) return NetworkImage(photoUrl!);
      return const AssetImage('assets/images/placeholder.jpg');
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(radius: 50, backgroundImage: _resolveImage()),
          InkWell(
            onTap: imageUploadBtnPress,
            child: const CircleAvatar(
              radius: 13,
              backgroundColor: Color.fromARGB(255, 0, 138, 218),
              child: Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class UserInfoEditField extends StatelessWidget {
  const UserInfoEditField({super.key, required this.text, required this.child});

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }
}
