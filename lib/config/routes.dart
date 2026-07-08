import 'package:go_router/go_router.dart';

import '../providers/auth_session.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/pengaduan/pengaduan_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/qrcode_screen.dart';
import '../screens/reward/reward_screen.dart';
import '../screens/saldo/riwayat_screen.dart';
import '../screens/saldo/tarik_saldo_screen.dart';
import '../screens/setoran/info_sampah_screen.dart';
import '../screens/setoran/penjemputan_screen.dart';
import '../screens/splash/splash_screen.dart';

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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/qrcode',
        builder: (context, state) => const QRCodeScreen(),
      ),
      GoRoute(
        path: '/info-sampah',
        builder: (context, state) => const InfoSampahScreen(),
      ),
      GoRoute(
        path: '/penjemputan',
        builder: (context, state) => const PenjemputanScreen(),
      ),
      GoRoute(
        path: '/riwayat',
        builder: (context, state) => const RiwayatScreen(),
      ),
      GoRoute(
        path: '/tarik-saldo',
        builder: (context, state) => const TarikSaldoScreen(),
      ),
      GoRoute(
        path: '/reward',
        builder: (context, state) => const RewardScreen(),
      ),
      GoRoute(
        path: '/pengaduan',
        builder: (context, state) => const PengaduanScreen(),
      ),
    ],
  );
}
