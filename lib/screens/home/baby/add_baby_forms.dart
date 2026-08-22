import 'package:flutter/material.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/shared/allergy_selector.dart';
import 'package:flutter/services.dart';

// CHANGED: full-screen 4-step form, bukan bottom sheet lagi.
// Dipake di 2 tempat: (1) wajib diisi pas onboarding lewat Wrapper,
// (2) "tambah bayi lain" dari BabyPage lewat Navigator.push
class AddBabyForms extends StatefulWidget {
  const AddBabyForms({super.key});

  @override
  State<AddBabyForms> createState() => _AddBabyFormsState();
}

class _AddBabyFormsState extends State<AddBabyForms> {
  // ADDED: satu key per step, biar validasi cuma ngecek step yang lagi aktif
  final List<GlobalKey<FormState>> _stepKeys = List.generate(
    4,
    (_) => GlobalKey<FormState>(),
  );
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // CHANGED: warna field disesuaikan ke dark palette
  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _fieldBg = Color(0xFF2A2828);
  static const _fieldBorder = Color(0xFF4A4646);
  static const _fieldText = Color(0xFFF2DAB1);

  final List<String> genders = ['Male', 'Female'];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _currentGender;
  double? _currentWeight;
  double? _currentHeight;
  DateTime? _currentDOB;
  bool _isPremature = false;
  int? _gestationalAgeWeeks;
  bool _isActivelyBreastfed = true;
  int? _toothCount;
  String? _medicalHistory;
  List<String> _selectedAllergyIds = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // CHANGED: pakai _fieldDecoration sendiri, ga lagi pakai textInputDecoration dari constants.dart
  // biar fill & text color bisa dikontrol per-file
  InputDecoration _fieldDecoration(
    String label, {
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _fieldBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _fieldBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brand, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  void _goToNextStep() {
    final currentFormState = _stepKeys[_currentStep].currentState;
    if (currentFormState != null && !currentFormState.validate()) {
      return;
    }
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  Future<void> _submit(String uid) async {
    final currentFormState = _stepKeys[_currentStep].currentState;
    if (currentFormState != null && !currentFormState.validate()) return;

    setState(() => _isLoading = true);
    await DatabaseService(uid: uid).addBaby(
      _firstNameController.text,
      _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      _lastNameController.text,
      _currentGender!,
      _currentDOB!,
      _currentWeight!,
      _currentHeight!,
      _selectedAllergyIds,
      _isPremature,
      _gestationalAgeWeeks,
      _isActivelyBreastfed,
      _toothCount,
      _medicalHistory,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // kalo dipanggil dari BabyPage (ada halaman sebelumnya di stack), pop balik.
    // kalo dipanggil dari Wrapper pas onboarding (ga ada yang bisa di-pop), biarin aja —
    // StreamBuilder<List<Baby>> di Wrapper bakal otomatis switch ke homepage
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final bool canCancel = Navigator.canPop(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: double.infinity),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF363434),
                  Color(0xFF1A1A1A),
                ], // CHANGED: was cream to white
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (canCancel)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: const Color(
                              0xFFF2DAB1,
                            ), // CHANGED: was Colors.white
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_totalSteps, (index) {
                        final isActive = index == _currentStep;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          height: 10.0,
                          width: isActive ? 22.0 : 10.0,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color.fromARGB(255, 144, 121, 84)
                                : const Color(
                                    0xFF4A4646,
                                  ), // CHANGED: was Colors.white
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        );
                      }),
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1Identitas(),
                        _buildStep2Pertumbuhan(),
                        _buildStep3Alergi(),
                        _buildStep4Tambahan(),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _currentStep > 0
                            ? TextButton.icon(
                                onPressed: _goToPreviousStep,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(
                                    0xFFF2DAB1,
                                  ), // CHANGED: default gelap di bg gelap
                                ),
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Kembali'),
                              )
                            : const SizedBox(width: 88),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFFF2DAB1,
                            ), // CHANGED: was Color(0xFF363434)
                            foregroundColor: const Color(
                              0xFF363434,
                            ), // CHANGED: was Colors.white
                          ),
                          onPressed: _currentStep == _totalSteps - 1
                              ? () => _submit(user!.uid)
                              : _goToNextStep,
                          child: Text(
                            _currentStep == _totalSteps - 1
                                ? 'Selesai'
                                : 'Lanjut',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(child: Loading()),
              ),
            ),
        ],
      ),
    );
  }

  // step 1: identitas bayi (nama, gender, tanggal lahir)
  Widget _buildStep1Identitas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _stepKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Silahkan Lengkapi Data Bayi Anda',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF2DAB1), // CHANGED: tambah color eksplisit
              ),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: _firstNameController,
              style: const TextStyle(
                color: _fieldText,
              ), // CHANGED: teks yang diketik jadi cream
              decoration: _fieldDecoration('Nama Depan'),
              validator: (val) => val!.isEmpty ? 'Masukkan nama depan' : null,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _middleNameController,
              style: const TextStyle(color: _fieldText), // CHANGED
              decoration: _fieldDecoration('Nama Tengah (Opsional)'),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _lastNameController,
              style: const TextStyle(color: _fieldText), // CHANGED
              decoration: _fieldDecoration('Nama Belakang'),
              validator: (val) =>
                  val!.isEmpty ? 'Masukkan nama belakang' : null,
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField<String>(
              value: _currentGender,
              decoration: _fieldDecoration('Pilih Jenis Kelamin'),
              dropdownColor: const Color(
                0xFF2A2828,
              ), // CHANGED: dropdown bg gelap
              style: const TextStyle(
                color: _fieldText,
                fontSize: 14,
              ), // CHANGED
              items: genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (val) => setState(() => _currentGender = val),
              validator: (val) => val == null ? 'Pilih gender' : null,
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _currentDOB ?? DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _currentDOB = picked;
                    _dobController.text =
                        '${picked.day}/${picked.month}/${picked.year}';
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dobController,
                  style: const TextStyle(color: _fieldText), // CHANGED
                  decoration: _fieldDecoration(
                    'Tanggal Lahir',
                    suffixIcon: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _brand,
                    ),
                  ),
                  validator: (_) {
                    if (_currentDOB == null) return 'Pilih tanggal lahir';
                    final ageInMonths =
                        DateTime.now().difference(_currentDOB!).inDays ~/ 30;
                    if (ageInMonths < 6) {
                      return 'MPASI diperuntukkan untuk bayi usia 6 bulan ke atas';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  // step 2: pertumbuhan & menyusui (berat, tinggi, ASI, prematur)
  Widget _buildStep2Pertumbuhan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _stepKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Pertumbuhan & Menyusui',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF2DAB1), // CHANGED
              ),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              style: const TextStyle(color: _fieldText), // CHANGED
              decoration: _fieldDecoration('Berat (kg)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: (val) => val!.isEmpty ? 'Masukkan berat badan' : null,
              onChanged: (val) =>
                  setState(() => _currentWeight = double.tryParse(val)),
            ),
            const SizedBox(height: 6),
            Text(
              'Gunakan titik (.) untuk bilangan desimal',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10.0),
            TextFormField(
              style: const TextStyle(color: _fieldText), // CHANGED
              decoration: _fieldDecoration('Tinggi (cm)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: (val) => val!.isEmpty ? 'Masukkan tinggi badan' : null,
              onChanged: (val) =>
                  setState(() => _currentHeight = double.tryParse(val)),
            ),
            const SizedBox(height: 6),
            Text(
              'Gunakan titik (.) untuk bilangan desimal',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12.0),
            // CHANGED: SwitchListTile pakai theme eksplisit biar teks keliatan di bg gelap
            Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(
                  context,
                ).textTheme.apply(bodyColor: const Color(0xFFF2DAB1)),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Masih menyusu ASI?',
                      style: TextStyle(color: Color(0xFFF2DAB1)), // CHANGED
                    ),
                    value: _isActivelyBreastfed,
                    activeColor: _brand,
                    onChanged: (val) =>
                        setState(() => _isActivelyBreastfed = val),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Bayi lahir prematur?',
                      style: TextStyle(color: Color(0xFFF2DAB1)), // CHANGED
                    ),
                    value: _isPremature,
                    activeColor: _brand,
                    onChanged: (val) => setState(() {
                      _isPremature = val;
                      if (!val) _gestationalAgeWeeks = null;
                    }),
                  ),
                ],
              ),
            ),
            if (_isPremature) ...[
              const SizedBox(height: 12.0),
              TextFormField(
                style: const TextStyle(color: _fieldText), // CHANGED
                decoration: _fieldDecoration(
                  'Usia Gestasi Saat Lahir (minggu)',
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (_isPremature && (val == null || val.isEmpty)) {
                    return 'Masukkan usia gestasi saat lahir';
                  }
                  final parsed = int.tryParse(val ?? '');
                  if (parsed == null || parsed < 24 || parsed > 36) {
                    return 'Usia gestasi prematur biasanya 24–36 minggu';
                  }
                  return null;
                },
                onChanged: (val) =>
                    setState(() => _gestationalAgeWeeks = int.tryParse(val)),
              ),
            ],
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  // step 3: alergi — sengaja ga pake Form/validator, boleh kosong
  Widget _buildStep3Alergi() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Alergi',
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF2DAB1), // CHANGED
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Boleh dilewati kalo belum tau ada alergi apa aja.',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ), // CHANGED: was Colors.black54
          ),
          const SizedBox(height: 24.0),
          AllergySelector(
            onChanged: (ids) => setState(() => _selectedAllergyIds = ids),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  // step 4: info tambahan (opsional) — halaman terakhir, tombol jadi "Selesai"
  Widget _buildStep4Tambahan() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Form(
        key: _stepKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Info Tambahan (Opsional)',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF2DAB1), // CHANGED
              ),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              style: const TextStyle(color: _fieldText), // CHANGED
              decoration: _fieldDecoration('Jumlah Gigi (Opsional)'),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => _toothCount = int.tryParse(val)),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              style: const TextStyle(color: _fieldText), // CHANGED
              decoration: _fieldDecoration('Riwayat Penyakit (Opsional)'),
              maxLines: 3,
              onChanged: (val) => setState(
                () => _medicalHistory = val.trim().isEmpty ? null : val.trim(),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
