import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_session.dart';
import '../providers/launch_experience.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/email_verify_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifikasi/detail_notifikasi_screen.dart';
import '../screens/notifikasi/notifikasi_screen.dart';
import '../screens/pengaduan/pengaduan_form_screen.dart';
import '../screens/pengaduan/pengaduan_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/qrcode_screen.dart';
import '../screens/reward/reward_screen.dart';
import '../screens/reward/tukar_poin_screen.dart';
import '../screens/saldo/riwayat_screen.dart';
import '../screens/saldo/tarik_saldo_screen.dart';
import '../screens/setoran/ajukan_penjemputan_screen.dart';
import '../screens/edukasi/edukasi_detail_screen.dart';
import '../screens/edukasi/edukasi_list_screen.dart';
import '../screens/setoran/info_sampah_screen.dart';
import '../screens/setoran/penjemputan_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/settings/kebijakan_data_screen.dart';
import '../screens/settings/pengumuman_screen.dart';
import '../screens/settings/tentang_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';
import '../models/announcement.dart';

GoRouter createAppRouter(AuthSession authSession, LaunchExperience launch) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([authSession, launch]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = authSession.isLoggedIn;
      final needsEmail = authSession.needsEmailVerification;

      // Gate OTP email: login / session restore dengan email_required=true
      // (kecuali splash — biarkan selesai bootstrap dulu)
      if (isLoggedIn &&
          needsEmail &&
          location != '/splash' &&
          location != '/splash-preview') {
        if (location != '/verify-email') return '/verify-email';
        return null;
      }

      // Sudah verifikasi → jangan tinggal di layar OTP
      if (isLoggedIn && location == '/verify-email') {
        if (launch.pendingOnboarding) return '/onboarding';
        return '/home';
      }

      // Redirect jika sudah login mencoba akses halaman auth
      if (isLoggedIn &&
          (location == '/login' ||
              location == '/register' ||
              location == '/forgot-password' ||
              location == '/reset-password')) {
        if (launch.pendingOnboarding) return '/onboarding';
        return '/home';
      }

      if (!isLoggedIn && location == '/onboarding') {
        return '/login';
      }

      return null;
    },
    routes: [
      // ── Auth routes (no bottom nav) ──
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Preview route untuk development splash screen.
      // Ubah `initialLocation` ke '/splash-preview' di atas
      // untuk melihat splash screen tanpa auto-redirect.
      GoRoute(
        path: '/splash-preview',
        builder: (context, state) =>
            const SplashScreen(previewMode: true),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final pending = state.extra is Map ? state.extra! as Map : null;
          return RegisterScreen(
            pendingUsername: pending?['username'] as String?,
            pendingPassword: pending?['password'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => ResetPasswordScreen(
          initialToken: state.extra as String?,
        ),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerifyScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Main app shell with bottom nav ──
      // Hanya halaman utama (root pages) ada di dalam StatefulShellRoute.
      // Halaman detail (tarik saldo, penjemputan, dll) adalah standalone
      // sehingga bottom nav hilang dan routing behavior lebih intuitif.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Beranda
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Riwayat
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/riwayat',
                builder: (context, state) => const RiwayatScreen(),
              ),
            ],
          ),

          // Branch 2: Notifikasi
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifikasi',
                builder: (context, state) => const NotifikasiScreen(),
              ),
            ],
          ),

          // Branch 3: Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Detail Screens (standalone, no bottom nav) ──
      // Halaman-halaman ini tidak memiliki bottom nav
      // agar pengalaman navigasi lebih intuitif.
      GoRoute(
        path: '/notifikasi/detail',
        redirect: (context, state) {
          if (state.extra is! AppNotification) return '/notifikasi';
          return null;
        },
        builder: (context, state) => DetailNotifikasiScreen(
          notification: state.extra! as AppNotification,
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        redirect: (context, state) {
          if (state.extra is! User) return '/profile';
          return null;
        },
        builder: (context, state) => EditProfileScreen(
          initialUser: state.extra! as User,
        ),
      ),
      GoRoute(
        path: '/pengumuman/detail',
        redirect: (context, state) {
          if (state.extra is! Announcement) return '/home';
          return null;
        },
        builder: (context, state) => PengumumanDetailScreen(
          item: state.extra! as Announcement,
        ),
      ),
      GoRoute(
        path: '/home/tarik-saldo',
        builder: (context, state) => const TarikSaldoScreen(),
      ),
      GoRoute(
        path: '/home/penjemputan',
        builder: (context, state) => const PenjemputanScreen(),
        routes: [
          GoRoute(
            path: 'ajukan',
            builder: (context, state) => const AjukanPenjemputanScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home/info-sampah',
        builder: (context, state) => const InfoSampahScreen(),
      ),
      GoRoute(
        path: '/home/edukasi',
        builder: (context, state) => const EdukasiListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return EdukasiDetailScreen(edukasiId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/home/reward',
        builder: (context, state) => const RewardScreen(),
        routes: [
          GoRoute(
            path: 'tukar',
            builder: (context, state) => const TukarPoinScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/home/pengaduan',
        builder: (context, state) => const PengaduanScreen(),
        routes: [
          GoRoute(
            path: 'form',
            builder: (context, state) => const PengaduanFormScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile/qrcode',
        builder: (context, state) => const QRCodeScreen(),
      ),

      // Kebijakan / Tentang — top-level (register consent + profil)
      GoRoute(
        path: '/settings/kebijakan-data',
        builder: (context, state) => const KebijakanDataScreen(),
      ),
      GoRoute(
        path: '/settings/tentang',
        builder: (context, state) => const TentangScreen(),
      ),
    ],
  );
}
