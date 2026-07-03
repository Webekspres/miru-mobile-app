# 03 — State Management (Mobile)

## Provider Architecture

### 1. AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  
  bool get isLoggedIn => _token != null;
  User? get user => _user;
  bool get isLoading => _isLoading;
  
  Future<void> login(String username, String password) async { ... }
  Future<void> register(Map<String, dynamic> data) async { ... }
  Future<void> logout() async { ... }
  Future<void> checkAuthStatus() async { ... } // Cek token tersimpan
}
```

### 2. SaldoProvider
```dart
class SaldoProvider extends ChangeNotifier {
  double _saldo = 0;
  int _poin = 0;
  List<Transaksi> _riwayat = [];
  
  Future<void> loadSaldo() async { ... }
  Future<void> loadRiwayat() async { ... }
  Future<void> ajukanPenarikan(double nominal) async { ... }
}
```

### 3. PenjemputanProvider
```dart
class PenjemputanProvider extends ChangeNotifier {
  List<Penjemputan> _penjemputanList = [];
  bool _isLoading = false;
  
  Future<void> loadPenjemputan() async { ... }
  Future<void> ajukanPenjemputan(Penjemputan data) async { ... }
}
```

### 4. RewardProvider
```dart
class RewardProvider extends ChangeNotifier {
  List<Reward> _katalog = [];
  List<PenukaranPoin> _penukaranList = [];
  
  Future<void> loadKatalog() async { ... }
  Future<void> tukarPoin(int rewardId) async { ... }
}
```

### 5. PengaduanProvider
```dart
class PengaduanProvider extends ChangeNotifier {
  List<Pengaduan> _pengaduanList = [];
  
  Future<void> loadPengaduan() async { ... }
  Future<void> ajukanPengaduan(String keluhan) async { ... }
}
```

## Data Flow Pattern

### Loading Data (Pull to Refresh)
```dart
// Di Screen
RefreshIndicator(
  onRefresh: () => context.read<SaldoProvider>().loadSaldo(),
  child: ListView(...)
)

// Di Provider
Future<void> loadSaldo() async {
  _isLoading = true;
  notifyListeners();
  try {
    final response = await api.get('/users/${userId}/');
    _saldo = response['saldo'];
    _poin = response['poin'];
  } catch (e) {
    _error = 'Gagal memuat saldo';
  }
  _isLoading = false;
  notifyListeners();
}
```

### Submit Data
```dart
// Di Screen
ElevatedButton(
  onPressed: _isLoading ? null : () async {
    setState(() => _isLoading = true);
    await context.read<PengaduanProvider>().ajukanPengaduan(_keluhanText);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengaduan berhasil dikirim')),
      );
      Navigator.pop(context);
    }
  },
  child: Text('Kirim Pengaduan'),
)
```

## State per Screen

Setiap screen harus handle 4 state:
1. **Loading** — CircularProgressIndicator atau shimmer
2. **Error** — Icon error + pesan + tombol coba lagi
3. **Empty** — Ilustrasi + "Belum ada data"
4. **Success** — Tampilkan data
