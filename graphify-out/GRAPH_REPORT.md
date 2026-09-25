# Graph Report - mobile  (2026-09-17)

## Corpus Check
- 137 files · ~248,731 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1962 nodes · 2940 edges · 132 communities (123 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `39fd940e`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- ../../widgets/shimmer_loading.dart
- README.md
- MIRU Bank Sampah — Mobile App (Miru-G)
- 04 — API Integration (Mobile)
- Ringkasan Aturan untuk UI Mobile
- 09 — Data Dictionary & Reference Values (Mobile)
- 10 — Integration & Roles (Mobile App)
- 03 — State Management (Mobile)
- Aturan Clean Code
- ⚠️ Batasan KERAS — Jangan Implementasikan di Mobile
- 01 — Project Overview (Mobile App)
- AppDelegate
- api_envelope.dart
- edukasi_detail_screen.dart
- Desain Halaman
- qrcode_screen.dart
- 02 — Architecture & Stack (Mobile)
- graphify
- constants.dart
- 12 — Play Console Internal Testing (Staging untuk Stakeholder)
- user.dart
- RTK - Rust Token Killer
- MIRU Mobile App — Agent Rules
- pickup.dart
- routes.dart
- forgot_password_screen.dart
- profile_provider_test.dart
- auth_service.dart
- MainActivity.kt
- harga_berlaku_banner.dart
- pengaduan_provider.dart
- reset_password_screen.dart
- auth_interceptor.dart
- tarik_saldo_screen.dart
- ajukan_penjemputan_screen.dart
- shimmer_loading.dart
- register_screen.dart
- app.dart
- saldo_provider.dart
- auth_provider.dart
- reward_screen.dart
- penjemputan_screen.dart
- institution_settings.dart
- notifikasi_screen.dart
- StatelessWidget
- withdrawal.dart
- complaint.dart
- reward_redemption.dart
- deposit.dart
- theme.dart
- activity_item.dart
- penjemputan_provider.dart
- package:provider/provider.dart
- edit_profile_screen.dart
- deposit_detail.dart
- home_provider.dart
- complete_profile_dialog.dart
- 11 — Security & Privacy (Mobile — mirumobileapp)
- notification_provider.dart
- reward_provider.dart
- settings_provider.dart
- pengaduan_screen.dart
- riwayat_screen.dart
- test_http.dart
- Selesai
- login_screen.dart
- HomeProvider
- home_screen.dart
- miru_logo.dart
- edukasi_provider.dart
- notification.dart
- info_sampah_screen.dart
- phone_verify_screen.dart
- profile_provider.dart
- reward.dart
- avatar_picker.dart
- ../../providers/auth_session.dart
- package:dio/dio.dart
- profile_screen.dart
- pengaduan_form_screen.dart
- waste_category.dart
- json_parsing.dart
- storage_service.dart
- load_when_visible.dart
- DateTime?
- edukasi_card.dart
- String?
- 3. Alur User Journey Nasabah
- onboarding_scaffold.dart
- Route /login
- bottom_nav_scaffold.dart
- AuthProvider
- saldo_card.dart
- empty_state.dart
- bool get
- ../config/theme.dart
- splash_screen.dart
- konten_edukasi.dart
- launch_experience.dart
- _
- home_qr_button.dart
- pengumuman_provider.dart
- LaunchImage.imageset/README.md
- PengumumanProvider
- bool?
- auth_provider_test.dart
- pengumuman_screen.dart
- tarik_saldo_screen_test.dart
- login_screen_test.dart
- _buildRecentActivity
- app_scaffold.dart
- SaldoProvider
- VoidCallback
- package:flutter/foundation.dart
- login_prompt.dart
- AuthSession
- parse_dio_error_test.dart
- 3. Autentikasi
- 4. Build AAB untuk Internal testing
- exit_dialog.dart
- package:flutter/material.dart
- 5. Upload & rilis Internal testing
- 7. Checklist rilis UAT (per build)
- _buildInfoSection
- edukasi_provider_test.dart
- placeholder_screen.dart
- _buildPublicPriceInfo

## God Nodes (most connected - your core abstractions)
1. `AuthSession` - 47 edges
2. `HomeProvider` - 46 edges
3. `AuthProvider` - 39 edges
4. `ProfileProvider` - 25 edges
5. `_` - 17 edges
6. `LaunchExperience` - 15 edges
7. `EdukasiProvider` - 13 edges
8. `ApiClient` - 13 edges
9. `11 — Security & Privacy (Mobile — mirumobileapp)` - 13 edges
10. `MIRU Bank Sampah — Mobile App (Miru-G)` - 13 edges

## Surprising Connections (you probably didn't know these)
- `build` --references--> `AuthSession`  [EXTRACTED]
  lib/screens/pengaduan/pengaduan_form_screen.dart → lib/providers/auth_session.dart
- `_loadData` --references--> `HomeProvider`  [EXTRACTED]
  lib/screens/setoran/info_sampah_screen.dart → lib/providers/home_provider.dart
- `_load` --references--> `HomeProvider`  [EXTRACTED]
  lib/widgets/harga_berlaku_banner.dart → lib/providers/home_provider.dart
- `_ForgotPasswordScreenState` --references--> `AuthProvider`  [EXTRACTED]
  lib/screens/auth/forgot_password_screen.dart → lib/providers/auth_provider.dart
- `_submitOtp` --references--> `AuthProvider`  [EXTRACTED]
  lib/screens/auth/forgot_password_screen.dart → lib/providers/auth_provider.dart

## Import Cycles
- None detected.

## Communities (132 total, 4 thin omitted)

### Community 0 - "../../widgets/shimmer_loading.dart"
Cohesion: 0.18
Nodes (15): SettingsProvider, initState, build, createState, initState, KebijakanDataScreen, _KebijakanDataScreenState, build (+7 more)

### Community 2 - "MIRU Bank Sampah — Mobile App (Miru-G)"
Cohesion: 0.10
Nodes (21): 1. Install Dependencies, 2. Konfigurasi API URL, 3. Jalankan Backend & Seed Data, 4. Run App, 5. Akun Demo (Registrasi atau Seed Full), Autentikasi, Batasan Penting, Branding (+13 more)

### Community 3 - "04 — API Integration (Mobile)"
Cohesion: 0.15
Nodes (13): 04 — API Integration (Mobile), 10. Batasan Mobile, 1. Base Configuration, 2. JSON Envelope — WAJIB Dipahami, 4. API Client (Dio), 5. Endpoint Mobile (Nasabah), 6. Error Handling, 7. Models — Konvensi (+5 more)

### Community 4 - "Ringkasan Aturan untuk UI Mobile"
Cohesion: 0.11
Nodes (17): 05 — Business Rules & SOPs (Mobile), 10. Kartu Digital (QR Code), 11. Standar Waktu yang Ditampilkan ke Nasabah, 12. Jam Layanan, 13. Informasi Penting Lainnya, 1. Registrasi Nasabah, 2. Dashboard, 3. Informasi Sampah (+9 more)

### Community 5 - "09 — Data Dictionary & Reference Values (Mobile)"
Cohesion: 0.12
Nodes (16): 09 — Data Dictionary & Reference Values (Mobile), A. INFORMASI HARGA — Tampilkan di Home & Info Sampah, B. PANDUAN PEMILAHAN (untuk Info Edukasi), C. KATALOG REWARD (tampilkan di menu Tukar Poin), D. STATUS PENJEMPUTAN — Warna & Ikon untuk UI, E. INDIKATOR POIN (informasi di halaman Tukar Poin), F. JENIS PENGADUAN (untuk dropdown pilihan), Format Berat (+8 more)

### Community 6 - "10 — Integration & Roles (Mobile App)"
Cohesion: 0.20
Nodes (10): 10 — Integration & Roles (Mobile App), 1. Role di Mobile App, 2. Matriks Fitur Nasabah vs Staff, 4. Data yang Bisa Diakses Nasabah, 5. QR Code — Kartu Digital, 6. Integrasi dengan Web Admin, 7. Dependensi Backend, 8. Diagram Arsitektur (+2 more)

### Community 7 - "03 — State Management (Mobile)"
Cohesion: 0.13
Nodes (14): 03 — State Management (Mobile), 1. AuthProvider, 2. SaldoProvider, 3. PenjemputanProvider, 4. RewardProvider, 5. PengaduanProvider, Data Flow Pattern, JSON Envelope di Provider (+6 more)

### Community 8 - "Aturan Clean Code"
Cohesion: 0.17
Nodes (11): 00 — System Prompt & Clean Code Rules (Mobile), 1. Struktur Folder, 2. Models (Data Classes), 3. State Management, 4. UI Patterns, 5. API Integration, 6. Error Handling, 7. Performance (+3 more)

### Community 9 - "⚠️ Batasan KERAS — Jangan Implementasikan di Mobile"
Cohesion: 0.22
Nodes (9): 1. TIDAK ADA Pembayaran Otomatis, 2. TIDAK ADA Live GPS Tracking, 3. TIDAK ADA Scan KTP/Face Recognition, 4. TIDAK ADA Integrasi Dukcapil, 5. Hanya Nasabah yang Login, 6. Prioritas Android, 7. Koneksi Internet Diperlukan, 8. Bahasa Indonesia (+1 more)

### Community 10 - "01 — Project Overview (Mobile App)"
Cohesion: 0.20
Nodes (10): 01 — Project Overview (Mobile App), Fitur Utama (Mobile — Nasabah), Informasi Branding, Jam Layanan, Latar Belakang, Platform, Posisi dalam Ekosistem, Referensi Dokumen Terkait (+2 more)

### Community 11 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 12 - "api_envelope.dart"
Cohesion: 0.05
Nodes (35): api_exception.dart, ApiEnvelope, ApiMeta, code, data, errors, fromJson, message (+27 more)

### Community 13 - "edukasi_detail_screen.dart"
Cohesion: 0.14
Nodes (17): EdukasiProvider, _ArticleBody, build, createState, EdukasiDetailScreen, _EdukasiDetailScreenState, edukasiId, _ensureLoaded (+9 more)

### Community 14 - "Desain Halaman"
Cohesion: 0.25
Nodes (7): 07 — Modules & Features (Mobile), 14 Fitur Mobile — untuk Nasabah, Desain Halaman, HomeScreen (Dashboard), PenjemputanScreen, RewardScreen, TarikSaldoScreen

### Community 15 - "qrcode_screen.dart"
Cohesion: 0.09
Nodes (22): BoxDecoration get, dart:math, dart:ui, _backRow, _buildActionButtons, _buildFlipCard, _buildQrBlock, _buildUsageInfo (+14 more)

### Community 16 - "02 — Architecture & Stack (Mobile)"
Cohesion: 0.29
Nodes (6): 02 — Architecture & Stack (Mobile), Architecture Pattern: Provider + Service, Arsitektur, Arsitektur Navigasi (go_router), Environment, Tech Stack

### Community 17 - "graphify"
Cohesion: 0.29
Nodes (6): ⚠️ AI Steering — baca on-demand (jangan semua sekaligus), Aturan Keras, graphify, MIRU Bank Sampah — Mobile App Nasabah (Flutter), Prioritas Platform, Referensi Cepat

### Community 18 - "constants.dart"
Cohesion: 0.11
Nodes (16): accessTokenKey, apiBaseUrl, AppConstants, appName, connectTimeout, receiveTimeout, refreshTokenKey, tokenExpiry (+8 more)

### Community 19 - "12 — Play Console Internal Testing (Staging untuk Stakeholder)"
Cohesion: 0.15
Nodes (13): 10. Definisi selesai (untuk jalur ini), 12 — Play Console Internal Testing (Staging untuk Stakeholder), 1. Mengapa Internal testing, 2.1 Akun & organisasi, 2.2 Backend & konfigurasi app, 2.3 Listing minimal agar track testing aktif, 2. Prasyarat, 3. Alur one-time (setup) (+5 more)

### Community 20 - "user.dart"
Cohesion: 0.07
Nodes (27): alamat, avatarUrl, copyWith, dateJoined, fromJson, hasCompleteAddress, id, isActive (+19 more)

### Community 21 - "RTK - Rust Token Killer"
Cohesion: 0.33
Nodes (5): graphify, Hook-Based Usage, Installation Verification, Meta Commands (always use rtk directly), RTK - Rust Token Killer

### Community 22 - "MIRU Mobile App — Agent Rules"
Cohesion: 0.40
Nodes (4): Graphify Knowledge Graph, MIRU Mobile App — Agent Rules, Stack, Token Savers (WAJIB)

### Community 23 - "pickup.dart"
Cohesion: 0.07
Nodes (26): Color get, dijadwalkan,
  dalamPerjalanan,
  dijemput,
  selesai,, alamatJemput, apiValue, badgeColor, displayLabel, ditolak, estimasiBerat (+18 more)

### Community 24 - "routes.dart"
Cohesion: 0.05
Nodes (43): createAppRouter, asset, body, build, createState, dispose, _index, _next (+35 more)

### Community 25 - "forgot_password_screen.dart"
Cohesion: 0.08
Nodes (25): _applyFieldErrors, _clearFieldErrors, createState, dispose, _extractError, _fieldErrorOtp, _fieldErrorPhone, _fieldErrorUsername (+17 more)

### Community 26 - "profile_provider_test.dart"
Cohesion: 0.11
Nodes (17): dart:async, dart:convert, dart:typed_data, Duration?, HttpClientAdapter, ScriptedAdapter, _body, close (+9 more)

### Community 27 - "auth_service.dart"
Cohesion: 0.09
Nodes (22): api_client.dart, apiClient, _asJsonMap, AuthService, authSession, forgotPassword, getAccessToken, getMe (+14 more)

### Community 28 - "MainActivity.kt"
Cohesion: 0.60
Nodes (3): MainActivity, Bundle, FlutterActivity

### Community 29 - "harga_berlaku_banner.dart"
Cohesion: 0.10
Nodes (20): @visibleForTesting, build, _bulanIdEn, createState, err, HargaBerlakuBanner, _HargaBerlakuBannerState, initState (+12 more)

### Community 30 - "pengaduan_provider.dart"
Cohesion: 0.12
Nodes (16): _apiClient, clearCache, clearError, clearSubmitError, closedComplaints, _complaints, createComplaint, _error (+8 more)

### Community 31 - "reset_password_screen.dart"
Cohesion: 0.11
Nodes (18): _canSubmit, _confirmPasswordController, createState, dispose, _formKey, _hasToken, initialToken, initState (+10 more)

### Community 32 - "auth_interceptor.dart"
Cohesion: 0.13
Nodes (14): Future, AuthInterceptor, authSession, _clearSession, _doRefresh, _isPublicPath, onError, onRequest (+6 more)

### Community 33 - "tarik_saldo_screen.dart"
Cohesion: 0.06
Nodes (36): File?, _besarNominal, _buildQuickAmountChips, createState, dispose, _extractFieldError, _formatRupiah, formatter (+28 more)

### Community 34 - "ajukan_penjemputan_screen.dart"
Cohesion: 0.05
Nodes (37): _alamatController, _ambilLokasi, _beratController, _buildInfoHeader, category, createState, dispose, empty (+29 more)

### Community 35 - "shimmer_loading.dart"
Cohesion: 0.10
Nodes (21): Animation, AnimationController, _animation, borderRadius, build, child, _controller, createState (+13 more)

### Community 36 - "register_screen.dart"
Cohesion: 0.06
Nodes (32): _applyFieldErrors, _buildStep2, _clearFieldErrors, createState, dispose, _extractError, _fieldErrorConsent, _fieldErrorNama (+24 more)

### Community 37 - "app.dart"
Cohesion: 0.06
Nodes (31): config/routes.dart, GoRouter, _apiClient, _authProvider, _authService, _authSession, build, createState (+23 more)

### Community 38 - "saldo_provider.dart"
Cohesion: 0.07
Nodes (26): _activeFilter, _apiClient, clearCache, clearError, clearSubmitError, createWithdrawal, _currentUserId, ensureLoaded (+18 more)

### Community 39 - "auth_provider.dart"
Cohesion: 0.07
Nodes (26): auth_session.dart, authService, authSession, checkAuthStatus, clearError, _clearSession, _error, forgotPassword (+18 more)

### Community 40 - "reward_screen.dart"
Cohesion: 0.12
Nodes (18): RewardProvider, createState, initState, _loadData, onTukar, _onTukarTap, poin, _PoinHeaderCard (+10 more)

### Community 41 - "penjemputan_screen.dart"
Cohesion: 0.14
Nodes (16): Pickup, PenjemputanProvider, _submit, _buildTabContent, createState, dispose, initState, _loadData (+8 more)

### Community 42 - "institution_settings.dart"
Cohesion: 0.10
Nodes (19): alamat, email, fromJson, InstitutionSettings, isDiLuarJamKerja, jamBuka, jamBukaTime, jamOperasional (+11 more)

### Community 43 - "notifikasi_screen.dart"
Cohesion: 0.11
Nodes (21): ChangeNotifier, AppNotification, NotificationProvider, build, DetailNotifikasiScreen, notification, createState, isUnread (+13 more)

### Community 44 - "StatelessWidget"
Cohesion: 0.13
Nodes (15): _ActivityItemWidget, _AnnouncementBanner, _ConfirmationRow, _MetodeSelector, _SaldoDisplayCard, _SlaInfoBanner, _CategoryPickerTile, _DatePickerTile (+7 more)

### Community 45 - "withdrawal.dart"
Cohesion: 0.09
Nodes (21): apiValue, displayLabel, ditolak, fromApiValue, fromJson, id, listFromJson, metode (+13 more)

### Community 46 - "complaint.dart"
Cohesion: 0.10
Nodes (20): hargaTidakSesuai,
  petugasTidakDatang,
  kesalahanData,
  buktiTidakMuncul,, apiValue, ComplaintStatus, displayLabel, ditutup, fromApiValue, fromJson, id (+12 more)

### Community 47 - "reward_redemption.dart"
Cohesion: 0.09
Nodes (21): apiValue, createPayload, displayLabel, fromApiValue, fromJson, id, listFromJson, nasabah (+13 more)

### Community 48 - "deposit.dart"
Cohesion: 0.10
Nodes (20): deposit_detail.dart, buktiDigital, Deposit, DepositDigitalProof, details, fromJson, id, listFromJson (+12 more)

### Community 49 - "theme.dart"
Cohesion: 0.22
Nodes (8): AppTheme, errorColor, primaryColor, primaryDark, surfaceColor, _textTheme, static const Color, static const TextTheme

### Community 50 - "activity_item.dart"
Cohesion: 0.08
Nodes (24): ActivityItem, ActivityType, apiValue, details, displayLabel, fromApiValue, fromJson, id (+16 more)

### Community 51 - "penjemputan_provider.dart"
Cohesion: 0.13
Nodes (14): activePickups, _apiClient, clearCache, clearError, createPickup, _currentUserId, _error, hasError (+6 more)

### Community 52 - "package:provider/provider.dart"
Cohesion: 0.09
Nodes (28): edukasi_card.dart, build, createState, EdukasiListScreen, _EdukasiListScreenState, _confirmRedemption, createState, initState (+20 more)

### Community 53 - "edit_profile_screen.dart"
Cohesion: 0.12
Nodes (16): _alamatController, _buildLabel, createState, dispose, EditProfileScreen, _EditProfileScreenState, _formKey, initialUser (+8 more)

### Community 54 - "deposit_detail.dart"
Cohesion: 0.14
Nodes (13): beratKg, beratKgAsDouble, DepositDetail, fromJson, hargaSaatItu, hargaSaatItuAsDouble, id, kategori (+5 more)

### Community 55 - "home_provider.dart"
Cohesion: 0.08
Nodes (23): _apiClient, _categories, clearCache, _error, _fetchDashboard, fetchEarliestUpcomingTanggalBerlaku, _fetchGeneration, _fetchRecentActivity (+15 more)

### Community 56 - "complete_profile_dialog.dart"
Cohesion: 0.15
Nodes (12): editUser, false, goEdit, home, profile, showCompleteProfileDialog, theme, updated (+4 more)

### Community 57 - "11 — Security & Privacy (Mobile — mirumobileapp)"
Cohesion: 0.11
Nodes (18): 10. Checklist Go-Live Keamanan (Mobile), 11. Mapping Task List, 11 — Security & Privacy (Mobile — mirumobileapp), 12. Aturan untuk AI / Engineer, 1. Ruang Lingkup, 2. Autentikasi & Token Storage, 3. Keamanan Kartu Digital (QR), 4. Komunikasi API (+10 more)

### Community 58 - "notification_provider.dart"
Cohesion: 0.09
Nodes (21): int get, _apiClient, clearCache, ensureLoaded, _error, hasError, _hasLoaded, _isFetching (+13 more)

### Community 59 - "reward_provider.dart"
Cohesion: 0.12
Nodes (16): _apiClient, clearCache, clearError, clearSubmitError, createRedemption, _error, hasError, hasSubmitError (+8 more)

### Community 60 - "settings_provider.dart"
Cohesion: 0.17
Nodes (11): InstitutionSettings? get, _apiClient, clearCache, _error, hasError, _isLoading, loadSettings, refresh (+3 more)

### Community 61 - "pengaduan_screen.dart"
Cohesion: 0.14
Nodes (16): Complaint, PengaduanProvider, _submit, _buildTabContent, complaint, _ComplaintCard, createState, dispose (+8 more)

### Community 62 - "riwayat_screen.dart"
Cohesion: 0.12
Nodes (16): _ActivityCard, createState, filter, _FilterTab, item, label, onTap, _RiwayatEmpty (+8 more)

### Community 63 - "test_http.dart"
Cohesion: 0.08
Nodes (23): dynamic data,
  int, alamat, apiClientWith, calls, close, delay, dio, envelope (+15 more)

### Community 64 - "Selesai"
Cohesion: 0.10
Nodes (20): 08 — Task List: Mobile, Bisa langsung, Bisa langsung, Bisa langsung (API sudah ✅), Fase 0 — Scaffold, Fase 1 — Foundation, Fase 2 — Auth, Fase 3 — Layar MVP (+12 more)

### Community 65 - "login_screen.dart"
Cohesion: 0.14
Nodes (14): _canSubmit, createState, dispose, _formKey, initState, _isSubmitting, LoginScreen, _LoginScreenState (+6 more)

### Community 66 - "HomeProvider"
Cohesion: 0.23
Nodes (13): HomeProvider, ProfileProvider, build, _saveProfile, _onVisible, _ensureDataLoaded, _getSaldo, _loadCategories (+5 more)

### Community 67 - "home_screen.dart"
Cohesion: 0.06
Nodes (34): ../edukasi/edukasi_card.dart, _authSession, _buildAnnouncementBanners, _buildEmptyActivity, _buildHomeShell, _buildNotifBell, _buildQuickActions, _buildSaldoHeader (+26 more)

### Community 68 - "miru_logo.dart"
Cohesion: 0.09
Nodes (21): BoxFit, double?, _asset, _bgPaddingFactor, build, fit, _gapFactor, height (+13 more)

### Community 69 - "edukasi_provider.dart"
Cohesion: 0.17
Nodes (11): _apiClient, clearCache, _error, findById, hasError, _isLoading, _items, loadDetail (+3 more)

### Community 70 - "notification.dart"
Cohesion: 0.20
Nodes (9): copyWith, createdAt, deskripsi, fromJson, id, isRead, judul, kategori (+1 more)

### Community 71 - "info_sampah_screen.dart"
Cohesion: 0.09
Nodes (21): build, _buildInfoHeader, _buildNotes, category, _CategoryCard, _categoryVisual, content, _contohSampah (+13 more)

### Community 72 - "phone_verify_screen.dart"
Cohesion: 0.11
Nodes (18): createState, _displayPhone, dispose, _formKey, initState, _isSending, _isVerifying, _maskedPhone (+10 more)

### Community 73 - "profile_provider.dart"
Cohesion: 0.09
Nodes (22): _apiClient, clearCache, clearError, disableEditMode, enableEditMode, ensureLoaded, _error, _fetch (+14 more)

### Community 74 - "reward.dart"
Cohesion: 0.20
Nodes (9): fromJson, id, isAffordable, listFromJson, nama, poinDibutuhkan, Reward, stok (+1 more)

### Community 75 - "avatar_picker.dart"
Cohesion: 0.29
Nodes (6): dart:io, cropped, pickAndCropAvatar, picked, package:image_cropper/image_cropper.dart, package:image_picker/image_picker.dart

### Community 76 - "../../providers/auth_session.dart"
Cohesion: 0.18
Nodes (10): Dio, interceptors/auth_interceptor.dart, interceptors/envelope_interceptor.dart, interceptors/safe_log_interceptor.dart, buildInterceptors, _createDio, dio, ../../providers/auth_session.dart (+2 more)

### Community 77 - "package:dio/dio.dart"
Cohesion: 0.22
Nodes (8): Interceptor, _envelopeException, EnvelopeInterceptor, onError, onResponse, ../../models/api_envelope.dart, ../models/api_exception.dart, package:dio/dio.dart

### Community 78 - "profile_screen.dart"
Cohesion: 0.09
Nodes (23): _buildAvatarSection, _buildEditProfileTile, _buildLogoutSection, _buildQRCard, _buildSaldoSection, _buildSkeleton, _changeAvatar, createState (+15 more)

### Community 79 - "pengaduan_form_screen.dart"
Cohesion: 0.14
Nodes (14): FormState, ComplaintJenis, build, _buildInfoHeader, _buildSlaInfo, createState, dispose, _formKey (+6 more)

### Community 80 - "waste_category.dart"
Cohesion: 0.15
Nodes (12): double get, fromJson, hargaBeliPerKg, hargaBeliPerKgAsDouble, id, listFromJson, nama, stokTerkiniKg (+4 more)

### Community 81 - "json_parsing.dart"
Cohesion: 0.22
Nodes (8): parse, parseDateTime, parseDecimal, parseInt, parseOptionalDateTime, parseOptionalDecimal, tryParse, value

### Community 82 - "storage_service.dart"
Cohesion: 0.14
Nodes (13): FlutterSecureStorage, clearTokens, delete, deleteAll, hasAccessToken, read, readAccessToken, readRefreshToken (+5 more)

### Community 83 - "load_when_visible.dart"
Cohesion: 0.18
Nodes (11): build, child, createState, didChangeDependencies, didUpdateWidget, enabled, LoadWhenVisible, _LoadWhenVisibleState (+3 more)

### Community 84 - "DateTime?"
Cohesion: 0.20
Nodes (9): DateTime?, Announcement, fromJson, id, isi, judul, listFromJson, status (+1 more)

### Community 85 - "edukasi_card.dart"
Cohesion: 0.14
Nodes (12): KontenEdukasi, build, EdukasiCard, _EdukasiCoverFallback, item, onTap, build, data (+4 more)

### Community 86 - "String?"
Cohesion: 0.29
Nodes (6): build, imageUrl, name, radius, UserAvatar, String?

### Community 87 - "3. Alur User Journey Nasabah"
Cohesion: 0.33
Nodes (6): 3.1 Onboarding, 3.2 Setor Sampah (Langsung ke Bank), 3.3 Penjemputan Sampah, 3.4 Penarikan Saldo, 3.5 Tukar Poin, 3. Alur User Journey Nasabah

### Community 88 - "onboarding_scaffold.dart"
Cohesion: 0.12
Nodes (15): asset, body, build, buttonLabel, _IllustrationHero, imageAsset, OnboardingScaffold, onButton (+7 more)

### Community 89 - "Route /login"
Cohesion: 0.18
Nodes (11): build, build, _logout, build, build, _handleReset, _missingToken, build (+3 more)

### Community 90 - "bottom_nav_scaffold.dart"
Cohesion: 0.10
Nodes (20): exit_dialog.dart, badgeCount, _barHeight, BottomNavScaffold, _fabProtrude, _fabSize, icon, _JemputCenterButton (+12 more)

### Community 91 - "AuthProvider"
Cohesion: 0.15
Nodes (19): AuthProvider, LaunchExperience, _submitOtp, _submitUsername, _handleLogin, build, _sendOtp, _verifyOtp (+11 more)

### Community 92 - "saldo_card.dart"
Cohesion: 0.25
Nodes (7): int?, build, _formatCurrency, isLoading, poin, saldo, SaldoCard

### Community 93 - "empty_state.dart"
Cohesion: 0.22
Nodes (8): action, build, description, EmptyState, expand, icon, title, Widget

### Community 94 - "bool get"
Cohesion: 0.15
Nodes (12): bool get, clearSession, consumeSessionMessage, _isLoggedIn, markSessionExpired, _needsPhoneVerification, refresh, _sessionMessage (+4 more)

### Community 95 - "../config/theme.dart"
Cohesion: 0.20
Nodes (8): ../config/constants.dart, ../config/theme.dart, _buildEdukasiSection, showWasteInviteModal, name, showWelcomeBackModal, title, Route /home/edukasi

### Community 96 - "splash_screen.dart"
Cohesion: 0.20
Nodes (10): build, createState, initState, _minDisplay, previewMode, _splashAsset, SplashScreen, _SplashScreenState (+2 more)

### Community 97 - "konten_edukasi.dart"
Cohesion: 0.20
Nodes (9): json_parsing.dart, createdAt, fromJson, gambarUrl, id, isi, judul, kategoriTerkaitNama (+1 more)

### Community 98 - "launch_experience.dart"
Cohesion: 0.22
Nodes (8): consumeOnboarding, consumeWasteInvite, consumeWelcomeBack, markLoggedIn, markRegistered, pendingOnboarding, pendingWelcomeBack, _wasteInvitePending

### Community 99 - "_"
Cohesion: 0.15
Nodes (14): Color, _, build, color, complaint, _complaintColor, _complaintIcon, icon (+6 more)

### Community 100 - "home_qr_button.dart"
Cohesion: 0.15
Nodes (12): User, _alive, build, createState, dispose, initState, _restoreBrightness, _setMaxBrightness (+4 more)

### Community 101 - "pengumuman_provider.dart"
Cohesion: 0.20
Nodes (9): _announcements, _apiClient, clearCache, _error, hasError, _isLoading, loadPengumuman, refresh (+1 more)

### Community 105 - "PengumumanProvider"
Cohesion: 0.33
Nodes (6): PengumumanProvider, HomeScreen, _HomeScreenState, _loadData, initState, _fallbackPengumuman

### Community 110 - "auth_provider_test.dart"
Cohesion: 0.14
Nodes (13): Exception, ApiException, package:mirumobileapp/models/api_envelope.dart, package:mirumobileapp/models/api_exception.dart, package:mirumobileapp/services/auth_service.dart, package:mirumobileapp/services/interceptors/envelope_interceptor.dart, api, _build (+5 more)

### Community 111 - "pengumuman_screen.dart"
Cohesion: 0.15
Nodes (13): build, _AnnouncementCard, build, createState, item, onTap, PengumumanDetailScreen, PengumumanScreen (+5 more)

### Community 112 - "tarik_saldo_screen_test.dart"
Cohesion: 0.19
Nodes (11): ElevatedButton, ../helpers/test_http.dart, package:flutter_secure_storage/flutter_secure_storage.dart, package:mirumobileapp/models/user.dart, package:mirumobileapp/providers/home_provider.dart, package:mirumobileapp/providers/profile_provider.dart, package:mirumobileapp/providers/saldo_provider.dart, package:mirumobileapp/screens/saldo/tarik_saldo_screen.dart (+3 more)

### Community 113 - "login_screen_test.dart"
Cohesion: 0.13
Nodes (13): package:flutter_test/flutter_test.dart, package:flutter/widgets.dart, package:mirumobileapp/app.dart, package:mirumobileapp/providers/auth_provider.dart, package:mirumobileapp/providers/launch_experience.dart, package:mirumobileapp/screens/auth/login_screen.dart, main, api (+5 more)

### Community 114 - "_buildRecentActivity"
Cohesion: 0.40
Nodes (5): _buildRecentActivity, build, Route /home/pengaduan, Route /home/penjemputan, Route /riwayat

### Community 115 - "app_scaffold.dart"
Cohesion: 0.13
Nodes (14): EdgeInsetsGeometry?, actions, AppScaffold, body, bodyPadding, bottomNavigationBar, build, floatingActionButton (+6 more)

### Community 116 - "SaldoProvider"
Cohesion: 0.33
Nodes (6): SaldoProvider, _buildFilterBar, _loadData, RiwayatScreen, _RiwayatScreenState, _onNominalChanged

### Community 117 - "VoidCallback"
Cohesion: 0.22
Nodes (8): build, ErrorView, expand, message, onRetry, retryLabel, title, VoidCallback

### Community 118 - "package:flutter/foundation.dart"
Cohesion: 0.33
Nodes (5): keys, out, redactSensitiveLog, package:flutter/foundation.dart, return

### Community 119 - "login_prompt.dart"
Cohesion: 0.29
Nodes (6): IconData, icon, LoginPrompt, message, showBackButton, title

### Community 120 - "AuthSession"
Cohesion: 0.12
Nodes (17): AuthSession, initState, _showNotifPopup, build, build, build, build, build (+9 more)

### Community 121 - "parse_dio_error_test.dart"
Cohesion: 0.17
Nodes (11): DioExceptionType, SafeLogInterceptor, LogInterceptor, package:mirumobileapp/providers/auth_session.dart, package:mirumobileapp/services/api_client.dart, package:mirumobileapp/services/interceptors/safe_log_interceptor.dart, package:mirumobileapp/services/storage_service.dart, main (+3 more)

### Community 122 - "3. Autentikasi"
Cohesion: 0.40
Nodes (5): 3.1 Endpoints, 3.2 Login Flow, 3.3 Registrasi Flow, 3.4 Token Refresh (Interceptor), 3. Autentikasi

### Community 123 - "4. Build AAB untuk Internal testing"
Cohesion: 0.50
Nodes (4): 4.1 Versi, 4.2 Perintah build (manual), 4.3 Environment API, 4. Build AAB untuk Internal testing

### Community 124 - "exit_dialog.dart"
Cohesion: 0.20
Nodes (9): cancelLabel, confirmed, confirmLabel, false, showExitDialog, theme, title, required String message,
  String (+1 more)

### Community 125 - "package:flutter/material.dart"
Cohesion: 0.22
Nodes (7): app.dart, initializeDateFormatting, main, package:flutter/material.dart, package:intl/date_symbol_data_local.dart, package:mirumobileapp/widgets/load_when_visible.dart, main

### Community 126 - "5. Upload & rilis Internal testing"
Cohesion: 0.50
Nodes (4): 5.1 Manual (Play Console), 5.2 Stakeholder: install pertama kali, 5.3 Stakeholder: update berikutnya, 5. Upload & rilis Internal testing

### Community 127 - "7. Checklist rilis UAT (per build)"
Cohesion: 0.50
Nodes (4): 7. Checklist rilis UAT (per build), Build & upload, Sebelum build, Setelah Available

### Community 128 - "_buildInfoSection"
Cohesion: 0.50
Nodes (4): _buildStep1, _buildInfoSection, Route /settings/kebijakan-data, Route /settings/tentang

### Community 129 - "edukasi_provider_test.dart"
Cohesion: 0.19
Nodes (7): package:mirumobileapp/models/konten_edukasi.dart, package:mirumobileapp/providers/edukasi_provider.dart, package:mirumobileapp/providers/notification_provider.dart, _artikel, main, _items, main

### Community 130 - "placeholder_screen.dart"
Cohesion: 0.50
Nodes (3): build, PlaceholderScreen, title

## Knowledge Gaps
- **1288 isolated node(s):** `XCTest`, `_storageService`, `_authSession`, `_authProvider`, `_homeProvider` (+1283 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1435 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthSession` connect `AuthSession` to `../../widgets/shimmer_loading.dart`, `qrcode_screen.dart`, `auth_service.dart`, `auth_interceptor.dart`, `tarik_saldo_screen.dart`, `ajukan_penjemputan_screen.dart`, `app.dart`, `auth_provider.dart`, `reward_screen.dart`, `penjemputan_screen.dart`, `notifikasi_screen.dart`, `package:provider/provider.dart`, `pengaduan_screen.dart`, `riwayat_screen.dart`, `HomeProvider`, `home_screen.dart`, `profile_screen.dart`, `pengaduan_form_screen.dart`, `AuthProvider`, `bool get`, `PengumumanProvider`, `pengumuman_screen.dart`, `SaldoProvider`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `HomeProvider` connect `HomeProvider` to `qrcode_screen.dart`, `harga_berlaku_banner.dart`, `tarik_saldo_screen.dart`, `ajukan_penjemputan_screen.dart`, `app.dart`, `reward_screen.dart`, `penjemputan_screen.dart`, `notifikasi_screen.dart`, `package:provider/provider.dart`, `home_provider.dart`, `complete_profile_dialog.dart`, `pengaduan_screen.dart`, `riwayat_screen.dart`, `home_screen.dart`, `info_sampah_screen.dart`, `profile_screen.dart`, `AuthProvider`, `home_qr_button.dart`, `PengumumanProvider`, `SaldoProvider`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `AuthProvider` connect `AuthProvider` to `Route /login`, `login_screen.dart`, `HomeProvider`, `home_screen.dart`, `register_screen.dart`, `app.dart`, `splash_screen.dart`, `auth_provider.dart`, `phone_verify_screen.dart`, `PengumumanProvider`, `notifikasi_screen.dart`, `profile_screen.dart`, `SaldoProvider`, `forgot_password_screen.dart`, `riwayat_screen.dart`, `reset_password_screen.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `XCTest`, `_storageService`, `_authSession` to the rest of the system?**
  _1288 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MIRU Bank Sampah — Mobile App (Miru-G)` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `Ringkasan Aturan untuk UI Mobile` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `09 — Data Dictionary & Reference Values (Mobile)` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._