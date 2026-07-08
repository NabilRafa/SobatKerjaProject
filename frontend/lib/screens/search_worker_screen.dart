import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/job_service.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'chat_list_screen.dart' show startAndOpenConversation;

class SearchWorkerScreen extends StatefulWidget {
  const SearchWorkerScreen({super.key});

  @override
  State<SearchWorkerScreen> createState() => _SearchWorkerScreenState();
}

class _SearchWorkerScreenState extends State<SearchWorkerScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _workers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers({String? skill}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await ProfileService.searchWorkers(
          skill: skill ?? _searchController.text.trim());
      setState(() => _workers = result['items'] as List<dynamic>);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat data pekerja');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOffer(String workerId, String workerName) async {
    List<dynamic> myJobs;
    try {
      final jobs = await JobService.getMyJobs();
      myJobs = jobs.where((j) => j['status'] == 'OPEN').toList();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal memuat lowongan kamu')));
      return;
    }

    if (myJobs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Kamu belum punya lowongan yang masih Buka. Buat lowongan dulu.')),
        );
      }
      return;
    }

    if (!mounted) return;
    final selectedJob = await showModalBottomSheet<Map>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tawarkan lowongan ke $workerName',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDark)),
                const SizedBox(height: 16),
                ...myJobs.map((job) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(job['title'] ?? '-',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          'Kuota: ${job['filledSlot']}/${job['totalSlot']}',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.textGray)),
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textGray),
                      onTap: () => Navigator.pop(context, job),
                    )),
              ],
            ),
          ),
        );
      },
    );

    if (selectedJob == null) return;

    try {
      await ApplicationService.createOffer(
          jobId: selectedJob['id'] as String, workerId: workerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tawaran berhasil dikirim ke $workerName')),
        );
      }
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text('Cari Pekerja',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white)),
                const SizedBox(height: 16),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          color: AppColors.textGray, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 14),
                          onSubmitted: (value) =>
                              _loadWorkers(skill: value.trim()),
                          decoration: const InputDecoration(
                            hintText:
                                'Cari berdasarkan keahlian (mis. Tukang Kayu)',
                            hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                color: AppColors.textGray,
                                fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                                onPressed: () => _loadWorkers(),
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : _workers.isEmpty
                        ? const Center(
                            child: Text('Tidak ada pekerja ditemukan',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.textGray)),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadWorkers(),
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 40),
                              itemCount: _workers.length,
                              itemBuilder: (context, index) =>
                                  _workerCard(_workers[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _workerCard(Map worker) {
    final fullName = worker['fullName'] ?? '-';
    final location = worker['location'] ?? '-';
    final bio = worker['bio'] ?? '';
    final skills = (worker['skills'] as List?)?.cast<String>() ?? [];
    final photoUrl = worker['photoUrl'] as String?;
    final rating = worker['rating']?['average'] ?? 0;
    final workerId = worker['userId'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.border,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, color: AppColors.textGray)
                    : null,
              ),
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
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: skills
                  .take(4)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(s,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ))
                  .toList(),
            ),
          ],
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleOffer(workerId, fullName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text('Tawarkan Pekerjaan',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => startAndOpenConversation(
                  context,
                  otherUserId: workerId,
                  otherUserName: fullName,
                  otherUserPhotoUrl: photoUrl,
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
        ],
      ),
    );
  }
}
