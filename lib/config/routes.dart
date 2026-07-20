import 'package:go_router/go_router.dart';

import '../providers/auth_session.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifikasi/notifikasi_screen.dart';
import '../screens/pengaduan/pengaduan_form_screen.dart';
import '../screens/pengaduan/pengaduan_screen.dart';
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
import '../screens/splash/splash_screen.dart';
import '../screens/settings/kebijakan_data_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/tentang_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

GoRouter createAppRouter(AuthSession authSession) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authSession,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = authSession.isLoggedIn;

      // Hanya redirect jika sudah login mencoba akses login/register
      if (isLoggedIn && (location == '/login' || location == '/register')) {
        return '/home';
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
        builder: (context, state) => const RegisterScreen(),
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

      // ── Settings Routes (standalone, no bottom nav) ──
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'kebijakan-data',
            builder: (context, state) => const KebijakanDataScreen(),
          ),
          GoRoute(
            path: 'tentang',
            builder: (context, state) => const TentangScreen(),
          ),
        ],
      ),
    ],
  );
}
