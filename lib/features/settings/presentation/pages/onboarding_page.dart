import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/neon_ui_kit.dart';
import '../../data/notification_settings_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isRunningDiagnostics = false;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'WELCOME TO THE GRID',
      description: 'Your financial mainframe is online. Track every data packet (dollar) with precision.',
      icon: Icons.grid_view_rounded,
      color: AppColors.primary,
    ),
    OnboardingSlide(
      title: 'THE PULSE ORB',
      description: 'Monitor your spending velocity in real-time. If the pulse turns red, the system is in critical load.',
      icon: Icons.bolt_rounded,
      color: AppColors.accent,
    ),
    OnboardingSlide(
      title: 'STRATEGY DOJO',
      description: 'Master the arts of zero-sum budgeting and subscription purging to optimize your net worth.',
      icon: Icons.psychology_rounded,
      color: AppColors.income,
    ),
    OnboardingSlide(
      title: 'AI PROJECTION',
      description: 'The mainframe predicts your future balance based on current spending trajectory.',
      icon: Icons.radar_rounded,
      color: AppColors.warning,
    ),
  ];

  void _startDiagnostics() {
    setState(() => _isRunningDiagnostics = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRunningDiagnostics) {
      return const DiagnosticsConsole();
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.spaceGradient),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _buildSlide(_slides[index]),
            ),
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => _buildDot(index == _currentPage),
                    ),
                  ),
                  _buildActionButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonPulseOrb(percentUsed: 0.5, baseColor: slide.color),
          const SizedBox(height: 60),
          Text(
            slide.title,
            style: AppTextStyles.headlineMainframe.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            slide.description,
            style: AppTextStyles.bodyMain,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: active ? 24 : 8,
      decoration: BoxDecoration(
        color: active ? AppColors.accent : AppColors.textMuted,
        borderRadius: BorderRadius.circular(4),
        boxShadow: active ? [
          BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: 8),
        ] : null,
      ),
    );
  }

  Widget _buildActionButton() {
    final isLast = _currentPage == _slides.length - 1;
    return TextButton(
      onPressed: () {
        if (isLast) {
          _startDiagnostics();
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Text(
        isLast ? 'INITIALIZE' : 'NEXT',
        style: AppTextStyles.labelNeon.copyWith(
          color: AppColors.accent,
          fontSize: 16,
        ),
      ),
    );
  }
}

class DiagnosticsConsole extends ConsumerStatefulWidget {
  const DiagnosticsConsole({super.key});

  @override
  ConsumerState<DiagnosticsConsole> createState() => _DiagnosticsConsoleState();
}

class _DiagnosticsConsoleState extends ConsumerState<DiagnosticsConsole> {
  final List<String> _log = [];
  int _currentLine = 0;
  late Timer _timer;

  final List<String> _bootSequence = [
    'SYSTEM_BOOT_SEQUENCE_ALPHA_LOAD...',
    'INITIALIZING_KERNEL_V0.1.0',
    'MOUNTING_LOCAL_HIVE_DATABASE...',
    'CONNECTING_TO_THE_GRID...',
    'LOADING_NEON_PALETTE_RESOURCES...',
    'CALIBRATING_PULSE_ORBS...',
    'SYNCING_AI_PROJECTION_ENGINES...',
    'SCANNING_FOR_ANOMALIES...',
    'OPTIMIZING_DOJO_MODULES...',
    'ACCESS_GRANTED.',
    'WELCOME_TO_THE_GRID_USER_SYNTH_X_84',
    'MAINFRAME_ONLINE.'
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_currentLine < _bootSequence.length) {
        setState(() {
          _log.add(_bootSequence[_currentLine]);
          _currentLine++;
        });
      } else {
        timer.cancel();
        _completeOnboarding();
      }
    });
  }

  Future<void> _completeOnboarding() async {
    await Future.delayed(const Duration(seconds: 1));
    await ref.read(notificationSettingsProvider.notifier).setOnboardingComplete();
    if (mounted) context.go('/');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          // Log Text
          Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: ListView.builder(
                    itemCount: _log.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '> ${_log[index]}',
                        style: AppTextStyles.labelNeon.copyWith(
                          color: _log[index] == 'MAINFRAME_ONLINE.' 
                              ? AppColors.income 
                              : AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scanline Effect
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.48, 0.5, 0.52],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
