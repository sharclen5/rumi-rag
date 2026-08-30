import 'package:flutter/material.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/loading.dart';

class EditUser extends StatefulWidget {
  final UserProfile targetUser;  // user yang mau diedit
  final String adminUid;         // uid admin yang lagi login
  const EditUser({
    super.key,
    required this.targetUser,
    required this.adminUid,
  });

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  final _formKey = GlobalKey<FormState>();

  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _border = Color(0xFF4A4646);
  static const _text = Color(0xFFF2DAB1);

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  late String _currentGender;
  late String _currentRole;

  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female'];
  final List<String> _roles = ['user', 'admin'];

  @override
  void initState() {
    super.initState();
    // prefill dari data user yang ada
    _firstNameController = TextEditingController(text: widget.targetUser.firstName);
    _lastNameController = TextEditingController(text: widget.targetUser.lastName);
    _emailController = TextEditingController(text: widget.targetUser.email);
    _phoneController = TextEditingController(text: widget.targetUser.phone);
    _currentGender = widget.targetUser.gender.isEmpty ? 'Male' : widget.targetUser.gender;
    _currentRole = widget.targetUser.role;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF363434),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brand, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit ${widget.targetUser.firstName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _text,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, size: 18, color: _text),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: _border, height: 1),

                // scrollable form
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            style: const TextStyle(color: _text),
                            decoration: _fieldDecoration('Nama Depan'),
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan nama depan' : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _lastNameController,
                            style: const TextStyle(color: _text),
                            decoration: _fieldDecoration('Nama Belakang'),
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan nama belakang' : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: _text),
                            decoration: _fieldDecoration('Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan email' : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _phoneController,
                            style: const TextStyle(color: _text),
                            decoration: _fieldDecoration('No. Telepon'),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            value: _currentGender,
                            decoration: _fieldDecoration('Jenis Kelamin'),
                            dropdownColor: const Color(0xFF2A2828),
                            style: const TextStyle(color: _text, fontSize: 14),
                            items: _genders.map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(g == 'Male' ? 'Laki-laki' : 'Perempuan'),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _currentGender = val!),
                          ),
                          const SizedBox(height: 14),

                          // role dropdown — dikasih warning visual kalo milih admin
                          DropdownButtonFormField<String>(
                            value: _currentRole,
                            decoration: _fieldDecoration('Role'),
                            dropdownColor: const Color(0xFF2A2828),
                            style: const TextStyle(color: _text, fontSize: 14),
                            items: _roles.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(r == 'admin' ? 'Admin' : 'User'),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _currentRole = val!),
                          ),

                          // warning kalo role di-set ke admin
                          if (_currentRole == 'admin') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade700,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: Colors.orange.shade400, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'User ini akan punya akses penuh ke Admin Dashboard.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          await DatabaseService(uid: widget.adminUid)
                              .updateUserAsAdmin(
                            widget.targetUser.uid,
                            _firstNameController.text.trim(),
                            _lastNameController.text.trim(),
                            _emailController.text.trim(),
                            _phoneController.text.trim(),
                            _currentGender,
                            _currentRole,
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),
                ),
              ],
            ),

            // loading overlay
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Loading()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}