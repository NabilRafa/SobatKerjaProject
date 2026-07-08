import 'package:flutter/material.dart';
import '../services/cv_service.dart';
import '../services/application_service.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';

class ApplyJobScreen extends StatefulWidget {
  final String jobId;
  const ApplyJobScreen({super.key, required this.jobId});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillController = TextEditingController();

  List<dynamic> _cvs = [];
  final Set<String> _selectedCvIds = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        CvService.getMyCvs(),
        ProfileService.getMyProfile(),
      ]);
      final cvs = results[0] as List<dynamic>;
      final profile = results[1] as Map<String, dynamic>;

      setState(() {
        _cvs = cvs;
        _nameController.text = profile['fullName'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
      });
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedCvIds.isEmpty) {
      setState(() => _errorMessage = 'Pilih minimal 1 CV untuk melamar');
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nama dan nomor telepon wajib diisi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ApplicationService.applyToJob(
        jobId: widget.jobId,
        cvIds: _selectedCvIds.toList(),
        contactName: _nameController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        appliedSkill: _skillController.text.trim().isEmpty
            ? null
            : _skillController.text.trim(),
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
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 50, 8, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const Text('Lamar Pekerjaan',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Nama Kontak'),
                        _textField(_nameController, 'Nama lengkap'),
                        const SizedBox(height: 16),
                        _label('Nomor Telepon'),
                        _textField(
                            _phoneController, 'Nomor yang bisa dihubungi',
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        _label('Keahlian yang Dilamar (opsional)'),
                        _textField(_skillController, 'Contoh: Tukang Kayu'),
                        const SizedBox(height: 20),
                        _label('Pilih CV'),
                        const SizedBox(height: 8),
                        _cvs.isEmpty
                            ? const Text(
                                'Kamu belum punya CV. Buat CV dulu di halaman Profil.',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    color: AppColors.textGray))
                            : Column(
                                children:
                                    _cvs.map((cv) => _cvCheckbox(cv)).toList()),
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
                            onPressed: _isSubmitting ? null : _handleSubmit,
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
                                        strokeWidth: 2.5, color: Colors.white))
                                : const Text('Kirim Lamaran',
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
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _cvCheckbox(Map cv) {
    final id = cv['id'] as String;
    final label = cv['label'] ?? 'CV';
    final selected = _selectedCvIds.contains(id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selected) {
            _selectedCvIds.remove(id);
          } else {
            _selectedCvIds.add(id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected ? AppColors.primary : AppColors.textGray),
            const SizedBox(width: 10),
            const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textDark))),
          ],
        ),
      ),
    );
  }
}
