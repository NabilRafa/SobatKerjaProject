import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  final String initialFullName;
  final String initialPhone;
  final String initialLocation;
  final String initialBio;
  final List<String> initialSkills;

  const EditProfileScreen({
    super.key,
    required this.initialFullName,
    required this.initialPhone,
    required this.initialLocation,
    required this.initialBio,
    this.initialSkills = const [],
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _skillInputController;

  late List<String> _skills;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.initialFullName);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _locationController = TextEditingController(text: widget.initialLocation);
    _bioController = TextEditingController(text: widget.initialBio);
    _skillInputController = TextEditingController();
    _skills = List<String>.from(widget.initialSkills);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;
    if (_skills.any((s) => s.toLowerCase() == value.toLowerCase())) {
      _skillInputController.clear();
      return;
    }
    setState(() {
      _skills.add(value);
      _skillInputController.clear();
    });
  }

  void _removeSkill(String value) {
    setState(() => _skills.remove(value));
  }

  Future<void> _handleSimpan() async {
    if (_namaController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nama wajib diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ProfileService.updateProfile(
        fullName: _namaController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Nama Anda'),
                  _textField(_namaController, 'Nama Lengkap'),
                  const SizedBox(height: 20),
                  _label('No. Telepon'),
                  _textField(_phoneController, 'Nomor Telepon',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _label('Lokasi Anda'),
                  _textField(_locationController, 'Kota/Kabupaten'),
                  const SizedBox(height: 20),
                  _label('Deskripsi'),
                  _textField(
                      _bioController, 'Ceritakan pengalaman & keahlian anda',
                      maxLines: 5),
                  const SizedBox(height: 20),
                  _label('Keahlian'),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          _skillInputController,
                          'Contoh: Las, Bangunan, Cleaning Service',
                          onSubmitted: _addSkill,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        width: 48,
                        child: ElevatedButton(
                          onPressed: () =>
                              _addSkill(_skillInputController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            padding: EdgeInsets.zero,
                            elevation: 0,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _skills.isEmpty
                      ? const Text(
                          'Belum ada keahlian ditambahkan',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              color: AppColors.textGray),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _skills
                              .map((s) => Chip(
                                    label: Text(
                                      s,
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textDark),
                                    ),
                                    backgroundColor: const Color(0xFFFFC107),
                                    deleteIcon: const Icon(Icons.close,
                                        size: 16, color: AppColors.textDark),
                                    onDeleted: () => _removeSkill(s),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide.none,
                                    ),
                                  ))
                              .toList(),
                        ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.red,
                          fontSize: 12.5),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSimpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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
          const Text(
            'Edit Profil',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textDark),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      textInputAction:
          onSubmitted != null ? TextInputAction.done : TextInputAction.next,
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
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
