import 'package:flutter/material.dart';
import 'package:frontend/screens/job_application_screen.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'create_job_screen.dart';
import 'edit_job_screen.dart';

class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final jobs = await JobService.getMyJobs();
      setState(() => _jobs = jobs);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat lowongan');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _salaryLabel(String? type) {
    switch (type) {
      case 'PER_JAM':
        return 'jam';
      case 'PER_MINGGU':
        return 'minggu';
      case 'PER_BULAN':
        return 'bulan';
      case 'PER_PROYEK':
        return 'proyek';
      case 'PER_BARANG':
        return 'barang';
      default:
        return 'hari';
    }
  }

  String _formatCurrency(dynamic amount) {
    final value = amount is String
        ? double.tryParse(amount) ?? 0
        : (amount as num).toDouble();
    final intVal = value.toInt();
    return intVal.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateJobScreen()),
          );
          if (created == true) _loadJobs();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Lowongan',
            style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w600)),
      ),
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
            child: const Text('Lowongan Saya',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Colors.white)),
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
                                onPressed: _loadJobs,
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : _jobs.isEmpty
                        ? const Center(
                            child: Text('Kamu belum memposting lowongan',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: AppColors.textGray)),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadJobs,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              itemCount: _jobs.length,
                              itemBuilder: (context, index) =>
                                  _jobCard(_jobs[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(Map job) {
    final title = job['title'] ?? '-';
    final location = job['locationArea'] ?? '-';
    final salaryAmount = job['salaryAmount'];
    final salaryType = _salaryLabel(job['salaryType']);
    final totalSlot = job['totalSlot'] ?? 0;
    final filledSlot = job['filledSlot'] ?? 0;
    final status = job['status'] ?? 'OPEN';
    final applicantsCount = job['_count']?['applications'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDark)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'OPEN'
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status == 'OPEN' ? 'Buka' : 'Tutup',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            status == 'OPEN' ? AppColors.primary : Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined, location),
          const SizedBox(height: 4),
          _infoRow(
              Icons.payments_outlined,
              salaryAmount != null
                  ? 'Rp. ${_formatCurrency(salaryAmount)} / $salaryType'
                  : '-'),
          const SizedBox(height: 4),
          _infoRow(Icons.person_outline,
              'Kuota: $filledSlot/$totalSlot Terisi  •  $applicantsCount Pelamar'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => JobApplicantsScreen(
                              jobId: job['id'] as String, jobTitle: title)),
                    );
                    _loadJobs();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Lihat Pelamar',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                          builder: (_) =>
                              EditJobScreen(job: job.cast<String, dynamic>())),
                    );
                    if (updated == true) _loadJobs();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Edit',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textGray),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textGray))),
      ],
    );
  }
}
