import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _totalSlotController = TextEditingController(text: '1');
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _requirementController = TextEditingController();

  final List<String> _requirements = [];
  String _salaryType = 'PER_HARI';
  bool _isSubmitting = false;
  String? _errorMessage;

  final Map<String, String> _salaryTypeLabels = const {
    'PER_JAM': 'Per Jam',
    'PER_HARI': 'Per Hari',
    'PER_MINGGU': 'Per Minggu',
    'PER_BULAN': 'Per Bulan',
    'PER_PROYEK': 'Per Proyek',
    'PER_BARANG': 'Per Barang',
  };

  void _addRequirement() {
    final value = _requirementController.text.trim();
    if (value.isEmpty) return;
    setState(() => _requirements.add(value));
    _requirementController.clear();
  }

  Future<void> _handleSimpan() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _salaryController.text.trim().isEmpty) {
      setState(() =>
          _errorMessage = 'Semua field wajib diisi, termasuk lokasi dan gaji');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await JobService.createJob(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        locationArea: _locationController.text.trim(),
        fullAddress: _addressController.text.trim(),
        salaryAmount: num.tryParse(_salaryController.text.trim()) ?? 0,
        salaryType: _salaryType,
        totalSlot: int.tryParse(_totalSlotController.text.trim()) ?? 1,
        requirements: _requirements,
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
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _totalSlotController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _requirementController.dispose();
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
                const Text('Buat Lowongan',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Nama Lowongan'),
                  _textField(_titleController, 'Contoh: Asisten Rumah Tangga'),
                  const SizedBox(height: 20),
                  _label('Gaji'),
                  _textField(_salaryController, 'Contoh: 70000',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _label('Tipe Pembayaran'),
                  _salaryTypeDropdown(),
                  const SizedBox(height: 20),
                  _label('Kuota (jumlah pekerja dibutuhkan)'),
                  _textField(_totalSlotController, 'Contoh: 3',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _label('Deskripsi Pekerjaan'),
                  _textField(_descriptionController,
                      'Jelaskan tugas dan tanggung jawab pekerjaan ini',
                      maxLines: 4),
                  const SizedBox(height: 20),
                  _label('Persyaratan'),
                  const SizedBox(height: 8),
                  ..._requirements
                      .asMap()
                      .entries
                      .map((entry) => _requirementItem(entry.key, entry.value)),
                  Row(
                    children: [
                      Expanded(
                          child: _textField(
                              _requirementController, 'Tambah persyaratan')),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addRequirement,
                        icon: const Icon(Icons.add_circle,
                            color: AppColors.primary, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _label('Lokasi Kerja'),
                  _textField(_locationController,
                      'Contoh: Purbalingga, Kalimanah, Jawa Tengah'),
                  const SizedBox(height: 20),
                  _label('Alamat Lengkap'),
                  _textField(_addressController, 'Alamat detail lokasi kerja',
                      maxLines: 2),
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
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Text('Posting Lowongan',
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
      {int maxLines = 1, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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

  Widget _salaryTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _salaryType,
          isExpanded: true,
          style: const TextStyle(
              fontFamily: 'Poppins', fontSize: 14, color: AppColors.textDark),
          items: _salaryTypeLabels.entries
              .map((entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _salaryType = value);
          },
        ),
      ),
    );
  }

  Widget _requirementItem(int index, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textDark))),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: () => setState(() => _requirements.removeAt(index)),
          ),
        ],
      ),
    );
  }
}
