import 'package:go_router/go_router.dart';

import '../providers/auth_session.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/pengaduan/pengaduan_form_screen.dart';
import '../screens/pengaduan/pengaduan_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/qrcode_screen.dart';
import '../screens/reward/reward_screen.dart';
import '../screens/reward/tukar_poin_screen.dart';
import '../screens/saldo/riwayat_screen.dart';
import '../screens/saldo/tarik_saldo_screen.dart';
import '../screens/setoran/ajukan_penjemputan_screen.dart';
import '../screens/setoran/info_sampah_screen.dart';
import '../screens/setoran/penjemputan_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

const _publicRoutes = <String>{
  '/splash',
  '/login',
  '/register',
};

GoRouter createAppRouter(AuthSession authSession) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authSession,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isLoggedIn = authSession.isLoggedIn;

      if (location == '/splash') {
        return null;
      }

      if (!isLoggedIn && !_publicRoutes.contains(location)) {
        return '/login';
      }

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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Main app shell with bottom nav ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'info-sampah',
                    builder: (context, state) => const InfoSampahScreen(),
                  ),
                  GoRoute(
                    path: 'penjemputan',
                    builder: (context, state) => const PenjemputanScreen(),
                    routes: [
                      GoRoute(
                        path: 'ajukan',
                        builder: (context, state) =>
                            const AjukanPenjemputanScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tarik-saldo',
                    builder: (context, state) => const TarikSaldoScreen(),
                  ),
                  GoRoute(
                    path: 'reward',
                    builder: (context, state) => const RewardScreen(),
                    routes: [
                      GoRoute(
                        path: 'tukar',
                        builder: (context, state) =>
                            const TukarPoinScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pengaduan',
                    builder: (context, state) => const PengaduanScreen(),
                    routes: [
                      GoRoute(
                        path: 'form',
                        builder: (context, state) =>
                            const PengaduanFormScreen(),
                      ),
                    ],
                  ),
                ],
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

          // Branch 2: Profil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'qrcode',
                    builder: (context, state) => const QRCodeScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

    ],
  );
}
