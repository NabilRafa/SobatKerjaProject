import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart' show ApiException;
import 'login_screen.dart';
import 'home_screen.dart';
import 'register_screen.dart' show AppRole;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final sessionCheck = _resolveSession();
    final minimumDelay = Future.delayed(const Duration(milliseconds: 1500));

    final results = await Future.wait([sessionCheck, minimumDelay]);
    final destination = results[0] as Widget;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  Future<Widget> _resolveSession() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return const LoginScreen();

    try {
      final profile = await ProfileService.getMyProfile();
      final roleStr = profile['user']?['role'] as String?;
      final role = roleStr == 'EMPLOYER' ? AppRole.employer : AppRole.worker;
      return HomeScreen(role: role);
    } on ApiException {
      await _storage.delete(key: 'jwt_token');
      return const LoginScreen();
    } catch (_) {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash/splash_bg.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}