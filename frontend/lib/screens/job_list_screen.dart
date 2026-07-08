import 'package:flutter/material.dart';
import '../services/job_service.dart';
import '../services/auth_service.dart' show ApiException;
import '../theme/app_colors.dart';
import 'job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _searchController = TextEditingController();
  final List<String> _filterChips = ['Semua', 'Tukang Kayu', 'Tukang Ojol', 'Lainnya'];
  String _activeFilter = 'Semua';

  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs({String? keyword}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await JobService.searchJobs(
        keyword: keyword ?? (_activeFilter == 'Semua' ? _searchController.text.trim() : _activeFilter),
      );
      setState(() => _jobs = result['items'] as List<dynamic>);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat memuat lowongan');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleFilterTap(String filter) {
    setState(() => _activeFilter = filter);
    _searchController.clear();
    _loadJobs(keyword: filter == 'Semua' ? '' : filter);
  }

  void _handleSearchSubmit(String value) {
    setState(() => _activeFilter = 'Semua');
    _loadJobs(keyword: value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBg,
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filterChips.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final label = _filterChips[index];
                  final active = _activeFilter == label;
                  return GestureDetector(
                    onTap: () => _handleFilterTap(label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: active ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_errorMessage!, style: const TextStyle(fontFamily: 'Poppins')),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => _loadJobs(), child: const Text('Coba lagi')),
                          ],
                        ),
                      )
                    : _jobs.isEmpty
                        ? const Center(
                            child: Text('Tidak ada lowongan ditemukan',
                                style: TextStyle(fontFamily: 'Poppins', color: AppColors.textGray)),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadJobs(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: _jobs.length,
                              itemBuilder: (context, index) => _jobCard(_jobs[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cari Pekerjaan',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
          const SizedBox(height: 16),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.textGray, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                    onSubmitted: _handleSearchSubmit,
                    decoration: const InputDecoration(
                      hintText: 'Cari pekerjaan',
                      hintStyle: TextStyle(fontFamily: 'Poppins', color: AppColors.textGray, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(Map job) {
    final title = job['title'] ?? '-';
    final employerName = job['employer']?['profile']?['fullName'] ?? '-';
    final location = job['locationArea'] ?? '-';
    final salaryAmount = job['salaryAmount'];
    final salaryType = _salaryLabel(job['salaryType']);
    final totalSlot = job['totalSlot'] ?? 0;
    final filledSlot = job['filledSlot'] ?? 0;
    final description = job['description'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 17, color: Colors.white)),
          const SizedBox(height: 2),
          Text(employerName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white)),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, location),
          const SizedBox(height: 4),
          _infoRow(Icons.payments_outlined, salaryAmount != null ? 'Rp. ${_formatCurrency(salaryAmount)} / $salaryType' : '-'),
          const SizedBox(height: 4),
          _infoRow(Icons.person_outline, 'Kuota: $filledSlot/$totalSlot Terisi'),
          const SizedBox(height: 10),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12.5, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => JobDetailScreen(jobId: job['id'] as String)),
                );
                _loadJobs();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text('Detail',
                  style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white))),
      ],
    );
  }

  String _salaryLabel(String? type) {
    switch (type) {
      case 'PER_JAM': return 'jam';
      case 'PER_MINGGU': return 'minggu';
      case 'PER_BULAN': return 'bulan';
      case 'PER_PROYEK': return 'proyek';
      case 'PER_BARANG': return 'barang';
      default: return 'hari';
    }
  }

  String _formatCurrency(dynamic amount) {
    final value = amount is String ? double.tryParse(amount) ?? 0 : (amount as num).toDouble();
    final intVal = value.toInt();
    return intVal.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.');
  }
}