import 'package:flutter/material.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'chat_list_screen.dart' show startAndOpenConversation;
import 'public_profile_screen.dart';

class JobApplicantsScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  const JobApplicantsScreen(
      {super.key, required this.jobId, required this.jobTitle});

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  List<dynamic> _applicants = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApplicationService.getApplicantsForJob(widget.jobId);
      setState(() => _applicants = data);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat pelamar');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRespond(String applicationId, String status) async {
    try {
      await ApplicationService.respondToApplication(
          applicationId: applicationId, status: status);
      _loadApplicants();
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _applicants.where((a) => a['status'] == 'PENDING').toList();
    final accepted = _applicants
        .where((a) => a['status'] == 'ACCEPTED' || a['status'] == 'COMPLETED')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Text(widget.jobTitle,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
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
                                onPressed: _loadApplicants,
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadApplicants,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                          children: [
                            const Text('Pelamar',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textDark)),
                            const SizedBox(height: 10),
                            pending.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: Text('-',
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            color: AppColors.textGray)),
                                  )
                                : Column(
                                    children: pending
                                        .map((a) => _applicantCard(a,
                                            showActions: true))
                                        .toList()),
                            const SizedBox(height: 20),
                            const Text('Diterima',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppColors.textDark)),
                            const SizedBox(height: 10),
                            accepted.isEmpty
                                ? const Text('-',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        color: AppColors.textGray))
                                : Column(
                                    children: accepted
                                        .map((a) => _applicantCard(a,
                                            showActions: false))
                                        .toList()),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _applicantCard(Map app, {required bool showActions}) {
    final applicant = app['applicant'] as Map? ?? {};
    final profile = applicant['profile'] as Map? ?? {};
    final fullName = profile['fullName'] ?? '-';
    final location = profile['location'] ?? '-';
    final bio = profile['bio'] ?? '';
    final skills = (profile['skills'] as List?)?.cast<String>() ?? [];
    final rating = applicant['rating']?['average'] ?? 0;
    final status = app['status'] ?? 'PENDING';
    final applicationId = app['id'] as String;
    final applicantId = applicant['id'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.border,
                  child: Icon(Icons.person, color: AppColors.textGray)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(fullName,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFC107),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('⭐ $rating',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    if (skills.isNotEmpty)
                      Text(skills.take(3).join(', '),
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textGray),
                        const SizedBox(width: 3),
                        Text(location,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.textGray)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (bio.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textDark)),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: applicantId == null
                      ? null
                      : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              PublicProfileScreen(userId: applicantId))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Lihat Profil',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: applicantId == null
                    ? null
                    : () => startAndOpenConversation(
                          context,
                          otherUserId: applicantId,
                          otherUserName: fullName,
                          otherUserPhotoUrl: profile['photoUrl'] as String?,
                        ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    size: 16, color: AppColors.primary),
              ),
            ],
          ),
          if (showActions && status == 'PENDING') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleRespond(applicationId, 'REJECTED'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('Tolak',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleRespond(applicationId, 'ACCEPTED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: const Text('Terima',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
          if (status == 'ACCEPTED')
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _handleRespond(applicationId, 'COMPLETED'),
                  child: const Text('Tandai Pekerjaan Selesai',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textGray)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
