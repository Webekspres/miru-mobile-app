# 03 — State Management (Mobile)

> **Integrasi API:** Lihat `04-api-integration.md` untuk Dio client & JSON Envelope.
> **Role & alur:** Lihat `10-integration-and-roles.md`.

## Provider Architecture

### 1. AuthProvider

```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _user != null;
  bool get isNasabah => _user?.role == 'nasabah';
  User? get user => _user;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.login(username, password);
      if (result.user.role != 'nasabah') {
        await _authService.logout();
        throw ApiException('Akun ini hanya untuk Web Admin.');
      }
      _user = result.user;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    if (await _authService.hasToken()) {
      _user = await _authService.getMe(); // GET /api/auth/me/
      notifyListeners();
    }
  }

  Future<void> logout() async { ... }
}
```

### 2. SaldoProvider

Memuat data dari `GET /api/auth/me/` (saldo, poin) dan riwayat:

```dart
Future<void> loadSaldo() async {
  final user = await _api.get('/auth/me/', fromJson: User.fromJson);
  _saldo = user.saldo;
  _poin = user.poin;
}

Future<void> loadRiwayat() async {
  final deposits = await _api.getList('/deposits/', query: {'nasabah': userId});
  final withdrawals = await _api.getList('/withdrawals/', query: {'nasabah': userId});
  // merge & sort by tanggal
}
```

### 3. PenjemputanProvider

- `loadPenjemputan()` → `GET /pickups/?nasabah={id}`
- `ajukanPenjemputan()` → `POST /pickups/`

### 4. RewardProvider

- `loadKatalog()` → `GET /rewards/`
- `tukarPoin(rewardId)` → `POST /reward-redemptions/`

### 5. PengaduanProvider

- `loadPengaduan()` → `GET /complaints/?nasabah={id}`
- `ajukanPengaduan()` → `POST /complaints/`

## JSON Envelope di Provider

Dio `EnvelopeInterceptor` unwrap `data` sebelum sampai ke provider. Provider menerima payload langsung:

```dart
// Setelah interceptor — response.data sudah unwrapped
final user = User.fromJson(response.data as Map<String, dynamic>);
```

Jika interceptor tidak dipakai, parse manual:

```dart
final envelope = ApiEnvelope<User>.fromJson(
  response.data,
  (json) => User.fromJson(json as Map<String, dynamic>),
);
if (!envelope.success) throw ApiException(envelope.message);
final user = envelope.data!;
```

## Data Flow Pattern

### Loading (Pull to Refresh)

```dart
RefreshIndicator(
  onRefresh: () async {
    await context.read<SaldoProvider>().loadSaldo();
    await context.read<SaldoProvider>().loadRiwayat();
  },
  child: ListView(...),
)
```

### Submit dengan Error Envelope

```dart
try {
  await context.read<PengaduanProvider>().ajukanPengaduan(keluhan);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengaduan berhasil dikirim')),
    );
  }
} on ApiException catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message)),
    );
  }
}
```

## State per Screen

Setiap screen handle 4 state:

| State | UI |
|-------|-----|
| **Loading** | `CircularProgressIndicator` atau shimmer |
| **Error** | Icon + pesan + tombol "Coba Lagi" |
| **Empty** | Ilustrasi + "Belum ada data" |
| **Success** | Tampilkan data |

## Provider Registration

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProxyProvider<AuthProvider, SaldoProvider>(...),
    ChangeNotifierProvider(create: (_) => PenjemputanProvider()),
    ChangeNotifierProvider(create: (_) => RewardProvider()),
    ChangeNotifierProvider(create: (_) => PengaduanProvider()),
  ],
  child: MyApp(),
)
```

## Konvensi Data

- Uang/saldo: parse `String` → `double` untuk display, format `NumberFormat.currency(locale: 'id_ID')`
- Timestamp: `DateTime.parse()` — tampilkan format Indonesia
- Pagination: baca `meta.pagination` jika list panjang (infinite scroll planned post-MVP)
