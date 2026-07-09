import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/auth_session.dart';
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
    _router = createAppRouter(_authSession);
    _authSession.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _storageService),
        ChangeNotifierProvider.value(value: _authSession),
        ChangeNotifierProvider.value(value: _authProvider),
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
