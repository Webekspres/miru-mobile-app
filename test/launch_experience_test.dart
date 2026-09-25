import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/launch_experience.dart';

void main() {
  test('register suppresses welcome-back and waste invite', () {
    final launch = LaunchExperience();
    launch.markRegistered();
    expect(launch.pendingOnboarding, isTrue);
    expect(launch.consumeWelcomeBack(), isFalse);
    expect(launch.consumeWasteInvite(), isFalse);
  });

  test('fresh login queues welcome-back and waste invite', () {
    final launch = LaunchExperience();
    launch.consumeWasteInvite();
    launch.markLoggedIn();
    expect(launch.consumeWelcomeBack(), isTrue);
    expect(launch.consumeWasteInvite(), isTrue);
  });

  test('cold start waste invite is consumed once', () {
    final launch = LaunchExperience();
    expect(launch.consumeWasteInvite(), isTrue);
    expect(launch.consumeWasteInvite(), isFalse);
  });
}
