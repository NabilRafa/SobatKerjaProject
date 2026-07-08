import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'chat_list_screen.dart' show startAndOpenConversation;

/// Menampilkan profil publik user lain (dipakai employer untuk melihat
/// profil pelamar sebelum menerima/menolak, atau worker melihat profil
/// employer/perusahaan).
class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
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
      final data = await ProfileService.getPublicProfile(widget.userId);
      setState(() => _profile = data);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat profil');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!,
                          style: const TextStyle(fontFamily: 'Poppins')),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _loadProfile,
                          child: const Text('Coba lagi')),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final profile = _profile!;
    final fullName = profile['fullName'] as String? ?? '-';
    final location = profile['location'] as String? ?? '-';
    final phone = profile['phone'] as String? ?? '-';
    final photoUrl = profile['photoUrl'] as String?;
    final bio = profile['bio'] as String?;
    final skills = (profile['skills'] as List?)?.cast<String>() ?? [];
    final cvs = (profile['cvs'] as List?) ?? [];
    final portfolios = (profile['portfolios'] as List?) ?? [];
    final rating = profile['rating'] as Map<String, dynamic>? ?? {};
    final ratingAvg = rating['average'] ?? 0;
    final reviews = (rating['reviews'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person,
                          size: 44, color: AppColors.textGray)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(fullName,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text('$location  •  $phone  •  ⭐ $ratingAvg',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white70)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => startAndOpenConversation(
                      context,
                      otherUserId: widget.userId,
                      otherUserName: fullName,
                      otherUserPhotoUrl: photoUrl,
                    ),
                    icon: const Icon(Icons.chat_bubble_outline,
                        size: 18, color: Colors.white),
                    label: const Text('Chat',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                  ),
                ),
                if (bio != null && bio.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionTitle('Deskripsi'),
                  const SizedBox(height: 8),
                  Text(bio,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.4)),
                ],
                if (skills.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Keahlian'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((s) => _skillChip(s)).toList(),
                  ),
                ],
                if (cvs.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('CV'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: cvs
                        .map((cv) => Container(
                              width: 100,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.picture_as_pdf,
                                      color: Colors.redAccent, size: 26),
                                  const SizedBox(height: 6),
                                  Text(
                                    cv['label'] as String? ?? 'CV',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins', fontSize: 11),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
                if (portfolios.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Hasil Kerja/Portofolio'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: portfolios.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final imageUrl =
                            portfolios[index]['imageUrl'] as String?;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageUrl != null
                              ? Image.network(imageUrl,
                                  width: 90, height: 90, fit: BoxFit.cover)
                              : Container(
                                  width: 90,
                                  height: 90,
                                  color: AppColors.border),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                _sectionTitle('Ulasan'),
                const SizedBox(height: 10),
                reviews.isEmpty
                    ? const Text('Belum ada ulasan',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            color: AppColors.textGray))
                    : Column(
                        children: reviews.map((r) => _reviewCard(r)).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.textDark));
  }

  Widget _skillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark)),
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
