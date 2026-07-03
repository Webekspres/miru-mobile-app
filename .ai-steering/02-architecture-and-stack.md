# 02 — Architecture & Stack (Mobile)

## Tech Stack

| Komponen | Teknologi | Versi |
|----------|-----------|-------|
| Framework | Flutter | 3.x (Dart SDK ^3.12.2) |
| State Management | Provider | (perlu ditambahkan) |
| HTTP Client | Dio | (perlu ditambahkan) |
| Storage | flutter_secure_storage | (perlu ditambahkan) |
| Routing | go_router | (perlu ditambahkan) |
| QR Code | qr_flutter / mobile_scanner | (perlu ditambahkan) |
| Icons | Material Icons + Cupertino Icons | sudah tersedia (cupertino_icons) |
| Linting | flutter_lints ^6.0.0 | sudah tersedia |

## Arsitektur

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Nasabah)                 │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │    Screens   │──│   Providers  │──│   Services   │  │
│  │  (UI Pages)  │  │ (State/Logic)│  │ (API/Auth)   │  │
│  └──────────────┘  └──────────────┘  └──────┬───────┘  │
│                                              │           │
│  ┌──────────────┐               ┌───────────┴──────────┐│
│  │   Widgets    │               │   Dio HTTP Client    ││
│  │ (Reusable)   │               │  (JWT Interceptor)   ││
│  └──────────────┘               └───────────┬──────────┘│
│                                              │           │
└──────────────────────────────────────────────┼───────────┘
                                               │
                                               ▼
                                    Backend API (Django)
                                    http://10.0.2.2:8000/api/
                                         (atau domain production)
```

## Architecture Pattern: Provider + Service

```
User Action → Screen (UI) → Provider (Logic) → Service (API/Storage) → Backend
                ↑                                │
                └────────────────────────────────┘
                         (notifyListeners)
```

## Arsitektur Navigasi (go_router)

```dart
final router = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    // Check if logged in → redirect accordingly
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn
    // If not logged in → /login
    // If logged in → /home
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
    GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/profile', builder: (_, __) => ProfileScreen()),
    GoRoute(path: '/qrcode', builder: (_, __) => QRCodeScreen()),
    GoRoute(path: '/info-sampah', builder: (_, __) => InfoSampahScreen()),
    GoRoute(path: '/penjemputan', builder: (_, __) => PenjemputanScreen()),
    GoRoute(path: '/riwayat', builder: (_, __) => RiwayatScreen()),
    GoRoute(path: '/tarik-saldo', builder: (_, __) => TarikSaldoScreen()),
    GoRoute(path: '/reward', builder: (_, __) => RewardScreen()),
    GoRoute(path: '/pengaduan', builder: (_, __) => PengaduanScreen()),
  ],
)
```

## Environment
```dart
class AppConstants {
  // Ganti ke domain production saat rilis
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const Duration tokenExpiry = Duration(hours: 24);
}
```
