import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/services/portofolio_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart' show AuthService, ApiException;
import '../theme/app_colors.dart';
import 'create_cv_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  bool _isUploadingPortfolio = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ProfileService.getMyProfile();
      setState(() => _profile = data);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat profil');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleChangePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      await ProfileService.uploadPhoto(File(picked.path));
      await _loadProfile();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload foto, coba lagi')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _handleAddPortfolio() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked == null) return;

    setState(() => _isUploadingPortfolio = true);
    try {
      await PortfolioService.uploadPortfolio(File(picked.path));
      await _loadProfile();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload portofolio, coba lagi')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPortfolio = false);
    }
  }

  Future<void> _handleDeletePortfolio(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Portofolio?',
            style: TextStyle(fontFamily: 'Poppins')),
        content: const Text('Item ini akan dihapus permanen.',
            style: TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PortfolioService.deletePortfolio(id);
      await _loadProfile();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _handleDownloadCv(Map cv) async {
    final pdfUrl = cv['pdfUrl'] as String?;
    if (pdfUrl == null || pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File CV tidak ditemukan')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mengunduh CV...')),
    );

    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Gagal mengunduh CV');
      }

      final tempDir = await getTemporaryDirectory();
      final label = (cv['label'] as String? ?? 'cv')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_ -]'), '')
          .trim();
      final file = File(
          '${tempDir.path}/${label.isEmpty ? 'cv' : label}_${cv['id']}.pdf');
      await file.writeAsBytes(response.bodyBytes);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengunduh CV, coba lagi')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('Keluar Akun?', style: TextStyle(fontFamily: 'Poppins')),
        content: const Text(
          'Anda perlu login kembali untuk mengakses akun ini.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();
    if (!mounted) return;

    // Pakai root navigator supaya keluar total dari shell (HomeScreen +
    // Navigator per-tabnya) dan bersihkan seluruh riwayat halaman, bukan
    // cuma pop di dalam Navigator tab Profile.
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleEditProfile() async {
    final profile = _profile!;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          initialFullName: profile['fullName'] ?? '',
          initialPhone: profile['phone'] ?? '',
          initialLocation: profile['location'] ?? '',
          initialBio: profile['bio'] ?? '',
          initialSkills:
              (profile['skills'] as List?)?.cast<String>() ?? const [],
        ),
      ),
    );
    if (result == true) _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _errorMessage != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadProfile,
                    child: _buildContent(),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_errorMessage!, style: const TextStyle(fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: _loadProfile, child: const Text('Coba lagi')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;
    final fullName = profile['fullName'] ?? '-';
    final location = profile['location'] ?? '-';
    final phone = profile['phone'] ?? '-';
    final photoUrl = profile['photoUrl'] as String?;
    final bio = profile['bio'] as String? ?? '-';
    final skills = (profile['skills'] as List?)?.cast<String>() ?? [];
    final cvs = (profile['cvs'] as List?) ?? [];
    final portfolios = (profile['portfolios'] as List?) ?? [];
    final rating = profile['rating'] as Map<String, dynamic>? ?? {};
    final ratingAvg = rating['average'] ?? 0;
    final reviews = (rating['reviews'] as List?) ?? [];

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        children: [
          _buildHeader(fullName, location, phone, photoUrl, ratingAvg),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Deskripsi'),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Keahlian'),
                  const SizedBox(height: 10),
                  skills.isEmpty
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
                          children: skills.map((s) => _skillChip(s)).toList(),
                        ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('CV'),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                                builder: (_) => const CreateCvScreen()),
                          );
                          if (result == true) _loadProfile();
                        },
                        child: const Icon(Icons.add_circle_outline,
                            color: AppColors.primary, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  cvs.isEmpty
                      ? const Text(
                          'Belum ada CV',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              color: AppColors.textGray),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cvs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.4,
                          ),
                          itemBuilder: (context, index) => _cvCard(cvs[index]),
                        ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Hasil Kerja/Portofolio'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: portfolios.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        if (index == portfolios.length) {
                          return _addPortfolioTile();
                        }
                        final item = portfolios[index];
                        final imageUrl = item['imageUrl'] as String?;
                        final id = item['id'] as String;

                        return GestureDetector(
                          onLongPress: () => _handleDeletePortfolio(id),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl != null
                                ? Image.network(imageUrl,
                                    width: 90, height: 90, fit: BoxFit.cover)
                                : Container(
                                    width: 90,
                                    height: 90,
                                    color: AppColors.border),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Ulasan'),
                  const SizedBox(height: 10),
                  reviews.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Belum ada ulasan',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                color: AppColors.textGray),
                          ),
                        )
                      : Column(
                          children:
                              reviews.map((r) => _reviewCard(r)).toList()),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _handleEditProfile,
                      icon:
                          const Icon(Icons.edit, size: 18, color: Colors.white),
                      label: const Text(
                        'Edit Profil',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 0,
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

  Widget _buildHeader(String fullName, String location, String phone,
      String? photoUrl, num ratingAvg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.logout, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Profil Anda',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person,
                        size: 48, color: AppColors.textGray)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _handleChangePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B4CCA),
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingPhoto
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$location  •  $phone  •  ⭐ $ratingAvg',
            style: const TextStyle(
                fontFamily: 'Poppins', fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700,
        fontSize: 15,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _skillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark),
      ),
    );
  }

  Widget _cvCard(Map cv) {
    final label = cv['label'] ?? 'CV';
    return GestureDetector(
      onTap: () => _handleDownloadCv(cv),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.download_rounded,
                size: 14, color: AppColors.textGray),
          ],
        ),
      ),
    );
  }

  Widget _addPortfolioTile() {
    return GestureDetector(
      onTap: _isUploadingPortfolio ? null : _handleAddPortfolio,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: _isUploadingPortfolio
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
              )
            : const Icon(Icons.add, color: AppColors.textGray),
      ),
    );
  }

  Widget _reviewCard(Map review) {
    final fromName = review['fromUser']?['profile']?['fullName'] ?? 'Pengguna';
    final score = review['score'] ?? 0;
    final comment = review['comment'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.border,
              child: Icon(Icons.person, size: 18, color: AppColors.textGray)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fromName,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(comment,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textGray)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(6)),
            child: Text('⭐ $score',
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
