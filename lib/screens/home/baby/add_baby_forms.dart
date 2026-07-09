import 'package:flutter/material.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/shared/allergy_selector.dart';

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

  // validasi dimatiin sementara buat keperluan adjustment.
  // jangan lupa di-uncomment lagi bagian validate() di bawah kalo udah selesai
  void _goToNextStep() {
    // komen if pertama buat bolak balik ganti style
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
            // ADDED: gradient sama kayak homepage, biar nyambung sama intro slides
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5EBD9), Color(0xFFFFFFFF)],
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // ADDED: dots indicator, gaya disamain sama IntroSlides
                  // ADDED: tombol Batal, cuma muncul kalo dipanggil dari BabyPage (ada yang bisa di-pop)
                  // kalo dari onboarding, ga ada tombol ini sama sekali karena form ini wajib diisi
                  if (canCancel)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
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
                                : Colors.white,
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        );
                      }),
                    ),
                  ),

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      // ADDED: swipe dimatiin, navigasi cuma lewat tombol biar validasi per-step kepegang
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStep1Identitas(),
                        _buildStep2Pertumbuhan(),
                        _buildStep3Alergi(),
                        _buildStep4Tambahan(),
                      ],
                    ),
                  ),

                  // ADDED: tombol navigasi Kembali / Lanjut / Selesai
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
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Kembali'),
                              )
                            : const SizedBox(
                                width: 88,
                              ), // spacer biar tombol kanan tetep di posisi kanan
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF363434),
                            foregroundColor: Colors.white,
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
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              controller: _firstNameController,
              decoration: textInputDecoration.copyWith(labelText: 'Nama Depan'),
              validator: (val) => val!.isEmpty ? 'Masukkan nama depan' : null,
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _middleNameController,
              decoration: textInputDecoration.copyWith(
                labelText: 'Nama Tengah (Opsional)',
              ),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              controller: _lastNameController,
              decoration: textInputDecoration.copyWith(
                labelText: 'Nama Belakang',
              ),
              validator: (val) =>
                  val!.isEmpty ? 'Masukkan nama belakang' : null,
            ),
            const SizedBox(height: 20.0),
            DropdownButtonFormField<String>(
              value: _currentGender,
              decoration: textInputDecoration.copyWith(
                labelText: 'Pilih Jenis Kelamin',
              ),
              items: genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (val) => setState(() => _currentGender = val),
              validator: (val) => val == null ? 'Pilih gender' : null,
            ),
            const SizedBox(height: 20.0),
            // CHANGED: DOB field pake controller + labelText, tanggal dipilih ditulis ke controller
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
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Tanggal Lahir',
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
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(labelText: 'Berat (kg)'),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? 'Masukkan berat badan' : null,
              onChanged: (val) =>
                  setState(() => _currentWeight = double.tryParse(val)),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(
                labelText: 'Tinggi (cm)',
              ),
              keyboardType: TextInputType.number,
              validator: (val) => val!.isEmpty ? 'Masukkan tinggi badan' : null,
              onChanged: (val) =>
                  setState(() => _currentHeight = double.tryParse(val)),
            ),
            const SizedBox(height: 12.0),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Masih menyusu ASI?'),
              value: _isActivelyBreastfed,
              onChanged: (val) => setState(() => _isActivelyBreastfed = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bayi lahir prematur?'),
              value: _isPremature,
              onChanged: (val) => setState(() {
                _isPremature = val;
                // reset usia gestasi kalo toggle dimatiin
                if (!val) _gestationalAgeWeeks = null;
              }),
            ),
            // field usia gestasi cuman muncul kalo isPremature == true
            if (_isPremature) ...[
              const SizedBox(height: 12.0),
              TextFormField(
                decoration: textInputDecoration.copyWith(
                  labelText: 'Usia Gestasi Saat Lahir (minggu)',
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
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Boleh dilewati kalo belum tau ada alergi apa aja.',
            style: TextStyle(fontSize: 14.0, color: Colors.black54),
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
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(
                labelText: 'Jumlah Gigi (Opsional)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) =>
                  setState(() => _toothCount = int.tryParse(val)),
            ),
            const SizedBox(height: 20.0),
            TextFormField(
              decoration: textInputDecoration.copyWith(
                labelText: 'Riwayat Penyakit (Opsional)',
              ),
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
