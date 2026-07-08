import 'package:flutter/material.dart';
import '../models/cv_draft.dart';
import '../theme/app_colors.dart';
import 'select_cv_template_screen.dart';

class CreateCvScreen extends StatefulWidget {
  const CreateCvScreen({super.key});

  @override
  State<CreateCvScreen> createState() => _CreateCvScreenState();
}

class _ExperienceEntry {
  final role = TextEditingController();
  final company = TextEditingController();
  final startYear = TextEditingController();
  final endYear = TextEditingController();
  final description = TextEditingController();
}

class _EducationEntry {
  final institution = TextEditingController();
  final startYear = TextEditingController();
  final endYear = TextEditingController();
  final description = TextEditingController();
}

class _CreateCvScreenState extends State<CreateCvScreen> {
  final _labelController = TextEditingController();
  final _positionController = TextEditingController();
  final _summaryController = TextEditingController();
  final _skillInputController = TextEditingController();

  final List<_ExperienceEntry> _experiences = [_ExperienceEntry()];
  final List<_EducationEntry> _educations = [_EducationEntry()];
  final List<String> _skills = [];

  String? _errorMessage;

  void _addSkill() {
    final value = _skillInputController.text.trim();
    if (value.isEmpty) return;
    if (!_skills.contains(value)) {
      setState(() => _skills.add(value));
    }
    _skillInputController.clear();
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  void _handleLanjut() {
    if (_labelController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Judul CV wajib diisi');
      return;
    }

    final experiencePayload = _experiences
        .where((e) =>
            e.role.text.trim().isNotEmpty || e.company.text.trim().isNotEmpty)
        .map((e) => {
              'position': e.role.text.trim(),
              'company': e.company.text.trim(),
              'startDate': e.startYear.text.trim(),
              'endDate': e.endYear.text.trim(),
              'description': e.description.text.trim(),
            })
        .toList();

    final educationPayload = _educations
        .where((e) => e.institution.text.trim().isNotEmpty)
        .map((e) => {
              'institution': e.institution.text.trim(),
              'startYear': e.startYear.text.trim(),
              'endYear': e.endYear.text.trim(),
              'description': e.description.text.trim(),
            })
        .toList();

    final draft = CvDraft(
      label: _labelController.text.trim(),
      position: _positionController.text.trim(),
      summary: _summaryController.text.trim(),
      experience: experiencePayload,
      education: educationPayload,
      skills: _skills,
    );

    Navigator.of(context)
        .push<bool>(
      MaterialPageRoute(builder: (_) => SelectCvTemplateScreen(draft: draft)),
    )
        .then((savedSuccessfully) {
      if (savedSuccessfully == true && mounted) {
        Navigator.of(context)
            .pop(true); // teruskan sinyal sukses ke ProfileScreen
      }
    });
  }

  @override
  void dispose() {
    _labelController.dispose();
    _positionController.dispose();
    _summaryController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Judul CV'),
                  _textField(_labelController, 'Contoh: CV Kuli'),
                  const SizedBox(height: 20),
                  _label('Profesi Anda'),
                  _textField(_positionController, 'Contoh: Tukang Bangunan'),
                  const SizedBox(height: 20),
                  _label('Ringkasan Diri'),
                  _textField(
                    _summaryController,
                    'Contoh: Berpengalaman 10 tahun di bidang konstruksi dan 5 tahun di bidang vape',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _label('Pengalaman Kerja'),
                  const SizedBox(height: 8),
                  ..._experiences.map((e) => _experienceGroup(e)),
                  _addButton('+ Tambah Pengalaman', () {
                    setState(() => _experiences.add(_ExperienceEntry()));
                  }),
                  const SizedBox(height: 20),
                  _label('Pendidikan'),
                  const SizedBox(height: 8),
                  ..._educations.map((e) => _educationGroup(e)),
                  _addButton('+ Tambah Pendidikan', () {
                    setState(() => _educations.add(_EducationEntry()));
                  }),
                  const SizedBox(height: 20),
                  _label('Keahlian (ketik keahlian)'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._skills.map((s) => _skillChip(s)),
                      _skillInputChip(),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(_errorMessage!,
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.red,
                            fontSize: 12.5)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleLanjut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: const Text('Lanjut & Pilih Template',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 50, 8, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon:
                  const Icon(Icons.chevron_left, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const Text('Buat CV',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark)),
    );
  }

  Widget _textField(TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
          fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Poppins', color: AppColors.textGray, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _halfTextField(TextEditingController controller, String hint) {
    return Expanded(
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(
            fontFamily: 'Poppins', fontSize: 13, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Poppins', color: AppColors.textGray, fontSize: 12.5),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _experienceGroup(_ExperienceEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _textField(e.role, 'Peran (cth: Kuli Bangunan)'),
          const SizedBox(height: 10),
          _textField(e.company, 'Nama Tempat Kerja'),
          const SizedBox(height: 10),
          Row(children: [
            _halfTextField(e.startYear, 'Tahun Mulai'),
            const SizedBox(width: 10),
            _halfTextField(e.endYear, 'Tahun Selesai')
          ]),
          const SizedBox(height: 10),
          _textField(e.description, 'Deskripsi singkat tugas'),
        ],
      ),
    );
  }

  Widget _educationGroup(_EducationEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _textField(e.institution, 'Nama Sekolah/Kampus'),
          const SizedBox(height: 10),
          Row(children: [
            _halfTextField(e.startYear, 'Tahun Mulai'),
            const SizedBox(width: 10),
            _halfTextField(e.endYear, 'Tahun Selesai')
          ]),
          const SizedBox(height: 10),
          _textField(e.description, 'Deskripsi singkat pendidikan'),
        ],
      ),
    );
  }

  Widget _addButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary)),
      ),
    );
  }

  Widget _skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeSkill(skill),
            child: const Icon(Icons.close, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _skillInputChip() {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: _skillInputController,
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        onSubmitted: (_) => _addSkill(),
        decoration: InputDecoration(
          hintText: 'Ketik & Enter',
          hintStyle: const TextStyle(
              fontFamily: 'Poppins', color: AppColors.textGray, fontSize: 12.5),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.border)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
            onPressed: _addSkill,
          ),
        ),
      ),
    );
  }
}
