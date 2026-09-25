import 'package:flutter/foundation.dart';

/// Session flags for first-run UX (onboarding + launch modals).
class LaunchExperience extends ChangeNotifier {
  bool pendingOnboarding = false;
  bool pendingWelcomeBack = false;
  bool _wasteInvitePending = true;

  void markRegistered() {
    pendingOnboarding = true;
    pendingWelcomeBack = false;
    _wasteInvitePending = false;
    notifyListeners();
  }

  /// Fresh login: welcome-back + "yuk kelola sampah" on home.
  void markLoggedIn() {
    if (pendingOnboarding) return;
    pendingWelcomeBack = true;
    _wasteInvitePending = true;
    notifyListeners();
  }

  void consumeOnboarding() {
    pendingOnboarding = false;
    notifyListeners();
  }

  bool consumeWelcomeBack() {
    if (!pendingWelcomeBack) return false;
    pendingWelcomeBack = false;
    notifyListeners();
    return true;
  }

  bool consumeWasteInvite() {
    if (!_wasteInvitePending) return false;
    _wasteInvitePending = false;
    return true;
  }
}
