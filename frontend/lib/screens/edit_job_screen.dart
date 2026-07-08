import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';

class EditJobScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const EditJobScreen({super.key, required this.job});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _salaryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _addressController;
  final _requirementController = TextEditingController();

  late List<String> _requirements;
  late String _salaryType;
  late String _status;

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

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _titleController = TextEditingController(text: job['title'] ?? '');
    _salaryController =
        TextEditingController(text: '${job['salaryAmount'] ?? ''}');
    _descriptionController =
        TextEditingController(text: job['description'] ?? '');
    _locationController =
        TextEditingController(text: job['locationArea'] ?? '');
    _addressController = TextEditingController(text: job['fullAddress'] ?? '');
    _requirements =
        ((job['requirements'] as List?)?.cast<String>() ?? []).toList();
    _salaryType = job['salaryType'] ?? 'PER_HARI';
    _status = job['status'] ?? 'OPEN';
  }

  void _addRequirement() {
    final value = _requirementController.text.trim();
    if (value.isEmpty) return;
    setState(() => _requirements.add(value));
    _requirementController.clear();
  }

  Future<void> _handleSimpan() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await JobService.updateJob(
        jobId: widget.job['id'] as String,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        locationArea: _locationController.text.trim(),
        fullAddress: _addressController.text.trim(),
        salaryAmount: num.tryParse(_salaryController.text.trim()),
        salaryType: _salaryType,
        requirements: _requirements,
        status: _status,
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

  Future<void> _handleHapus() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lowongan?',
            style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
            'Lowongan ini akan dihapus permanen beserta seluruh data lamaran terkait.',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await JobService.deleteJob(widget.job['id'] as String);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
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
                const Text('Edit Lowongan',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white)),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _handleHapus,
                  ),
                ),
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
                  _textField(_titleController, 'Nama lowongan'),
                  const SizedBox(height: 20),
                  _label('Gaji'),
                  _textField(_salaryController, 'Nominal gaji',
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _label('Tipe Pembayaran'),
                  _salaryTypeDropdown(),
                  const SizedBox(height: 20),
                  _label('Deskripsi Pekerjaan'),
                  _textField(_descriptionController, 'Deskripsi pekerjaan',
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
                              _requirementController, '+ Tambah Persyaratan')),
                      const SizedBox(width: 8),
                      IconButton(
                          onPressed: _addRequirement,
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.primary, size: 28)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _label('Lokasi Kerja'),
                  _textField(_locationController, 'Lokasi kerja'),
                  const SizedBox(height: 20),
                  _label('Alamat Lengkap'),
                  _textField(_addressController, 'Alamat lengkap', maxLines: 2),
                  const SizedBox(height: 20),
                  _label('Status Lowongan'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statusToggle('Buka', 'OPEN'),
                      const SizedBox(width: 10),
                      _statusToggle('Tutup', 'CLOSED'),
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
                          : const Text('Simpan Perubahan',
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
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
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
              icon:
                  const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => setState(() => _requirements.removeAt(index))),
        ],
      ),
    );
  }

  Widget _statusToggle(String label, String value) {
    final active = _status == value;
    return GestureDetector(
      onTap: () => setState(() => _status = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: active ? Colors.white : AppColors.textDark)),
      ),
    );
  }
}
