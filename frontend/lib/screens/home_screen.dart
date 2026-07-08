import 'package:flutter/material.dart';
import 'package:frontend/screens/applications_screen.dart';
import 'package:frontend/screens/job_list_screen.dart';
import 'package:frontend/screens/my_jobs_screen.dart';
import 'package:frontend/screens/search_worker_screen.dart';
import 'package:frontend/widgets/bottom_bar.dart';
import '../theme/app_colors.dart';
import 'register_screen.dart' show AppRole;
import '../services/location_service.dart';
import 'profile_screen.dart';
import 'chat_list_screen.dart';
import 'create_job_screen.dart';
import 'create_cv_screen.dart';

/// Shell utama aplikasi setelah login.
///
/// Ini yang bikin bottom bar "fleksibel": bottom bar-nya nempel di sini,
/// dan body-nya di-switch pakai IndexedStack (bukan Navigator.push),
/// jadi bottom bar tetap kelihatan di semua tab utama (Beranda, Profile, dll),
/// bukan cuma di Beranda doang. State tiap tab juga kejaga karena
/// IndexedStack tidak dispose widget yang lagi tidak aktif.
class HomeScreen extends StatefulWidget {
  final AppRole role;

  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  // Satu Navigator terpisah per tab. Ini kuncinya: kalau sebuah screen di
  // dalam tab tertentu (mis. ProfileScreen -> EditProfileScreen -> ...)
  // memanggil Navigator.of(context).push, yang kepakai otomatis adalah
  // Navigator tab itu (Navigator ANCESTOR terdekat dari context-nya),
  // bukan root navigator. Karena bottom bar digambar di LUAR Navigator-
  // Navigator ini (lihat build() di bawah), bottom bar tetap kelihatan di
  // semua halaman turunan tiap tab, bukan cuma di halaman utamanya saja.
  final List<GlobalKey<NavigatorState>> _tabNavKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>());

  bool get _isEmployer => widget.role == AppRole.employer;

  List<NavBarItem> get _navItems => _isEmployer
      ? const [
          NavBarItem(icon: Icons.home, label: 'Beranda'),
          NavBarItem(icon: Icons.work_outline, label: 'Lowongan Saya'),
          NavBarItem(icon: Icons.badge_outlined, label: 'Cari Pekerja'),
          NavBarItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
          NavBarItem(icon: Icons.person_outline, label: 'Profile'),
        ]
      : const [
          NavBarItem(icon: Icons.home, label: 'Beranda'),
          NavBarItem(icon: Icons.assignment_outlined, label: 'Lamaran Saya'),
          NavBarItem(icon: Icons.work_outline, label: 'Pekerjaan'),
          NavBarItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
          NavBarItem(icon: Icons.person_outline, label: 'Profile'),
        ];

  List<Widget> get _tabRoots => [
        _HomeTab(role: widget.role),
        const _ComingSoonTab(),
        const _ComingSoonTab(),
        const ChatListScreen(),
        const ProfileScreen(),
      ];

  List<Widget> get _tabs => List.generate(
        _tabRoots.length,
        (i) => Navigator(
          key: _tabNavKeys[i],
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => _tabRoots[i],
          ),
        ),
      );

  void _handleNavTap(int index) {
    if (index == 0 || index == 3) {
      // Beranda & Chat sudah langsung ada di IndexedStack (lihat _tabRoots),
      // jadi cukup pindah tab tanpa Navigator.push.
      setState(() => _navIndex = index);
      return;
    }

    setState(() => _navIndex = index);

    switch (index) {
      case 1:
        if (_isEmployer) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const MyJobsScreen()))
              .then((_) {
            if (mounted) setState(() => _navIndex = 0);
          });
        } else {
          Navigator.of(context)
              .push(
                  MaterialPageRoute(builder: (_) => const ApplicationsScreen()))
              .then((_) {
            if (mounted) setState(() => _navIndex = 0);
          });
        }
        break;
      case 2:
        if (_isEmployer) {
          Navigator.of(context)
              .push(
                  MaterialPageRoute(builder: (_) => const SearchWorkerScreen()))
              .then((_) {
            if (mounted) setState(() => _navIndex = 0);
          });
        } else {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const JobListScreen()))
              .then((_) {
            if (mounted) setState(() => _navIndex = 0);
          });
        }
        break;
      case 4:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ProfileScreen()))
            .then((_) {
          if (mounted) setState(() => _navIndex = 0);
        });
        break;
    }
  }

  Future<bool> _handleBackButton() async {
    // Kalau tab yang lagi aktif ada halaman ke-push di atasnya (mis. Edit
    // Profil, Buat CV), tombol back harus nge-pop halaman itu dulu, bukan
    // langsung keluar dari shell.
    final currentNav = _tabNavKeys[_navIndex].currentState;
    if (currentNav != null && currentNav.canPop()) {
      currentNav.pop();
      return false;
    }
    if (_navIndex != 0) {
      setState(() => _navIndex = 0);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _handleBackButton();
        if (shouldPop && mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cardBg,
        body: Stack(
          children: [
            IndexedStack(
              index: _navIndex,
              children: _tabs,
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: BottomNavBar(
                  items: _navItems,
                  currentIndex: _navIndex,
                  onTap: _handleNavTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 100),
      child: const Text(
        'Fitur ini akan segera hadir',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.textGray,
        ),
      ),
    );
  }
}

/// Konten tab Beranda (dulunya isi HomeScreen). Dipisah supaya bisa
/// dipasang sebagai salah satu halaman di IndexedStack milik shell.
class _HomeTab extends StatefulWidget {
  final AppRole role;
  const _HomeTab({required this.role});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _bannerController = PageController(viewportFraction: 0.92);

  String _locationLabel = 'Mencari lokasi...';

  bool get _isEmployer => widget.role == AppRole.employer;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final label = await LocationService.getCurrentLocationLabel();
    if (mounted) setState(() => _locationLabel = label);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildBannerCarousel(),
                  const SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Quick Action',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActions(),
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
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
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
                  children: [
                    const Text(
                      'Lokasi anda',
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _locationLabel,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildNotificationBell(),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          Positioned(
            top: 9,
            right: 9,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.redAccent, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textGray, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Cari pekerjaan atau pekerja',
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
    );
  }

  Widget _buildBannerCarousel() {
    final banners = _isEmployer
        ? [
            _BannerData(
              title: 'Temukan Pekerja\nSejatimu!',
              buttonLabel: 'Cari Sekarang',
              icon: Icons.work_outline,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SearchWorkerScreen())),
            ),
            _BannerData(
              title: 'Lengkapi Profil\nPerusahaan Anda!',
              buttonLabel: 'Edit Profil',
              icon: Icons.badge_outlined,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ]
        : [
            _BannerData(
              title: 'Temukan Pekerjaan\nImpianmu!',
              buttonLabel: 'Cari Sekarang',
              icon: Icons.work_outline,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JobListScreen())),
            ),
            _BannerData(
              title: 'Lengkapi CV-mu\nSekarang!',
              buttonLabel: 'Buat CV',
              icon: Icons.description_outlined,
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateCvScreen())),
            ),
          ];

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _bannerController,
        itemCount: banners.length,
        padEnds: false,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 8),
            child: _BannerCard(data: banner),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = _isEmployer
        ? [
            _QuickAction(
              icon: Icons.edit_note,
              label: 'Buat Lowongan\nSekarang',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateJobScreen())),
            ),
            _QuickAction(
              icon: Icons.work_history_outlined,
              label: 'Lihat Pelamar\nPekerjaan',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyJobsScreen())),
            ),
            _QuickAction(
              icon: Icons.edit_outlined,
              label: 'Edit Profil\nAnda',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ]
        : [
            _QuickAction(
              icon: Icons.description_outlined,
              label: 'Buat CV\nSekarang',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateCvScreen())),
            ),
            _QuickAction(
              icon: Icons.work_outline,
              label: 'Lihat Status\nLamaran',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      const ApplicationsScreen(initialShowTawaran: false))),
            ),
            _QuickAction(
              icon: Icons.outlined_flag,
              label: 'Lihat Status\nTawaran',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      const ApplicationsScreen(initialShowTawaran: true))),
            ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: actions
            .map<Widget>((a) => Expanded(child: _buildQuickActionCard(a)))
            .expand((w) => [w, const SizedBox(width: 12)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerData {
  final String title;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onTap;

  _BannerData({
    required this.title,
    required this.buttonLabel,
    required this.icon,
    required this.onTap,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 19,
                    height: 1.2,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: data.onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    data.buttonLabel,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, size: 32, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _QuickAction({required this.icon, required this.label, required this.onTap});
}
