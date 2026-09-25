# Graph Report - mobile  (2026-09-02)

## Corpus Check
- 137 files · ~248,788 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1960 nodes · 2937 edges · 125 communities (117 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `bc2cfe15`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- package:provider/provider.dart
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
- AuthSession
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
- package:dio/dio.dart
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
- tukar_poin_screen.dart
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
- 08 — Task List: Mobile
- login_screen.dart
- HomeProvider
- home_screen.dart
- Selesai
- edukasi_provider.dart
- notification.dart
- info_sampah_screen.dart
- phone_verify_screen.dart
- profile_provider.dart
- reward.dart
- avatar_picker.dart
- _handleLogin
- ../models/api_exception.dart
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
- onboarding_screen.dart
- LaunchImage.imageset/README.md
- bool?
- auth_provider_test.dart
- pengumuman_screen.dart
- tarik_saldo_screen_test.dart
- login_screen_test.dart
- _buildRecentActivity
- app_scaffold.dart
- State
- VoidCallback
- package:go_router/go_router.dart
- _showNotifPopup
- parse_dio_error_test.dart
- edukasi_list_screen.dart
- exit_dialog.dart
- package:flutter/material.dart
- markdown_document.dart
- Local Development
- edukasi_provider_test.dart

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
- `build` --references--> `AuthProvider`  [EXTRACTED]
  lib/screens/auth/phone_verify_screen.dart → lib/providers/auth_provider.dart
- `build` --references--> `AuthSession`  [EXTRACTED]
  lib/screens/pengaduan/pengaduan_form_screen.dart → lib/providers/auth_session.dart
- `build` --references--> `AuthSession`  [EXTRACTED]
  lib/screens/reward/reward_screen.dart → lib/providers/auth_session.dart
- `build` --references--> `AuthSession`  [EXTRACTED]
  lib/screens/reward/tukar_poin_screen.dart → lib/providers/auth_session.dart
- `_getSaldo` --references--> `HomeProvider`  [EXTRACTED]
  lib/screens/saldo/tarik_saldo_screen.dart → lib/providers/home_provider.dart

## Import Cycles
- None detected.

## Communities (125 total, 3 thin omitted)

### Community 0 - "package:provider/provider.dart"
Cohesion: 0.18
Nodes (16): SettingsProvider, initState, build, createState, initState, KebijakanDataScreen, _KebijakanDataScreenState, build (+8 more)

### Community 2 - "MIRU Bank Sampah — Mobile App (Miru-G)"
Cohesion: 0.13
Nodes (15): Autentikasi, Batasan Penting, Branding, Dokumentasi Proyek, Endpoint Mobile, Fitur MVP (Nasabah), Format Response — JSON Envelope, Integrasi Backend API (+7 more)

### Community 3 - "04 — API Integration (Mobile)"
Cohesion: 0.11
Nodes (18): 04 — API Integration (Mobile), 10. Batasan Mobile, 1. Base Configuration, 2. JSON Envelope — WAJIB Dipahami, 3.1 Endpoints, 3.2 Login Flow, 3.3 Registrasi Flow, 3.4 Token Refresh (Interceptor) (+10 more)

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
Cohesion: 0.06
Nodes (33): api_exception.dart, ApiEnvelope, ApiMeta, code, data, errors, fromJson, message (+25 more)

### Community 13 - "edukasi_detail_screen.dart"
Cohesion: 0.15
Nodes (16): EdukasiProvider, _ArticleBody, build, createState, EdukasiDetailScreen, _EdukasiDetailScreenState, edukasiId, _ensureLoaded (+8 more)

### Community 14 - "Desain Halaman"
Cohesion: 0.25
Nodes (7): 07 — Modules & Features (Mobile), 14 Fitur Mobile — untuk Nasabah, Desain Halaman, HomeScreen (Dashboard), PenjemputanScreen, RewardScreen, TarikSaldoScreen

### Community 15 - "AuthSession"
Cohesion: 0.07
Nodes (31): BoxDecoration get, dart:math, dart:ui, AuthSession, initState, build, _backRow, build (+23 more)

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
Cohesion: 0.08
Nodes (25): 10. Definisi selesai (untuk jalur ini), 12 — Play Console Internal Testing (Staging untuk Stakeholder), 1. Mengapa Internal testing, 2.1 Akun & organisasi, 2.2 Backend & konfigurasi app, 2.3 Listing minimal agar track testing aktif, 2. Prasyarat, 3. Alur one-time (setup) (+17 more)

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
Cohesion: 0.04
Nodes (47): BoxFit, Color get, dijadwalkan,
  dalamPerjalanan,
  dijemput,
  selesai,, double?, alamatJemput, apiValue, badgeColor, displayLabel (+39 more)

### Community 24 - "routes.dart"
Cohesion: 0.07
Nodes (28): createAppRouter, ../screens/auth/forgot_password_screen.dart, ../screens/auth/login_screen.dart, ../screens/auth/phone_verify_screen.dart, ../screens/auth/register_screen.dart, ../screens/auth/reset_password_screen.dart, ../screens/edukasi/edukasi_detail_screen.dart, ../screens/edukasi/edukasi_list_screen.dart (+20 more)

### Community 25 - "forgot_password_screen.dart"
Cohesion: 0.08
Nodes (23): _applyFieldErrors, _clearFieldErrors, createState, dispose, _extractError, _fieldErrorOtp, _fieldErrorPhone, _fieldErrorUsername (+15 more)

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
Cohesion: 0.09
Nodes (22): build, _logout, build, build, _canSubmit, _confirmPasswordController, createState, dispose (+14 more)

### Community 32 - "package:dio/dio.dart"
Cohesion: 0.07
Nodes (30): Dio, Future, interceptors/auth_interceptor.dart, interceptors/envelope_interceptor.dart, interceptors/safe_log_interceptor.dart, buildInterceptors, _createDio, dio (+22 more)

### Community 33 - "tarik_saldo_screen.dart"
Cohesion: 0.06
Nodes (35): File?, _besarNominal, _buildQuickAmountChips, createState, dispose, _extractFieldError, _formatRupiah, formatter (+27 more)

### Community 34 - "ajukan_penjemputan_screen.dart"
Cohesion: 0.05
Nodes (38): _alamatController, _ambilLokasi, _beratController, _buildInfoHeader, category, createState, dispose, empty (+30 more)

### Community 35 - "shimmer_loading.dart"
Cohesion: 0.10
Nodes (21): Animation, AnimationController, _animation, borderRadius, build, child, _controller, createState (+13 more)

### Community 36 - "register_screen.dart"
Cohesion: 0.06
Nodes (34): _applyFieldErrors, _buildStep1, _buildStep2, _clearFieldErrors, createState, dispose, _extractError, _fieldErrorConsent (+26 more)

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
Cohesion: 0.13
Nodes (15): build, createState, initState, onTukar, _onTukarTap, poin, _PoinHeaderCard, reward (+7 more)

### Community 41 - "penjemputan_screen.dart"
Cohesion: 0.13
Nodes (14): Pickup, build, _buildTabContent, createState, dispose, initState, pickup, _PickupCard (+6 more)

### Community 42 - "institution_settings.dart"
Cohesion: 0.10
Nodes (19): alamat, email, fromJson, InstitutionSettings, isDiLuarJamKerja, jamBuka, jamBukaTime, jamOperasional (+11 more)

### Community 43 - "notifikasi_screen.dart"
Cohesion: 0.12
Nodes (19): AppNotification, NotificationProvider, build, DetailNotifikasiScreen, notification, createState, isUnread, item (+11 more)

### Community 44 - "StatelessWidget"
Cohesion: 0.12
Nodes (17): _ActivityItemWidget, _AnnouncementBanner, _ActivityCard, _RiwayatEmpty, _RiwayatFilterChip, _ConfirmationRow, _MetodeSelector, _SaldoDisplayCard (+9 more)

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

### Community 52 - "tukar_poin_screen.dart"
Cohesion: 0.15
Nodes (15): RewardProvider, _loadData, build, _confirmRedemption, createState, initState, _isProcessing, reward (+7 more)

### Community 53 - "edit_profile_screen.dart"
Cohesion: 0.12
Nodes (16): _alamatController, _buildLabel, createState, dispose, EditProfileScreen, _EditProfileScreenState, _formKey, initialUser (+8 more)

### Community 54 - "deposit_detail.dart"
Cohesion: 0.14
Nodes (13): beratKg, beratKgAsDouble, DepositDetail, fromJson, hargaSaatItu, hargaSaatItuAsDouble, id, kategori (+5 more)

### Community 55 - "home_provider.dart"
Cohesion: 0.08
Nodes (24): _apiClient, _categories, clearCache, _error, _fetchDashboard, fetchEarliestUpcomingTanggalBerlaku, _fetchGeneration, _fetchRecentActivity (+16 more)

### Community 56 - "complete_profile_dialog.dart"
Cohesion: 0.14
Nodes (13): editUser, false, goEdit, home, profile, showCompleteProfileDialog, theme, updated (+5 more)

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
Cohesion: 0.13
Nodes (15): Complaint, build, _buildTabContent, complaint, _ComplaintCard, createState, dispose, initState (+7 more)

### Community 62 - "riwayat_screen.dart"
Cohesion: 0.13
Nodes (18): SaldoProvider, _buildFilterBar, createState, filter, _FilterTab, item, label, _loadData (+10 more)

### Community 63 - "test_http.dart"
Cohesion: 0.08
Nodes (23): dynamic data,
  int, alamat, apiClientWith, calls, close, delay, dio, envelope (+15 more)

### Community 64 - "08 — Task List: Mobile"
Cohesion: 0.17
Nodes (11): 08 — Task List: Mobile, Bisa langsung, Bisa langsung, Bisa langsung (API sudah ✅), Fase 6 — Kualitas & UAT, Fase 7 — Production Android, Fase 8 — Pengembangan lanjutan, Out of scope (+3 more)

### Community 65 - "login_screen.dart"
Cohesion: 0.14
Nodes (14): _canSubmit, createState, dispose, _formKey, initState, _isSubmitting, LoginScreen, _LoginScreenState (+6 more)

### Community 66 - "HomeProvider"
Cohesion: 0.22
Nodes (14): HomeProvider, PenjemputanProvider, ProfileProvider, build, _saveProfile, AjukanPenjemputanScreen, _AjukanPenjemputanScreenState, _prefillAlamat (+6 more)

### Community 67 - "home_screen.dart"
Cohesion: 0.05
Nodes (36): ../edukasi/edukasi_card.dart, _authSession, _buildAnnouncementBanners, _buildEmptyActivity, _buildHomeShell, _buildNotifBell, _buildPublicPriceInfo, _buildQuickActions (+28 more)

### Community 68 - "Selesai"
Cohesion: 0.22
Nodes (9): Fase 0 — Scaffold, Fase 1 — Foundation, Fase 2 — Auth, Fase 3 — Layar MVP, Fase 4 — Navigasi & UX, Fase 5 — Settings & informasi, Fase 6 (sebagian), Fase 8 (sebagian) (+1 more)

### Community 69 - "edukasi_provider.dart"
Cohesion: 0.09
Nodes (21): _apiClient, clearCache, _error, findById, hasError, _isLoading, _items, loadDetail (+13 more)

### Community 70 - "notification.dart"
Cohesion: 0.20
Nodes (9): copyWith, createdAt, deskripsi, fromJson, id, isRead, judul, kategori (+1 more)

### Community 71 - "info_sampah_screen.dart"
Cohesion: 0.09
Nodes (21): build, _buildInfoHeader, _buildNotes, category, _CategoryCard, _categoryVisual, content, _contohSampah (+13 more)

### Community 72 - "phone_verify_screen.dart"
Cohesion: 0.11
Nodes (17): build, createState, _displayPhone, dispose, _formKey, initState, _isSending, _isVerifying (+9 more)

### Community 73 - "profile_provider.dart"
Cohesion: 0.09
Nodes (22): _apiClient, clearCache, clearError, disableEditMode, enableEditMode, ensureLoaded, _error, _fetch (+14 more)

### Community 74 - "reward.dart"
Cohesion: 0.20
Nodes (9): fromJson, id, isAffordable, listFromJson, nama, poinDibutuhkan, Reward, stok (+1 more)

### Community 75 - "avatar_picker.dart"
Cohesion: 0.29
Nodes (6): dart:io, cropped, pickAndCropAvatar, picked, package:image_cropper/image_cropper.dart, package:image_picker/image_picker.dart

### Community 76 - "_handleLogin"
Cohesion: 0.33
Nodes (7): _handleLogin, _sendOtp, _verifyOtp, _finish, _bootstrap, Route /home, Route /verify-phone

### Community 77 - "../models/api_exception.dart"
Cohesion: 0.25
Nodes (7): Interceptor, _envelopeException, EnvelopeInterceptor, onError, onResponse, ../../models/api_envelope.dart, ../models/api_exception.dart

### Community 78 - "profile_screen.dart"
Cohesion: 0.09
Nodes (23): _buildAvatarSection, _buildEditProfileTile, _buildLogoutSection, _buildQRCard, _buildSaldoSection, _buildSkeleton, _changeAvatar, createState (+15 more)

### Community 79 - "pengaduan_form_screen.dart"
Cohesion: 0.13
Nodes (17): FormState, ComplaintJenis, PengaduanProvider, build, _buildInfoHeader, _buildSlaInfo, createState, dispose (+9 more)

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
Cohesion: 0.25
Nodes (7): KontenEdukasi, build, EdukasiCard, _EdukasiCoverFallback, item, onTap, ../../models/konten_edukasi.dart

### Community 86 - "String?"
Cohesion: 0.29
Nodes (6): build, imageUrl, name, radius, UserAvatar, String?

### Community 87 - "3. Alur User Journey Nasabah"
Cohesion: 0.33
Nodes (6): 3.1 Onboarding, 3.2 Setor Sampah (Langsung ke Bank), 3.3 Penjemputan Sampah, 3.4 Penarikan Saldo, 3.5 Tukar Poin, 3. Alur User Journey Nasabah

### Community 88 - "onboarding_scaffold.dart"
Cohesion: 0.12
Nodes (15): asset, body, build, buttonLabel, _IllustrationHero, imageAsset, OnboardingScaffold, onButton (+7 more)

### Community 90 - "bottom_nav_scaffold.dart"
Cohesion: 0.10
Nodes (20): exit_dialog.dart, badgeCount, _barHeight, BottomNavScaffold, _fabProtrude, _fabSize, icon, _JemputCenterButton (+12 more)

### Community 91 - "AuthProvider"
Cohesion: 0.16
Nodes (16): ChangeNotifier, AuthProvider, LaunchExperience, _submitOtp, _submitUsername, _handleRegister, RegisterScreen, _RegisterScreenState (+8 more)

### Community 92 - "saldo_card.dart"
Cohesion: 0.25
Nodes (7): int?, build, _formatCurrency, isLoading, poin, saldo, SaldoCard

### Community 93 - "empty_state.dart"
Cohesion: 0.20
Nodes (9): IconData, action, build, description, EmptyState, expand, icon, title (+1 more)

### Community 94 - "bool get"
Cohesion: 0.15
Nodes (12): bool get, clearSession, consumeSessionMessage, _isLoggedIn, markSessionExpired, _needsPhoneVerification, refresh, _sessionMessage (+4 more)

### Community 95 - "../config/theme.dart"
Cohesion: 0.20
Nodes (8): ../config/constants.dart, ../config/theme.dart, _buildEdukasiSection, showWasteInviteModal, name, showWelcomeBackModal, title, Route /home/edukasi

### Community 96 - "splash_screen.dart"
Cohesion: 0.22
Nodes (8): build, createState, initState, _minDisplay, previewMode, _splashAsset, ../../providers/auth_provider.dart, static const

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
Cohesion: 0.14
Nodes (14): User, _alive, build, createState, dispose, _HomeQrDialog, _HomeQrDialogState, initState (+6 more)

### Community 101 - "onboarding_screen.dart"
Cohesion: 0.13
Nodes (15): asset, body, build, createState, dispose, _index, _next, OnboardingScreen (+7 more)

### Community 110 - "auth_provider_test.dart"
Cohesion: 0.14
Nodes (13): Exception, ApiException, package:mirumobileapp/models/api_envelope.dart, package:mirumobileapp/models/api_exception.dart, package:mirumobileapp/services/auth_service.dart, package:mirumobileapp/services/interceptors/envelope_interceptor.dart, api, _build (+5 more)

### Community 111 - "pengumuman_screen.dart"
Cohesion: 0.13
Nodes (17): PengumumanProvider, build, _loadData, _AnnouncementCard, build, createState, initState, item (+9 more)

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
Cohesion: 0.14
Nodes (13): EdgeInsetsGeometry?, actions, AppScaffold, body, bodyPadding, bottomNavigationBar, build, floatingActionButton (+5 more)

### Community 116 - "State"
Cohesion: 0.15
Nodes (19): ForgotPasswordScreen, _ForgotPasswordScreenState, PhoneVerifyScreen, _PhoneVerifyScreenState, ResetPasswordScreen, _ResetPasswordScreenState, _TukarPoinContent, _TukarPoinContentState (+11 more)

### Community 117 - "VoidCallback"
Cohesion: 0.22
Nodes (8): build, ErrorView, expand, message, onRetry, retryLabel, title, VoidCallback

### Community 119 - "package:go_router/go_router.dart"
Cohesion: 0.17
Nodes (11): build, _missingToken, build, icon, LoginPrompt, message, showBackButton, title (+3 more)

### Community 120 - "_showNotifPopup"
Cohesion: 0.50
Nodes (4): _showNotifPopup, build, Route /notifikasi, Route /notifikasi/detail

### Community 121 - "parse_dio_error_test.dart"
Cohesion: 0.17
Nodes (11): DioExceptionType, SafeLogInterceptor, LogInterceptor, package:mirumobileapp/providers/auth_session.dart, package:mirumobileapp/services/api_client.dart, package:mirumobileapp/services/interceptors/safe_log_interceptor.dart, package:mirumobileapp/services/storage_service.dart, main (+3 more)

### Community 122 - "edukasi_list_screen.dart"
Cohesion: 0.33
Nodes (6): edukasi_card.dart, build, createState, EdukasiListScreen, _EdukasiListScreenState, ../../providers/edukasi_provider.dart

### Community 124 - "exit_dialog.dart"
Cohesion: 0.20
Nodes (9): cancelLabel, confirmed, confirmLabel, false, showExitDialog, theme, title, required String message,
  String (+1 more)

### Community 125 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (10): app.dart, initializeDateFormatting, main, build, PlaceholderScreen, title, package:flutter/material.dart, package:intl/date_symbol_data_local.dart (+2 more)

### Community 126 - "markdown_document.dart"
Cohesion: 0.33
Nodes (5): build, data, MarkdownDocument, package:cached_network_image/cached_network_image.dart, package:flutter_markdown_plus/flutter_markdown_plus.dart

### Community 127 - "Local Development"
Cohesion: 0.33
Nodes (6): 1. Install Dependencies, 2. Konfigurasi API URL, 3. Jalankan Backend & Seed Data, 4. Run App, 5. Akun Demo (Registrasi atau Seed Full), Local Development

### Community 129 - "edukasi_provider_test.dart"
Cohesion: 0.19
Nodes (7): package:mirumobileapp/models/konten_edukasi.dart, package:mirumobileapp/providers/edukasi_provider.dart, package:mirumobileapp/providers/notification_provider.dart, _artikel, main, _items, main

## Knowledge Gaps
- **1286 isolated node(s):** `XCTest`, `_storageService`, `_authSession`, `_authProvider`, `_homeProvider` (+1281 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1433 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthSession` connect `AuthSession` to `package:provider/provider.dart`, `auth_service.dart`, `package:dio/dio.dart`, `tarik_saldo_screen.dart`, `ajukan_penjemputan_screen.dart`, `app.dart`, `auth_provider.dart`, `reward_screen.dart`, `penjemputan_screen.dart`, `notifikasi_screen.dart`, `tukar_poin_screen.dart`, `pengaduan_screen.dart`, `riwayat_screen.dart`, `HomeProvider`, `home_screen.dart`, `profile_screen.dart`, `pengaduan_form_screen.dart`, `AuthProvider`, `bool get`, `pengumuman_screen.dart`, `State`, `_showNotifPopup`?**
  _High betweenness centrality (0.027) - this node is a cross-community bridge._
- **Why does `HomeProvider` connect `HomeProvider` to `AuthSession`, `harga_berlaku_banner.dart`, `tarik_saldo_screen.dart`, `ajukan_penjemputan_screen.dart`, `app.dart`, `penjemputan_screen.dart`, `tukar_poin_screen.dart`, `home_provider.dart`, `complete_profile_dialog.dart`, `pengaduan_screen.dart`, `riwayat_screen.dart`, `home_screen.dart`, `info_sampah_screen.dart`, `profile_screen.dart`, `pengaduan_form_screen.dart`, `AuthProvider`, `home_qr_button.dart`, `pengumuman_screen.dart`, `State`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **Why does `AuthProvider` connect `AuthProvider` to `splash_screen.dart`, `login_screen.dart`, `home_screen.dart`, `register_screen.dart`, `app.dart`, `auth_provider.dart`, `phone_verify_screen.dart`, `_handleLogin`, `profile_screen.dart`, `AuthSession`, `State`, `forgot_password_screen.dart`, `riwayat_screen.dart`, `reset_password_screen.dart`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **What connects `XCTest`, `_storageService`, `_authSession` to the rest of the system?**
  _1286 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `MIRU Bank Sampah — Mobile App (Miru-G)` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `04 — API Integration (Mobile)` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Should `Ringkasan Aturan untuk UI Mobile` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._