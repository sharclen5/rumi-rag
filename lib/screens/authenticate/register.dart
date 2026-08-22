import 'package:flutter/material.dart';
import 'package:rumi/services/auth.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/shared/rag_badge.dart';

class Register extends StatefulWidget {
  final void Function({bool fromRegister}) toggleView;

  const Register({super.key, required this.toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool loading = false;

  // CHANGED: warna dark palette
  static const _bg = Color(0xFF1A1A1A);
  static const _fieldBg = Color(0xFF2A2828);
  static const _fieldBorder = Color(0xFF4A4646);
  static const _fieldText = Color(0xFFF2DAB1);
  static const _brand = Color.fromARGB(255, 144, 121, 84);

  String email = '';
  String firstName = '';
  String lastName = '';
  String phone = '';
  String gender = '';
  String password = '';
  String error = '';
  bool _obscurePassword = true;

  // CHANGED: custom field decoration biar ga perlu import constants.dart lagi
  InputDecoration _fieldDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Poppins'),
      filled: true,
      fillColor: _fieldBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1.6, color: _brand),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1.6, color: Colors.red.shade300),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final systemNavInset = MediaQuery.of(context).padding.bottom;
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: _bg, // CHANGED: was Colors.white
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 1, top: 1),
                    child: SizedBox(
                      width: 500,
                      height: 457,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Image.asset(
                            "assets/images/vector-3.png",
                            width: 413,
                            height: 457,
                          ),
                          Positioned(
                            top: 25,
                            right: 12,
                            child: RagBadge(size: RagBadgeSize.large),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Register',
                            style: TextStyle(
                              color:
                                  _fieldText, // CHANGED: was Color(0xFF363434)
                              fontSize: 27,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 25),
                          // email
                          TextFormField(
                            controller: _emailController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color:
                                  _fieldText, // CHANGED: was Color(0xFF393939)
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _fieldDecoration('Email'),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter an email'
                                : null,
                            onChanged: (val) => setState(() => email = val),
                          ),
                          const SizedBox(height: 30),
                          // first name
                          TextFormField(
                            controller: _firstNameController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: _fieldText, // CHANGED
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _fieldDecoration('First Name'),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter your first name'
                                : null,
                            onChanged: (val) => setState(() => firstName = val),
                          ),
                          const SizedBox(height: 30),
                          // last name
                          TextFormField(
                            controller: _lastNameController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: _fieldText, // CHANGED
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _fieldDecoration('Last Name'),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter your last name'
                                : null,
                            onChanged: (val) => setState(() => lastName = val),
                          ),
                          const SizedBox(height: 30),
                          // gender
                          DropdownButtonFormField<String>(
                            value: gender.isEmpty ? null : gender,
                            hint: Text(
                              'Select Gender',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                              ), // CHANGED: hint jadi terang di bg gelap
                            ),
                            dropdownColor:
                                _fieldBg, // CHANGED: dropdown bg gelap
                            style: const TextStyle(
                              color: _fieldText, // CHANGED
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Select your gender'
                                : null,
                            decoration: _fieldDecoration('Select Gender'),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (val) => setState(() => gender = val!),
                          ),
                          const SizedBox(height: 30),
                          // phone number
                          TextFormField(
                            controller: _phoneController,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: _fieldText, // CHANGED
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _fieldDecoration('Phone Number'),
                            validator: (val) => val == null || val.isEmpty
                                ? 'Enter your phone number'
                                : null,
                            onChanged: (val) => setState(() => phone = val),
                          ),
                          const SizedBox(height: 30),
                          // password
                          TextFormField(
                            controller: _passController,
                            textAlign: TextAlign.left,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: _fieldText, // CHANGED
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: _fieldDecoration(
                              'Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors
                                      .grey
                                      .shade500, // CHANGED: was Color(0xFF837E93)
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (val) => val == null || val.length < 6
                                ? 'Enter a password with at least 6 characters'
                                : null,
                            onChanged: (val) => setState(() => password = val),
                          ),
                          const SizedBox(height: 25),
                          // register button
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _fieldText, // CHANGED: was Color(0xFF363434)
                                ),
                                child: const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Color(
                                      0xFF363434,
                                    ), // CHANGED: was Colors.white — teks gelap di atas bg cream
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    setState(() => loading = true);
                                    dynamic result = await _auth
                                        .registerWithEmailAndPassword(
                                          email,
                                          firstName,
                                          lastName,
                                          phone,
                                          gender,
                                          password,
                                        );
                                    if (result is String) {
                                      setState(() {
                                        error = result;
                                        loading = false;
                                      });
                                    } else if (result != null) {
                                      setState(() => loading = false);
                                      debugPrint('mounted check: $mounted');
                                      if (mounted) {
                                        widget.toggleView(fromRegister: true);
                                      }
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Already have an account?',
                                style: TextStyle(
                                  color: Colors
                                      .grey
                                      .shade500, // CHANGED: was Color(0xFF837E93)
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 2.5),
                              InkWell(
                                onTap: () => widget.toggleView(),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color:
                                        _fieldText, // CHANGED: was Color(0xFF393939)
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24 + systemNavInset),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
