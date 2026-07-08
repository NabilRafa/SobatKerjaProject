import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const AuthHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -60,
            left: -20,
            child: Transform.rotate(
              angle: 0.45,
              child: Container(
                width: 140,
                height: 300,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 10,
            child: Transform.rotate(
              angle: 0.45,
              child: Container(
                width: 100,
                height: 260,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 28),
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/splash/icon.png',
                      width: 150,
                      height: 110,
                      fit: BoxFit.contain,
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
}
