# Graph Report - mirumobileapp  (2026-07-08)

## Corpus Check
- 79 files · ~19,749 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 756 nodes · 809 edges · 73 communities (60 shown, 13 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `888cd23f`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]

## God Nodes (most connected - your core abstractions)
1. `08 — Task List: Mobile App Development Roadmap` - 17 edges
2. `_` - 16 edges
3. `MIRU Bank Sampah — Mobile App (Miru-G)` - 13 edges
4. `04 — API Integration (Mobile)` - 11 edges
5. `Ringkasan Aturan untuk UI Mobile` - 11 edges
6. `01 — Project Overview (Mobile App)` - 10 edges
7. `10 — Integration & Roles (Mobile App)` - 10 edges
8. `⚠️ Batasan KERAS — Jangan Implementasikan di Mobile` - 9 edges
9. `Fase 3: MVP Screens` - 9 edges
10. `09 — Data Dictionary & Reference Values (Mobile)` - 9 edges

## Surprising Connections (you probably didn't know these)
- `MiruApp` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/app.dart → None  _Bridges community 15 → community 65_
- `RegisterScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/auth/register_screen.dart → None  _Bridges community 65 → community 64_
- `HomeScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/home/home_screen.dart → None  _Bridges community 65 → community 67_
- `PengaduanScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/pengaduan/pengaduan_screen.dart → None  _Bridges community 65 → community 68_
- `ProfileScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/profile/profile_screen.dart → None  _Bridges community 65 → community 19_

## Import Cycles
- None detected.

## Communities (73 total, 13 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.18
Nodes (10): bool get, ChangeNotifier, package:flutter/foundation.dart, AuthSession, _isLoggedIn, refresh, setLoggedIn, _storage (+2 more)

### Community 1 - "Community 1"
Cohesion: 0.18
Nodes (10): 08 — Task List: Mobile App Development Roadmap, 0.1 Project Setup ✅, Cakupan Modul — Mobile (Nasabah), Checklist Integrasi End-to-End (Mobile ↔ Backend ↔ Web Admin), Definisi "Selesai" per Tahap, Environment Testing, Fase 0: Scaffold ✅ Selesai, Matriks Dependensi Backend → Mobile (+2 more)

### Community 2 - "Community 2"
Cohesion: 0.09
Nodes (21): 1. Install Dependencies, 2. Konfigurasi API URL, 3. Jalankan Backend & Seed Data, 4. Run App, 5. Akun Demo (Registrasi atau Seed Full), Autentikasi, Batasan Penting, Branding (+13 more)

### Community 3 - "Community 3"
Cohesion: 0.11
Nodes (18): 04 — API Integration (Mobile), 10. Batasan Mobile, 1. Base Configuration, 2. JSON Envelope — WAJIB Dipahami, 3.1 Endpoints, 3.2 Login Flow, 3.3 Registrasi Flow, 3.4 Token Refresh (Interceptor) (+10 more)

### Community 4 - "Community 4"
Cohesion: 0.11
Nodes (17): 05 — Business Rules & SOPs (Mobile), 10. Kartu Digital (QR Code), 11. Standar Waktu yang Ditampilkan ke Nasabah, 12. Jam Layanan, 13. Informasi Penting Lainnya, 1. Registrasi Nasabah, 2. Dashboard, 3. Informasi Sampah (+9 more)

### Community 5 - "Community 5"
Cohesion: 0.12
Nodes (16): 09 — Data Dictionary & Reference Values (Mobile), A. INFORMASI HARGA — Tampilkan di Home & Info Sampah, B. PANDUAN PEMILAHAN (untuk Info Edukasi), C. KATALOG REWARD (tampilkan di menu Tukar Poin), D. STATUS PENJEMPUTAN — Warna & Ikon untuk UI, E. INDIKATOR POIN (informasi di halaman Tukar Poin), F. JENIS PENGADUAN (untuk dropdown pilihan), Format Berat (+8 more)

### Community 6 - "Community 6"
Cohesion: 0.12
Nodes (16): 10 — Integration & Roles (Mobile App), 1. Role di Mobile App, 2. Matriks Fitur Nasabah vs Staff, 3.1 Onboarding, 3.2 Setor Sampah (Langsung ke Bank), 3.3 Penjemputan Sampah, 3.4 Penarikan Saldo, 3.5 Tukar Poin (+8 more)

### Community 7 - "Community 7"
Cohesion: 0.13
Nodes (14): 03 — State Management (Mobile), 1. AuthProvider, 2. SaldoProvider, 3. PenjemputanProvider, 4. RewardProvider, 5. PengaduanProvider, Data Flow Pattern, JSON Envelope di Provider (+6 more)

### Community 8 - "Community 8"
Cohesion: 0.17
Nodes (11): 00 — System Prompt & Clean Code Rules (Mobile), 1. Struktur Folder, 2. Models (Data Classes), 3. State Management, 4. UI Patterns, 5. API Integration, 6. Error Handling, 7. Performance (+3 more)

### Community 9 - "Community 9"
Cohesion: 0.17
Nodes (11): 06 — System Constraints (Mobile), 1. TIDAK ADA Pembayaran Otomatis, 2. TIDAK ADA Live GPS Tracking, 3. TIDAK ADA Scan KTP/Face Recognition, 4. TIDAK ADA Integrasi Dukcapil, 5. Hanya Nasabah yang Login, 6. Prioritas Android, 7. Koneksi Internet Diperlukan (+3 more)

### Community 10 - "Community 10"
Cohesion: 0.18
Nodes (10): 01 — Project Overview (Mobile App), Fitur Utama (Mobile — Nasabah), Informasi Branding, Jam Layanan, Latar Belakang, Platform, Posisi dalam Ekosistem, Referensi Dokumen Terkait (+2 more)

### Community 11 - "Community 11"
Cohesion: 0.20
Nodes (7): Any, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, Bool, AppDelegate, UIApplication

### Community 12 - "Community 12"
Cohesion: 0.04
Nodes (45): api_exception.dart, ../config/theme.dart, Exception, int?, Map, ApiEnvelope, ApiMeta, code (+37 more)

### Community 13 - "Community 13"
Cohesion: 0.13
Nodes (14): FlutterSecureStorage, package:flutter_secure_storage/flutter_secure_storage.dart, clearTokens, delete, deleteAll, hasAccessToken, read, readAccessToken (+6 more)

### Community 14 - "Community 14"
Cohesion: 0.25
Nodes (7): 07 — Modules & Features (Mobile), 14 Fitur Mobile — untuk Nasabah, Desain Halaman, HomeScreen (Dashboard), PenjemputanScreen, RewardScreen, TarikSaldoScreen

### Community 15 - "Community 15"
Cohesion: 0.06
Nodes (33): AuthService, createAppRouter, config/routes.dart, _publicRoutes, GoRouter, _apiClient, _authService, _authSession (+25 more)

### Community 16 - "Community 16"
Cohesion: 0.29
Nodes (6): 02 — Architecture & Stack (Mobile), Architecture Pattern: Provider + Service, Arsitektur, Arsitektur Navigasi (go_router), Environment, Tech Stack

### Community 17 - "Community 17"
Cohesion: 0.29
Nodes (6): ⚠️ AI Steering — baca on-demand (jangan semua sekaligus), Aturan Keras, graphify, MIRU Bank Sampah — Mobile App Nasabah (Flutter), Prioritas Platform, Referensi Cepat

### Community 18 - "Community 18"
Cohesion: 0.18
Nodes (10): accessTokenKey, apiBaseUrl, AppConstants, appName, connectTimeout, receiveTimeout, refreshTokenKey, tokenExpiry (+2 more)

### Community 19 - "Community 19"
Cohesion: 0.20
Nodes (7): build, ProfileScreen, build, RiwayatScreen, build, TarikSaldoScreen, ../../widgets/placeholder_screen.dart

### Community 20 - "Community 20"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 21 - "Community 21"
Cohesion: 0.33
Nodes (5): graphify, Hook-Based Usage, Installation Verification, Meta Commands (always use rtk directly), RTK - Rust Token Killer

### Community 22 - "Community 22"
Cohesion: 0.40
Nodes (4): Graphify Knowledge Graph, MIRU Mobile App — Agent Rules, Stack, Token Savers (WAJIB)

### Community 23 - "Community 23"
Cohesion: 0.08
Nodes (24): Color get, dijadwalkan,
  dalamPerjalanan,
  dijemput,
  selesai,, alamatJemput, apiValue, badgeColor, displayLabel, ditolak, estimasiBerat (+16 more)

### Community 24 - "Community 24"
Cohesion: 0.11
Nodes (17): api_client.dart, ApiClient, apiClient, _asJsonMap, AuthService, authSession, getAccessToken, getMe (+9 more)

### Community 26 - "Community 26"
Cohesion: 0.50
Nodes (3): package:flutter_test/flutter_test.dart, package:mirumobileapp/app.dart, main

### Community 40 - "Community 40"
Cohesion: 0.12
Nodes (16): AuthSession, Future, AuthInterceptor, authSession, _clearSession, _doRefresh, _isPublicPath, onError (+8 more)

### Community 41 - "Community 41"
Cohesion: 0.22
Nodes (8): Interceptor, _envelopeException, EnvelopeInterceptor, onError, onResponse, ../../models/api_envelope.dart, ../../models/api_exception.dart, package:dio/dio.dart

### Community 42 - "Community 42"
Cohesion: 0.22
Nodes (8): interceptors/auth_interceptor.dart, interceptors/envelope_interceptor.dart, ../../providers/auth_session.dart, ApiClient, _createDio, dio, ../storage_service.dart, T

### Community 43 - "Community 43"
Cohesion: 0.29
Nodes (7): 1.1 Dependencies (`pubspec.yaml`), 1.2 Folder Structure, 1.3 Config & Theme, 1.4 API Client (Modul 2 — infrastruktur), 1.5 Core Models, 1.6 Shared Widgets, Fase 1: Foundation

### Community 44 - "Community 44"
Cohesion: 0.50
Nodes (3): ../config/constants.dart, build, SplashScreen

### Community 45 - "Community 45"
Cohesion: 0.04
Nodes (46): double get, json_parsing.dart, menunggu,
  selesai,, beratKg, beratKgAsDouble, DepositDetail, fromJson, hargaSaatItu (+38 more)

### Community 46 - "Community 46"
Cohesion: 0.09
Nodes (22): beratTidakSesuai,
  hargaTidakSesuai,
  petugasTidakDatang,
  kesalahanData,, apiValue, buktiTidakMuncul, Complaint, ComplaintJenis, ComplaintStatus, displayLabel, ditutup (+14 more)

### Community 47 - "Community 47"
Cohesion: 0.09
Nodes (22): menunggu,, apiValue, createPayload, displayLabel, fromApiValue, fromJson, id, listFromJson (+14 more)

### Community 48 - "Community 48"
Cohesion: 0.10
Nodes (20): deposit_detail.dart, buktiDigital, Deposit, DepositDigitalProof, details, fromJson, id, listFromJson (+12 more)

### Community 49 - "Community 49"
Cohesion: 0.10
Nodes (21): IconData, ../models/complaint.dart, ../models/pickup.dart, Widget?, action, build, description, EmptyState (+13 more)

### Community 50 - "Community 50"
Cohesion: 0.09
Nodes (21): ActivityItem, ActivityType, apiValue, displayLabel, fromApiValue, fromJson, id, isCredit (+13 more)

### Community 51 - "Community 51"
Cohesion: 0.10
Nodes (20): DateTime, alamat, dateJoined, fromJson, id, isActive, isNasabah, listFromJson (+12 more)

### Community 52 - "Community 52"
Cohesion: 0.20
Nodes (9): fromJson, id, isAffordable, listFromJson, nama, poinDibutuhkan, Reward, stok (+1 more)

### Community 53 - "Community 53"
Cohesion: 0.22
Nodes (9): 3.1 HomeScreen / Dashboard (Modul 15, 5, 9), 3.2 Profil & Kartu Digital (Modul 3), 3.3 Info Sampah (Modul 4, 5), 3.4 Penjemputan (Modul 7), 3.5 Riwayat Transaksi (Modul 9), 3.6 Tarik Saldo (Modul 10), 3.7 Reward & Tukar Poin (Modul 11), 3.8 Pengaduan (Modul 14) (+1 more)

### Community 54 - "Community 54"
Cohesion: 0.29
Nodes (6): parse, parseDateTime, parseDecimal, parseOptionalDateTime, tryParse, value

### Community 55 - "Community 55"
Cohesion: 0.33
Nodes (6): 2.1 AuthProvider, 2.2 SplashScreen, 2.3 LoginScreen, 2.4 RegisterScreen, 2.5 Auth Routing, Fase 2: Auth Flow (Modul 2)

### Community 56 - "Community 56"
Cohesion: 0.40
Nodes (5): 8.1 Push Notifications, 8.2 iOS, 8.3 Enhancements, 8.4 Yang TIDAK BOLEH Diimplementasikan, Fase 8: Post-MVP

### Community 57 - "Community 57"
Cohesion: 0.50
Nodes (4): 4.1 Navigation, 4.2 UX Polish, 4.3 Performance, Fase 4: Navigation & UX Polish

### Community 58 - "Community 58"
Cohesion: 0.50
Nodes (4): 5.1 SettingsScreen, 5.2 Pengumuman, 5.3 Kebijakan Data, Fase 5: Settings & Informasi (Modul 17)

### Community 59 - "Community 59"
Cohesion: 0.50
Nodes (4): 6.1 Automated Tests, 6.2 Manual / UAT Checklist, 6.3 Edge Cases, Fase 6: Kualitas & Testing

### Community 60 - "Community 60"
Cohesion: 0.50
Nodes (4): 7.1 Build Configuration, 7.2 Play Store Preparation, 7.3 Security, Fase 7: Production Android

### Community 61 - "Community 61"
Cohesion: 0.15
Nodes (12): EdgeInsetsGeometry?, List, actions, body, bodyPadding, bottomNavigationBar, build, floatingActionButton (+4 more)

### Community 62 - "Community 62"
Cohesion: 0.22
Nodes (8): AppTheme, errorColor, primaryColor, primaryDark, surfaceColor, _textTheme, static const Color, static const TextTheme

### Community 63 - "Community 63"
Cohesion: 0.22
Nodes (8): VoidCallback?, build, ErrorView, expand, message, onRetry, retryLabel, title

### Community 64 - "Community 64"
Cohesion: 0.29
Nodes (5): app.dart, build, RegisterScreen, main, package:flutter/material.dart

### Community 65 - "Community 65"
Cohesion: 0.29
Nodes (6): build, LoginScreen, StatelessWidget, AppScaffold, HomeAppScaffold, StatusBadge

### Community 66 - "Community 66"
Cohesion: 0.50
Nodes (3): build, PlaceholderScreen, title

## Knowledge Gaps
- **514 isolated node(s):** `SBFrame`, `SBDebugger`, `flutter_export_environment.sh script`, `UIApplication`, `Any` (+509 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `_` connect `Community 49` to `Community 64`, `Community 65`?**
  _High betweenness centrality (0.019) - this node is a cross-community bridge._
- **Why does `08 — Task List: Mobile App Development Roadmap` connect `Community 1` to `Community 43`, `Community 53`, `Community 55`, `Community 56`, `Community 57`, `Community 58`, `Community 59`, `Community 60`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **Why does `MiruApp` connect `Community 15` to `Community 65`?**
  _High betweenness centrality (0.004) - this node is a cross-community bridge._
- **What connects `SBFrame`, `SBDebugger`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` to the rest of the system?**
  _515 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.10526315789473684 - nodes in this community are weakly interconnected._
- **Should `Community 4` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._