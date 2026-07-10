import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/auth_session.dart';
import 'providers/home_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/pengaduan_provider.dart';
import 'providers/pengumuman_provider.dart';
import 'providers/penjemputan_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/reward_provider.dart';
import 'providers/saldo_provider.dart';
import 'providers/settings_provider.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';

class MiruApp extends StatefulWidget {
  const MiruApp({super.key});

  @override
  State<MiruApp> createState() => _MiruAppState();
}

class _MiruAppState extends State<MiruApp> {
  late final StorageService _storageService;
  late final AuthSession _authSession;
  late final AuthProvider _authProvider;
  late final HomeProvider _homeProvider;
  late final NotificationProvider _notificationProvider;
  late final PengaduanProvider _pengaduanProvider;
  late final PengumumanProvider _pengumumanProvider;
  late final PenjemputanProvider _penjemputanProvider;
  late final ProfileProvider _profileProvider;
  late final RewardProvider _rewardProvider;
  late final SaldoProvider _saldoProvider;
  late final SettingsProvider _settingsProvider;
  late final ApiClient _apiClient;
  late final AuthService _authService;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _authSession = AuthSession(_storageService);
    _apiClient = ApiClient(
      storageService: _storageService,
      authSession: _authSession,
    );
    _authService = AuthService(
      apiClient: _apiClient,
      storageService: _storageService,
      authSession: _authSession,
    );
    _authProvider = AuthProvider(
      authService: _authService,
      storageService: _storageService,
      authSession: _authSession,
    );
    _homeProvider = HomeProvider(apiClient: _apiClient);
    _notificationProvider = NotificationProvider(apiClient: _apiClient);
    _pengaduanProvider = PengaduanProvider(apiClient: _apiClient);
    _pengumumanProvider = PengumumanProvider(apiClient: _apiClient);
    _penjemputanProvider = PenjemputanProvider(apiClient: _apiClient);
    _profileProvider = ProfileProvider(apiClient: _apiClient);
    _rewardProvider = RewardProvider(apiClient: _apiClient);
    _saldoProvider = SaldoProvider(apiClient: _apiClient);
    _settingsProvider = SettingsProvider(apiClient: _apiClient);
    _router = createAppRouter(_authSession);
    _authSession.refresh();

    // Hapus semua cache provider saat logout
    _authSession.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _authSession.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!_authSession.isLoggedIn) {
      _homeProvider.clearCache();
      _saldoProvider.clearCache();
      _profileProvider.clearCache();
      _penjemputanProvider.clearCache();
      _pengaduanProvider.clearCache();
      _rewardProvider.clearCache();
      _pengumumanProvider.clearCache();
      _notificationProvider.clearCache();
      _settingsProvider.clearCache();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _storageService),
        ChangeNotifierProvider.value(value: _authSession),
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _homeProvider),
        ChangeNotifierProvider.value(value: _notificationProvider),
        ChangeNotifierProvider.value(value: _pengaduanProvider),
        ChangeNotifierProvider.value(value: _pengumumanProvider),
        ChangeNotifierProvider.value(value: _penjemputanProvider),
        ChangeNotifierProvider.value(value: _profileProvider),
        ChangeNotifierProvider.value(value: _rewardProvider),
        ChangeNotifierProvider.value(value: _saldoProvider),
        ChangeNotifierProvider.value(value: _settingsProvider),
        Provider.value(value: _apiClient),
        Provider.value(value: _authService),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
