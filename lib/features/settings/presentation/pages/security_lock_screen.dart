import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/security_service.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';

class SecurityLockScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const SecurityLockScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  ConsumerState<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends ConsumerState<SecurityLockScreen> {
  final SecurityService _securityService = SecurityService();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _handleAuthentication();
  }

  Future<void> _handleAuthentication() async {
    setState(() => _isAuthenticating = true);
    final success = await _securityService.authenticate();
    setState(() => _isAuthenticating = false);
    
    if (success) {
      widget.onAuthenticated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.spaceGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NeonPulseOrb(
                percentUsed: 0.5,
                baseColor: AppColors.primary,
              ),
              const SizedBox(height: 48),
              Text(
                'MAINFRAME_LOCKED',
                style: AppTextStyles.headlineMainframe.copyWith(
                  color: AppColors.expense,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SECURITY_HANDSHAKE_REQUIRED',
                style: AppTextStyles.labelNeon.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 60),
              if (!_isAuthenticating)
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleAuthentication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'AUTHENTICATE',
                      style: AppTextStyles.labelNeon.copyWith(color: Colors.white),
                    ),
                  ),
                )
              else
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
