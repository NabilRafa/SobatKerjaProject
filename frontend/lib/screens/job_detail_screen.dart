import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'apply_job_screen.dart';
import 'chat_list_screen.dart' show startAndOpenConversation;

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  Map<String, dynamic>? _job;
  bool _isLoading = true;
  bool _isResponding = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await JobService.getJobDetail(widget.jobId);
      setState(() => _job = data);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat detail lowongan');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRespondOffer(String applicationId, String status) async {
    setState(() => _isResponding = true);
    try {
      await ApplicationService.respondToApplication(
          applicationId: applicationId, status: status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(status == 'ACCEPTED'
                ? 'Tawaran berhasil diterima'
                : 'Tawaran berhasil ditolak')));
      }
      await _loadDetail();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal merespon tawaran')));
      }
    } finally {
      if (mounted) setState(() => _isResponding = false);
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
                          onPressed: _loadDetail,
                          child: const Text('Coba lagi')),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final job = _job!;
    final title = job['title'] ?? '-';
    final locationArea = job['locationArea'] ?? '-';
    final fullAddress = job['fullAddress'] ?? '-';
    final description = job['description'] ?? '-';
    final salaryAmount = job['salaryAmount'];
    final salaryType = _salaryLabel(job['salaryType']);
    final totalSlot = job['totalSlot'] ?? 0;
    final filledSlot = job['filledSlot'] ?? 0;
    final requirements = (job['requirements'] as List?)?.cast<String>() ?? [];
    final employer = job['employer'] as Map? ?? {};
    final employerName = employer['profile']?['fullName'] ?? '-';
    final employerRating = employer['rating']?['average'] ?? 0;
    final myApplication = job['myApplication'] as Map?;

    return SingleChildScrollView(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: AppColors.textDark),
                      const SizedBox(width: 4),
                      Text(locationArea,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.white)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('Rp. ${_formatCurrency(salaryAmount)} / $salaryType',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10),
                    ]),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 16, color: AppColors.textDark),
                    const SizedBox(width: 6),
                    Text('Kuota: $filledSlot/$totalSlot Terisi',
                        style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Pemberi Kerja'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.border,
                        child: Icon(Icons.person, color: AppColors.textGray)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employerName,
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          Text('⭐ $employerRating',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: AppColors.textGray)),
                        ],
                      ),
                    ),
                    if (employer['id'] != null)
                      OutlinedButton(
                        onPressed: () => startAndOpenConversation(
                          context,
                          otherUserId: employer['id'] as String,
                          otherUserName: employerName,
                          otherUserPhotoUrl:
                              employer['profile']?['photoUrl'] as String?,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: const Icon(Icons.chat_bubble_outline,
                            size: 16, color: AppColors.primary),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('Deskripsi Pekerjaan'),
                const SizedBox(height: 8),
                Text(description,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.5)),
                const SizedBox(height: 20),
                _sectionTitle('Alamat Lengkap'),
                const SizedBox(height: 8),
                Text(fullAddress,
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.textDark,
                        height: 1.5)),
                if (requirements.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _sectionTitle('Persyaratan'),
                  const SizedBox(height: 8),
                  ...requirements.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  ',
                                style: TextStyle(fontFamily: 'Poppins')),
                            Expanded(
                                child: Text(r,
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: AppColors.textDark))),
                          ],
                        ),
                      )),
                ],
                const SizedBox(height: 28),
                if (myApplication != null &&
                    myApplication['type'] == 'OFFER' &&
                    myApplication['status'] == 'PENDING')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isResponding
                              ? null
                              : () => _handleRespondOffer(
                                  myApplication['id'] as String, 'REJECTED'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Tolak Tawaran',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isResponding
                              ? null
                              : () => _handleRespondOffer(
                                  myApplication['id'] as String, 'ACCEPTED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: _isResponding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Terima Tawaran',
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: myApplication != null
                        ? _buildStatusBanner(myApplication['status'] as String)
                        : ElevatedButton(
                            onPressed: () async {
                              final applied =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ApplyJobScreen(jobId: widget.jobId)),
                              );
                              if (applied == true) _loadDetail();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 0,
                            ),
                            child: const Text('Lamar Sekarang',
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

  Widget _buildStatusBanner(String status) {
    String label;
    Color color;
    switch (status) {
      case 'PENDING':
        label = 'Lamaran Menunggu Respon';
        color = const Color(0xFF6C4CE0);
        break;
      case 'ACCEPTED':
        label = 'Lamaran Diterima';
        color = AppColors.primary;
        break;
      case 'REJECTED':
        label = 'Lamaran Ditolak';
        color = const Color(0xFFE0433E);
        break;
      case 'COMPLETED':
        label = 'Pekerjaan Selesai';
        color = AppColors.primary;
        break;
      default:
        label = status;
        color = AppColors.textGray;
    }
    return Container(
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
      child: Text(label,
          style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.white)),
    );
  }
}
