import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/launch_experience.dart';
import '../../widgets/onboarding_scaffold.dart';

class _Slide {
  const _Slide({
    required this.asset,
    required this.title,
    required this.body,
  });

  final String asset;
  final String title;
  final String body;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _slides = [
    _Slide(
      asset: 'assets/images/onboarding_jemput.png',
      title: 'Jemput Cepat',
      body:
          'Ajukan penjemputan sampah dari rumah. Petugas MIRU datang sesuai jadwal dan mengangkut sampah Anda.',
    ),
    _Slide(
      asset: 'assets/images/onboarding_edukasi.png',
      title: 'Kelola & Daur Ulang',
      body:
          'Belajar memilah sampah, mendaur ulang, dan mengelola limbah rumah tangga dengan cara yang fleksibel dan efisien.',
    ),
    _Slide(
      asset: 'assets/images/onboarding_setor.png',
      title: 'Setor, Timbang, Dibayar',
      body:
          'Sampah dijemput atau disetor ke bank sampah, ditimbang di tempat, dan dibayar sesuai jenis yang diterima MIRU.',
    ),
  ];

  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _finish() {
    context.read<LaunchExperience>().consumeOnboarding();
    context.go('/home');
  }

  void _next() {
    if (_index >= _slides.length - 1) {
      _finish();
      return;
    }
    _page.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _page,
      itemCount: _slides.length,
      onPageChanged: (i) => setState(() => _index = i),
      itemBuilder: (context, i) {
        final slide = _slides[i];
        final last = i == _slides.length - 1;
        return OnboardingScaffold(
          imageAsset: slide.asset,
          title: slide.title,
          body: slide.body,
          buttonLabel: last ? 'Mulai' : 'Lanjut',
          onButton: _next,
          pageIndex: i,
          pageCount: _slides.length,
          showSkip: !last,
          onSkip: _finish,
        );
      },
    );
  }
}
