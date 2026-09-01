# Graph Report - mobile  (2026-08-26)

## Corpus Check
- 125 files · ~248,360 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1902 nodes · 2816 edges · 119 communities (116 shown, 3 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b9aa7a0d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- onboarding_screen.dart
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
- tukar_poin_screen.dart
- edit_profile_screen.dart
- deposit_detail.dart
- home_provider.dart
- ../../providers/auth_session.dart
- 11 — Security & Privacy (Mobile — mirumobileapp)
- notification_provider.dart
- reward_provider.dart
- settings_provider.dart
- phone_verify_screen.dart
- riwayat_screen.dart
- Audit Temuan — selesai ✅
- Fase 8: Pengembangan Lanjutan
- login_screen.dart
- HomeProvider
- home_screen.dart
- miru_logo.dart
- edukasi_provider.dart
- notification.dart
- info_sampah_screen.dart
- Fase 6: Kualitas & Testing (UAT Ready)
- profile_provider.dart
- reward.dart
- pengumuman_provider.dart
- complete_profile_dialog.dart
- ../models/api_exception.dart
- profile_screen.dart
- pengaduan_screen.dart
- waste_category.dart
- json_parsing.dart
- storage_service.dart
- pengumuman_screen.dart
- DateTime?
- edukasi_card.dart
- String?
- 3. Alur User Journey Nasabah
- onboarding_scaffold.dart
- PengumumanProvider
- bottom_nav_scaffold.dart
- AuthProvider
- saldo_card.dart
- Local Development
- bool get
- ../config/constants.dart
- splash_screen.dart
- konten_edukasi.dart
- package:flutter/foundation.dart
- _
- home_qr_button.dart
- _buildInfoSection
- LaunchImage.imageset/README.md
- _buildPublicPriceInfo
- bool?
- ../config/theme.dart
- app_scaffold.dart
- State
- VoidCallback
- package:go_router/go_router.dart
- AuthSession
- api_exception.dart
- exit_dialog.dart
- package:flutter/material.dart

## God Nodes (most connected - your core abstractions)
1. `AuthSession` - 47 edges
2. `HomeProvider` - 46 edges
3. `AuthProvider` - 39 edges
4. `ProfileProvider` - 25 edges
5. `_` - 17 edges
6. `Audit Temuan — selesai ✅` - 17 edges
7. `LaunchExperience` - 15 edges
8. `BAGIAN B — SELESAI (arsip) — urutan bawah` - 15 edges
9. `EdukasiProvider` - 13 edges
10. `ApiClient` - 13 edges

## Surprising Connections (you probably didn't know these)
- `build` --references--> `AuthSession`  [EXTRACTED]
  lib/screens/pengaduan/pengaduan_form_screen.dart → lib/providers/auth_session.dart
- `build` --references--> `AuthSession`  [EXTRACTED]
  lib/screens/reward/tukar_poin_screen.dart → lib/providers/auth_session.dart
- `_loadData` --references--> `HomeProvider`  [EXTRACTED]
  lib/screens/setoran/info_sampah_screen.dart → lib/providers/home_provider.dart
- `_load` --references--> `HomeProvider`  [EXTRACTED]
  lib/widgets/harga_berlaku_banner.dart → lib/providers/home_provider.dart
- `_ForgotPasswordScreenState` --references--> `AuthProvider`  [EXTRACTED]
  lib/screens/auth/forgot_password_screen.dart → lib/providers/auth_provider.dart

## Import Cycles
- None detected.

## Communities (119 total, 3 thin omitted)

### Community 0 - "onboarding_screen.dart"
Cohesion: 0.13
Nodes (15): asset, body, build, createState, dispose, _index, _next, OnboardingScreen (+7 more)

### Community 1 - "README.md"
Cohesion: 0.20
Nodes (4): 08 — Task List: Mobile App Development Roadmap, Cakupan Modul — Mobile (Nasabah), Ringkasan Fase, Urutan kerja disarankan (Mobile)

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
Cohesion: 0.17
Nodes (11): 06 — System Constraints (Mobile), 1. TIDAK ADA Pembayaran Otomatis, 2. TIDAK ADA Live GPS Tracking, 3. TIDAK ADA Scan KTP/Face Recognition, 4. TIDAK ADA Integrasi Dukcapil, 5. Hanya Nasabah yang Login, 6. Prioritas Android, 7. Koneksi Internet Diperlukan (+3 more)

### Community 10 - "01 — Project Overview (Mobile App)"
Cohesion: 0.20
Nodes (10): 01 — Project Overview (Mobile App), Fitur Utama (Mobile — Nasabah), Informasi Branding, Jam Layanan, Latar Belakang, Platform, Posisi dalam Ekosistem, Referensi Dokumen Terkait (+2 more)

### Community 11 - "AppDelegate"
Cohesion: 0.11
Nodes (14): Any, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate, Bool (+6 more)

### Community 12 - "api_envelope.dart"
Cohesion: 0.10
Nodes (20): api_exception.dart, ApiEnvelope, ApiMeta, code, data, errors, fromJson, message (+12 more)

### Community 13 - "edukasi_detail_screen.dart"
Cohesion: 0.11
Nodes (23): edukasi_card.dart, EdukasiProvider, _ArticleBody, build, createState, EdukasiDetailScreen, _EdukasiDetailScreenState, edukasiId (+15 more)

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
Cohesion: 0.07
Nodes (26): Color get, dijadwalkan,
  dalamPerjalanan,
  dijemput,
  selesai,, alamatJemput, apiValue, badgeColor, displayLabel, ditolak, estimasiBerat (+18 more)

### Community 24 - "routes.dart"
Cohesion: 0.07
Nodes (28): createAppRouter, ../screens/auth/forgot_password_screen.dart, ../screens/auth/login_screen.dart, ../screens/auth/phone_verify_screen.dart, ../screens/auth/register_screen.dart, ../screens/auth/reset_password_screen.dart, ../screens/edukasi/edukasi_detail_screen.dart, ../screens/edukasi/edukasi_list_screen.dart (+20 more)

### Community 25 - "forgot_password_screen.dart"
Cohesion: 0.08
Nodes (25): _applyFieldErrors, _clearFieldErrors, createState, dispose, _extractError, _fieldErrorOtp, _fieldErrorPhone, _fieldErrorUsername (+17 more)

### Community 26 - "profile_provider_test.dart"
Cohesion: 0.07
Nodes (26): dart:async, dart:convert, dart:typed_data, Duration?, HttpClientAdapter, package:flutter_test/flutter_test.dart, package:mirumobileapp/app.dart, package:mirumobileapp/models/user.dart (+18 more)

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
Cohesion: 0.07
Nodes (29): build, build, _logout, build, build, _canSubmit, _confirmPasswordController, createState (+21 more)

### Community 32 - "auth_interceptor.dart"
Cohesion: 0.13
Nodes (14): Future, AuthInterceptor, authSession, _clearSession, _doRefresh, _isPublicPath, onError, onRequest (+6 more)

### Community 33 - "tarik_saldo_screen.dart"
Cohesion: 0.05
Nodes (42): dart:io, File?, _besarNominal, _buildQuickAmountChips, createState, dispose, _extractFieldError, _formatRupiah (+34 more)

### Community 34 - "ajukan_penjemputan_screen.dart"
Cohesion: 0.05
Nodes (37): _alamatController, _ambilLokasi, _beratController, _buildInfoHeader, category, createState, dispose, empty (+29 more)

### Community 35 - "shimmer_loading.dart"
Cohesion: 0.10
Nodes (19): Animation, AnimationController, _animation, borderRadius, build, child, _controller, createState (+11 more)

### Community 36 - "register_screen.dart"
Cohesion: 0.06
Nodes (32): _applyFieldErrors, _buildStep2, _clearFieldErrors, createState, dispose, _extractError, _fieldErrorConsent, _fieldErrorNama (+24 more)

### Community 37 - "app.dart"
Cohesion: 0.06
Nodes (43): config/routes.dart, GoRouter, _apiClient, _authProvider, _authService, _authSession, build, createState (+35 more)

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
Nodes (20): ChangeNotifier, AppNotification, NotificationProvider, build, DetailNotifikasiScreen, notification, createState, isUnread (+12 more)

### Community 44 - "StatelessWidget"
Cohesion: 0.13
Nodes (15): _ActivityItemWidget, _AnnouncementBanner, _ConfirmationRow, _MetodeSelector, _SaldoDisplayCard, _SlaInfoBanner, _CategoryPickerTile, _DatePickerTile (+7 more)

### Community 45 - "withdrawal.dart"
Cohesion: 0.09
Nodes (21): apiValue, displayLabel, ditolak, fromApiValue, fromJson, id, listFromJson, metode (+13 more)

### Community 46 - "complaint.dart"
Cohesion: 0.09
Nodes (22): hargaTidakSesuai,
  petugasTidakDatang,
  kesalahanData,
  buktiTidakMuncul,, apiValue, Complaint, ComplaintJenis, ComplaintStatus, displayLabel, ditutup, fromApiValue (+14 more)

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
Nodes (14): build, _confirmRedemption, createState, initState, _isProcessing, reward, _TukarPoinBody, _TukarPoinBodyState (+6 more)

### Community 53 - "edit_profile_screen.dart"
Cohesion: 0.12
Nodes (16): _alamatController, _buildLabel, createState, dispose, EditProfileScreen, _EditProfileScreenState, _formKey, initialUser (+8 more)

### Community 54 - "deposit_detail.dart"
Cohesion: 0.14
Nodes (13): beratKg, beratKgAsDouble, DepositDetail, fromJson, hargaSaatItu, hargaSaatItuAsDouble, id, kategori (+5 more)

### Community 55 - "home_provider.dart"
Cohesion: 0.08
Nodes (23): _apiClient, _categories, clearCache, _error, _fetchDashboard, fetchEarliestUpcomingTanggalBerlaku, _fetchGeneration, _fetchRecentActivity (+15 more)

### Community 56 - "../../providers/auth_session.dart"
Cohesion: 0.22
Nodes (8): Dio, interceptors/auth_interceptor.dart, interceptors/envelope_interceptor.dart, _createDio, dio, ../../providers/auth_session.dart, ../storage_service.dart, T

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

### Community 61 - "phone_verify_screen.dart"
Cohesion: 0.11
Nodes (18): createState, _displayPhone, dispose, _formKey, initState, _isSending, _isVerifying, _maskedPhone (+10 more)

### Community 62 - "riwayat_screen.dart"
Cohesion: 0.11
Nodes (19): SaldoProvider, _ActivityCard, createState, dispose, filter, _FilterTab, initState, item (+11 more)

### Community 63 - "Audit Temuan — selesai ✅"
Cohesion: 0.06
Nodes (35): 8.1 Modul 2 — Autentikasi lanjutan, 8.2 Modul 3 — Profil & kartu digital, Audit Temuan — selesai ✅, BAGIAN B — SELESAI (arsip) — urutan bawah, Checklist Integrasi End-to-End, Dari Fase 8: Pengembangan Lanjutan, Definisi "Selesai" per Tahap, Environment Testing (+27 more)

### Community 64 - "Fase 8: Pengembangan Lanjutan"
Cohesion: 0.17
Nodes (12): 7.1 Build Configuration, 7.2 Play Store Preparation, 7.3 Security Release Checklist, 8.1 Modul 2 — Autentikasi lanjutan, 8.4 Modul 5 / 9 — FCM push (sisa), 8.5 Modul 7 — Wilayah & peta sederhana, 8.6 Modul 10 / 11 — Bukti & masa berlaku poin, 8.7 iOS & peningkatan opsional (+4 more)

### Community 65 - "login_screen.dart"
Cohesion: 0.13
Nodes (15): FormState, _canSubmit, createState, dispose, _formKey, initState, _isSubmitting, LoginScreen (+7 more)

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
Cohesion: 0.10
Nodes (21): build, _buildInfoHeader, _buildNotes, category, _categoryVisual, content, _contohSampah, createState (+13 more)

### Community 72 - "Fase 6: Kualitas & Testing (UAT Ready)"
Cohesion: 0.40
Nodes (5): 6.0 Keamanan Client — sisa, 6.1 Automated Tests — sisa, 6.2 Manual / UAT Checklist, 6.3 Edge Cases, Fase 6: Kualitas & Testing (UAT Ready)

### Community 73 - "profile_provider.dart"
Cohesion: 0.09
Nodes (22): _apiClient, clearCache, clearError, disableEditMode, enableEditMode, ensureLoaded, _error, _fetch (+14 more)

### Community 74 - "reward.dart"
Cohesion: 0.20
Nodes (9): fromJson, id, isAffordable, listFromJson, nama, poinDibutuhkan, Reward, stok (+1 more)

### Community 75 - "pengumuman_provider.dart"
Cohesion: 0.20
Nodes (9): _announcements, _apiClient, clearCache, _error, hasError, _isLoading, loadPengumuman, refresh (+1 more)

### Community 76 - "complete_profile_dialog.dart"
Cohesion: 0.14
Nodes (13): editUser, false, goEdit, home, profile, showCompleteProfileDialog, theme, updated (+5 more)

### Community 77 - "../models/api_exception.dart"
Cohesion: 0.22
Nodes (8): Interceptor, _envelopeException, EnvelopeInterceptor, onError, onResponse, ../../models/api_envelope.dart, ../models/api_exception.dart, package:dio/dio.dart

### Community 78 - "profile_screen.dart"
Cohesion: 0.09
Nodes (23): _buildAvatarSection, _buildEditProfileTile, _buildLogoutSection, _buildQRCard, _buildSaldoSection, _buildSkeleton, _changeAvatar, createState (+15 more)

### Community 79 - "pengaduan_screen.dart"
Cohesion: 0.09
Nodes (28): PengaduanProvider, build, _buildInfoHeader, _buildSlaInfo, createState, dispose, _formKey, _infoBullet (+20 more)

### Community 80 - "waste_category.dart"
Cohesion: 0.15
Nodes (12): double get, fromJson, hargaBeliPerKg, hargaBeliPerKgAsDouble, id, listFromJson, nama, stokTerkiniKg (+4 more)

### Community 81 - "json_parsing.dart"
Cohesion: 0.25
Nodes (7): parse, parseDateTime, parseDecimal, parseOptionalDateTime, parseOptionalDecimal, tryParse, value

### Community 82 - "storage_service.dart"
Cohesion: 0.13
Nodes (14): FlutterSecureStorage, clearTokens, delete, deleteAll, hasAccessToken, read, readAccessToken, readRefreshToken (+6 more)

### Community 83 - "pengumuman_screen.dart"
Cohesion: 0.15
Nodes (13): build, _AnnouncementCard, build, createState, item, onTap, PengumumanDetailScreen, PengumumanScreen (+5 more)

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

### Community 89 - "PengumumanProvider"
Cohesion: 0.33
Nodes (6): PengumumanProvider, HomeScreen, _HomeScreenState, _loadData, initState, _fallbackPengumuman

### Community 90 - "bottom_nav_scaffold.dart"
Cohesion: 0.04
Nodes (45): exit_dialog.dart, IconData, _buildRecentActivity, badgeCount, _barHeight, BottomNavScaffold, build, _fabProtrude (+37 more)

### Community 91 - "AuthProvider"
Cohesion: 0.15
Nodes (19): AuthProvider, LaunchExperience, _submitOtp, _submitUsername, _handleLogin, build, _sendOtp, _verifyOtp (+11 more)

### Community 92 - "saldo_card.dart"
Cohesion: 0.25
Nodes (7): int?, build, _formatCurrency, isLoading, poin, saldo, SaldoCard

### Community 93 - "Local Development"
Cohesion: 0.33
Nodes (6): 1. Install Dependencies, 2. Konfigurasi API URL, 3. Jalankan Backend & Seed Data, 4. Run App, 5. Akun Demo (Registrasi atau Seed Full), Local Development

### Community 94 - "bool get"
Cohesion: 0.20
Nodes (9): bool get, clearSession, _isLoggedIn, _needsPhoneVerification, refresh, setLoggedIn, setNeedsPhoneVerification, _storage (+1 more)

### Community 95 - "../config/constants.dart"
Cohesion: 0.40
Nodes (4): ../config/constants.dart, name, showWelcomeBackModal, title

### Community 96 - "splash_screen.dart"
Cohesion: 0.20
Nodes (10): build, createState, initState, _minDisplay, previewMode, _splashAsset, SplashScreen, _SplashScreenState (+2 more)

### Community 97 - "konten_edukasi.dart"
Cohesion: 0.20
Nodes (9): json_parsing.dart, createdAt, fromJson, gambarUrl, id, isi, judul, kategoriTerkaitNama (+1 more)

### Community 98 - "package:flutter/foundation.dart"
Cohesion: 0.20
Nodes (9): consumeOnboarding, consumeWasteInvite, consumeWelcomeBack, markLoggedIn, markRegistered, pendingOnboarding, pendingWelcomeBack, _wasteInvitePending (+1 more)

### Community 99 - "_"
Cohesion: 0.15
Nodes (14): Color, _, build, color, complaint, _complaintColor, _complaintIcon, icon (+6 more)

### Community 100 - "home_qr_button.dart"
Cohesion: 0.15
Nodes (12): User, _alive, build, createState, dispose, initState, _restoreBrightness, _setMaxBrightness (+4 more)

### Community 101 - "_buildInfoSection"
Cohesion: 0.50
Nodes (4): _buildStep1, _buildInfoSection, Route /settings/kebijakan-data, Route /settings/tentang

### Community 113 - "../config/theme.dart"
Cohesion: 0.40
Nodes (4): ../config/theme.dart, _buildEdukasiSection, showWasteInviteModal, Route /home/edukasi

### Community 115 - "app_scaffold.dart"
Cohesion: 0.13
Nodes (14): EdgeInsetsGeometry?, actions, AppScaffold, body, bodyPadding, bottomNavigationBar, build, floatingActionButton (+6 more)

### Community 116 - "State"
Cohesion: 0.25
Nodes (11): RiwayatScreen, _RiwayatScreenState, AjukanPenjemputanScreen, _AjukanPenjemputanScreenState, _HomeQrDialog, _HomeQrDialogState, ShimmerWidget, _ShimmerWidgetState (+3 more)

### Community 117 - "VoidCallback"
Cohesion: 0.22
Nodes (8): build, ErrorView, expand, message, onRetry, retryLabel, title, VoidCallback

### Community 119 - "package:go_router/go_router.dart"
Cohesion: 0.29
Nodes (6): icon, LoginPrompt, message, showBackButton, title, package:go_router/go_router.dart

### Community 120 - "AuthSession"
Cohesion: 0.12
Nodes (16): AuthSession, initState, _showNotifPopup, build, build, build, build, build (+8 more)

### Community 122 - "api_exception.dart"
Cohesion: 0.14
Nodes (13): Exception, ApiException, apiExceptionFromDio, code, data, fieldErrors, _localizeAuthMessage, message (+5 more)

### Community 124 - "exit_dialog.dart"
Cohesion: 0.20
Nodes (9): cancelLabel, confirmed, confirmLabel, false, showExitDialog, theme, title, required String message,
  String (+1 more)

### Community 125 - "package:flutter/material.dart"
Cohesion: 0.15
Nodes (10): app.dart, initializeDateFormatting, main, build, PlaceholderScreen, title, package:flutter/material.dart, package:intl/date_symbol_data_local.dart (+2 more)

## Knowledge Gaps
- **1261 isolated node(s):** `XCTest`, `_storageService`, `_authSession`, `_authProvider`, `_homeProvider` (+1256 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AuthSession` connect `AuthSession` to `qrcode_screen.dart`, `auth_service.dart`, `auth_interceptor.dart`, `tarik_saldo_screen.dart`, `ajukan_penjemputan_screen.dart`, `app.dart`, `auth_provider.dart`, `reward_screen.dart`, `penjemputan_screen.dart`, `notifikasi_screen.dart`, `tukar_poin_screen.dart`, `riwayat_screen.dart`, `HomeProvider`, `home_screen.dart`, `profile_screen.dart`, `pengaduan_screen.dart`, `pengumuman_screen.dart`, `PengumumanProvider`, `AuthProvider`, `bool get`, `State`?**
  _High betweenness centrality (0.045) - this node is a cross-community bridge._
- **Why does `AuthProvider` connect `AuthProvider` to `PengumumanProvider`, `login_screen.dart`, `HomeProvider`, `home_screen.dart`, `register_screen.dart`, `app.dart`, `splash_screen.dart`, `auth_provider.dart`, `notifikasi_screen.dart`, `profile_screen.dart`, `State`, `forgot_password_screen.dart`, `phone_verify_screen.dart`, `riwayat_screen.dart`, `reset_password_screen.dart`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **Why does `HomeProvider` connect `HomeProvider` to `qrcode_screen.dart`, `harga_berlaku_banner.dart`, `tarik_saldo_screen.dart`, `ajukan_penjemputan_screen.dart`, `app.dart`, `reward_screen.dart`, `penjemputan_screen.dart`, `notifikasi_screen.dart`, `tukar_poin_screen.dart`, `home_provider.dart`, `riwayat_screen.dart`, `home_screen.dart`, `info_sampah_screen.dart`, `complete_profile_dialog.dart`, `profile_screen.dart`, `pengaduan_screen.dart`, `PengumumanProvider`, `AuthProvider`, `home_qr_button.dart`, `State`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **What connects `XCTest`, `_storageService`, `_authSession` to the rest of the system?**
  _1261 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `onboarding_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `MIRU Bank Sampah — Mobile App (Miru-G)` be split into smaller, more focused modules?**
  _Cohesion score 0.13333333333333333 - nodes in this community are weakly interconnected._
- **Should `04 — API Integration (Mobile)` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._