import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/cv_draft.dart';
import '../services/cv_service.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';

class SelectCvTemplateScreen extends StatefulWidget {
  final CvDraft draft;

  const SelectCvTemplateScreen({super.key, required this.draft});

  @override
  State<SelectCvTemplateScreen> createState() => _SelectCvTemplateScreenState();
}

class _SelectCvTemplateScreenState extends State<SelectCvTemplateScreen> {
  List<dynamic> _templates = [];
  String? _selectedTemplateId;
  String _fullName = '';
  bool _isLoading = true;
  bool _isPreviewing = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        CvService.getTemplates(),
        ProfileService.getMyProfile(),
      ]);

      final templates = results[0] as List<dynamic>;
      final profile = results[1] as Map<String, dynamic>;

      setState(() {
        _templates = templates;
        _fullName = profile['fullName'] ?? '';
        _selectedTemplateId =
            templates.isNotEmpty ? templates.first['id'] as String : null;
      });
    } catch (e) {
      setState(() => _errorMessage = 'Gagal memuat template');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLihatPreview() async {
    if (_selectedTemplateId == null) return;

    setState(() => _isPreviewing = true);
    try {
      final pdfBytes = await CvService.previewCv(
        templateId: _selectedTemplateId!,
        position: widget.draft.position,
        summary: widget.draft.summary,
        experience: widget.draft.experience,
        education: widget.draft.education,
        skills: widget.draft.skills,
      );

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/preview_cv_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(pdfBytes);
      await OpenFilex.open(file.path);
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka preview')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPreviewing = false);
    }
  }

  Future<void> _handleSimpan() async {
    if (_selectedTemplateId == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await CvService.createCv(
        label: widget.draft.label,
        templateId: _selectedTemplateId!,
        position: widget.draft.position,
        summary: widget.draft.summary,
        experience: widget.draft.experience,
        education: widget.draft.education,
        skills: widget.draft.skills,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark),
                            children: [
                              TextSpan(text: 'Pilih Template'),
                              TextSpan(
                                  text: '*  ',
                                  style: TextStyle(color: Colors.red)),
                              TextSpan(
                                text: '(Pilih Salah Satu)',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textGray),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._templates.map((t) => _templatePreviewCard(
                            t['id'] as String, t['name'] as String)),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(_errorMessage!,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.red,
                                  fontSize: 12.5)),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                _isPreviewing ? null : _handleLihatPreview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C4CE0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: _isPreviewing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.white),
                                  )
                                : const Text('Lihat Preview',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _handleSimpan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5, color: Colors.white),
                                  )
                                : const Text('Simpan & Post ke Profile',
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
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
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

  Widget _templatePreviewCard(String templateId, String templateName) {
    final selected = _selectedTemplateId == templateId;

    return GestureDetector(
      onTap: () => setState(() => _selectedTemplateId = templateId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildMiniPreview(templateId),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(templateName,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? AppColors.primary : AppColors.textGray,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini preview yang menyesuaikan gaya masing-masing template (klasik/modern/minimalis)
  Widget _buildMiniPreview(String templateId) {
    final position = widget.draft.position ?? '';
    final summary = widget.draft.summary ?? '';

    switch (templateId) {
      case 'template2': // Modern — header banner teal
        return Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E5F74),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fullName.isEmpty ? 'Nama Anda' : _fullName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(position.toUpperCase(),
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.white70,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: Colors.white70)),
            ],
          ),
        );

      case 'template3': // Minimalis — serif, center-aligned
        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.cardBg,
          child: Column(
            children: [
              Text(_fullName.isEmpty ? 'Nama Anda' : _fullName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(position,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                      color: AppColors.textGray)),
              const SizedBox(height: 8),
              Text(summary,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textDark)),
            ],
          ),
        );

      default: // template1 — Klasik, putih polos
        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fullName.isEmpty ? 'Nama Anda' : _fullName,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(position,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textGray)),
              const SizedBox(height: 8),
              Text(summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      color: AppColors.textDark)),
            ],
          ),
        );
    }
  }
}
