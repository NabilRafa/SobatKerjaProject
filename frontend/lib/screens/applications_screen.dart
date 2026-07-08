import 'package:flutter/material.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'job_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  final bool initialShowTawaran;
  const ApplicationsScreen({super.key, this.initialShowTawaran = false});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  late bool _showTawaran = widget.initialShowTawaran;
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _applications = [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await ApplicationService.getMyApplications(
        type: _showTawaran ? 'OFFER' : 'APPLICATION',
      );
      setState(() => _applications = data);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat data');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _switchTab(bool showTawaran) {
    setState(() => _showTawaran = showTawaran);
    _loadApplications();
  }

  Future<void> _handleRespondOffer(String applicationId, String status) async {
    try {
      await ApplicationService.respondToApplication(
          applicationId: applicationId, status: status);
      _loadApplications();
    } on ApiException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _handleCancel(String applicationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Lamaran?',
            style:
                TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: const Text(
          'Lamaran yang sudah dibatalkan tidak bisa dikembalikan. Apakah Anda yakin ingin membatalkan lamaran ini?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak', style: TextStyle(fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApplicationService.cancelApplication(applicationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lamaran berhasil dibatalkan')),
        );
      }
      _loadApplications();
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
          _buildHeader(),
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
                                onPressed: _loadApplications,
                                child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : _applications.isEmpty
                        ? Center(
                            child: Text(
                              _showTawaran
                                  ? 'Belum ada tawaran'
                                  : 'Belum ada lamaran',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.textGray,
                                  fontSize: 14),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadApplications,
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 100),
                              itemCount: _applications.length,
                              itemBuilder: (context, index) =>
                                  _applicationCard(_applications[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Lokasi anda',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('Purbalingga, Jawa Tengah',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.notifications_none,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.search, color: AppColors.textGray, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Cari pekerjaan',
                      hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textGray,
                          fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildToggle(),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(
              child: _toggleButton(
                  'Lamaran', !_showTawaran, () => _switchTab(false))),
          Expanded(
              child: _toggleButton(
                  'Tawaran', _showTawaran, () => _switchTab(true))),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: active ? Colors.white : AppColors.primary)),
      ),
    );
  }

  Widget _applicationCard(Map application) {
    final job = application['job'] as Map? ?? {};
    final title = job['title'] ?? '-';
    final employerName = job['employer']?['profile']?['fullName'] ?? '-';
    final location = job['locationArea'] ?? '-';
    final salaryAmount = job['salaryAmount'];
    final salaryType = _salaryLabel(job['salaryType']);
    final totalSlot = job['totalSlot'] ?? 0;
    final filledSlot = job['filledSlot'] ?? 0;
    final description = job['description'] ?? '';
    final status = application['status'] as String? ?? 'PENDING';
    final applicationId = application['id'] as String;
    final jobId = job['id'] as String?;

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
          Text(title,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(employerName,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary)),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, location),
          const SizedBox(height: 4),
          _infoRow(
              Icons.payments_outlined,
              salaryAmount != null
                  ? 'Rp ${_formatCurrency(salaryAmount)} / $salaryType'
                  : '-'),
          const SizedBox(height: 4),
          _infoRow(
              Icons.person_outline, 'Kuota: $filledSlot/$totalSlot Terisi'),
          const SizedBox(height: 10),
          Text(description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: AppColors.textGray,
                  height: 1.4)),
          const SizedBox(height: 14),
          _buildActionRow(status, applicationId, jobId),
        ],
      ),
    );
  }

  Widget _buildActionRow(String status, String applicationId, String? jobId) {
    Widget detailButton() {
      return Expanded(
        child: OutlinedButton(
          onPressed: jobId == null
              ? null
              : () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => JobDetailScreen(jobId: jobId)));
                  _loadApplications();
                },
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.primary,
            side: BorderSide.none,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Detail',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white)),
        ),
      );
    }

    // Tab Tawaran & status PENDING -> worker harus bisa lihat detail dulu,
    // baru terima/tolak. Detail ditampilkan di baris atas, aksi terima/tolak
    // di baris bawah supaya tidak keliru tertekan.
    if (_showTawaran && status == 'PENDING') {
      return Column(
        children: [
          Row(children: [detailButton()]),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _handleRespondOffer(applicationId, 'REJECTED'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Tolak',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.red)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _handleRespondOffer(applicationId, 'ACCEPTED'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Terima',
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
      );
    }

    // Tab Lamaran, status masih menunggu -> worker bisa membatalkan lamaran
    // lewat tombol terpisah (dengan konfirmasi), bukan dengan tap status.
    if (status == 'PENDING') {
      return Row(
        children: [
          Expanded(child: _statusButton(status, applicationId)),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _handleCancel(applicationId),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Batalkan',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.red)),
            ),
          ),
        ],
      );
    }

    // Tab Lamaran -> tampilkan status button + Detail
    return Row(
      children: [
        Expanded(child: _statusButton(status, applicationId)),
        const SizedBox(width: 10),
        detailButton(),
      ],
    );
  }

  Widget _statusButton(String status, String applicationId) {
    late final String label;
    late final Color color;
    VoidCallback? onTap;

    switch (status) {
      case 'PENDING':
        label = 'Menunggu';
        color = const Color(0xFF6C4CE0);
        // Tidak ada aksi di sini lagi -- pembatalan sekarang lewat tombol
        // "Batalkan" terpisah supaya tidak bisa tidak sengaja tertekan.
        break;
      case 'ACCEPTED':
        label = 'Diterima';
        color = AppColors.primary;
        break;
      case 'COMPLETED':
        label = 'Selesai';
        color = const Color(0xFF6C4CE0);
        break;
      case 'REJECTED':
        label = 'Ditolak';
        color = const Color(0xFFE0433E);
        break;
      case 'CANCELLED':
        label = 'Dibatalkan';
        color = AppColors.textGray;
        break;
      default:
        label = status;
        color = AppColors.textGray;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white)),
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
}
