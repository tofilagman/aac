import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No personal data is collected. Everything stays on your device.',
                      style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _section('Overview',
                'The AAC App is a communication aid for nonverbal and minimally verbal children with autism. '
                'This app does not collect, store, transmit, or share any personal information.'),
            _section('Data Stored on Your Device',
                'The app stores your symbol board configuration and voice preference locally on your device only, '
                'using Android\'s standard storage. This data never leaves your device.'),
            _section('Internet Access',
                'The AAC App does not require an internet connection and makes no network requests. '
                'The app works fully offline.'),
            _section('Text-to-Speech',
                'The app uses Android\'s built-in Text-to-Speech engine. All processing happens '
                'on-device. No audio or text is sent to external servers.'),
            _section('Children\'s Privacy (COPPA)',
                'This app is designed for children under caregiver supervision. We do not collect '
                'any information from children, have no accounts or registration, and share no data '
                'with third parties.'),
            _section('Third-Party Services',
                'The app has no analytics, advertising, or tracking SDKs. There are no ads.'),
            _section('Permissions',
                'The app may request READ_MEDIA_IMAGES only if you choose to add a custom photo '
                'as a symbol image. No other permissions are required.'),
            _section('Contact',
                'Questions? Open an issue at github.com/tofilagman/aac/issues'),
            const SizedBox(height: 8),
            Text(
              'Effective date: June 28, 2026',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }
}
