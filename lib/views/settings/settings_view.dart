import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firebase_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings & Firebase"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Firebase Connection Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF0284C7).withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.cloud_done_outlined,
                                color: Color(0xFFF59E0B), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Firebase Data Connection",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "Cloud Firestore & Real-Time Sync",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (firebaseService.isFirebaseInitialized
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF0284C7))
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          firebaseService.isFirebaseInitialized
                              ? "Online Firebase"
                              : "Demo / Offline Store",
                          style: TextStyle(
                            color: firebaseService.isFirebaseInitialized
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0284C7),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    "How to connect your live Firebase project:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "1. Place your 'google-services.json' in 'android/app/' folder.\n"
                    "2. Or run 'flutterfire configure' in terminal to automatically link Web, Android, and Windows projects.\n"
                    "3. In the meantime, the app runs smoothly with full reactive in-memory data.",
                    style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Appearance
            Text(
              "Appearance",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                ),
              ),
              child: SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: const Color(0xFF0284C7),
                ),
                title: const Text("Dark Theme"),
                subtitle: const Text("Midnight Slate & Cyan aesthetic"),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const SizedBox(height: 20),

            // Shop Details
            Text(
              "Mobile Shop Profile",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C2541) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A395E) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _infoRow("Shop Name", "Umar Farooq Mobile Zone"),
                  const Divider(height: 18),
                  _infoRow("Market Location", "Hafeez Centre, Main Boulevard"),
                  const Divider(height: 18),
                  _infoRow("Contact Phone", "+92 300 0000000"),
                  const Divider(height: 18),
                  _infoRow("Base Currency", "Pakistani Rupee (PKR / Rs.)"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
