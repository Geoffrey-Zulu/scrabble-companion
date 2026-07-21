abstract final class PrivacyPolicy {
  static const title = 'Privacy Policy';
  static const subtitle = 'Last updated: July 2026';

  static const sections = [
    PrivacySection(
      title: 'Offline First',
      body:
          'Scrabble Companion is designed to be fully functional without an internet connection. We do not transmit your game data, scores, or settings to any external servers.',
    ),
    PrivacySection(
      title: 'Local Data Storage',
      body:
          'All game history and personal preferences are stored locally on your device. This data remains on your phone and is not accessible by us.',
    ),
    PrivacySection(
      title: 'Analytics & Tracking',
      body:
          'We do not use any third-party analytics, tracking cookies, or advertising identifiers. Your usage of the app is completely private.',
    ),
    PrivacySection(
      title: 'Permissions',
      body:
          'The app requires minimal permissions to function. We do not access your contacts, location, or camera.',
    ),
    PrivacySection(
      title: 'Feedback',
      body:
          'If you choose to send feedback via email, we will only use your email address to respond to your inquiry. We do not share your contact information with third parties.',
    ),
  ];
}

class PrivacySection {
  const PrivacySection({required this.title, required this.body});
  final String title;
  final String body;
}
