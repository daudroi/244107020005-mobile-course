import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeAsync = ref.watch(darkModeProvider);
    final forceOfflineAsync = ref.watch(forceOfflineProvider);
    final lastOpenedAsync = ref.watch(lastOpenedProvider);

    final isDark = darkModeAsync.value ?? false;
    final isOffline = forceOfflineAsync.value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Preferensi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.blueGrey,
                  ),
                  title: const Text('Mode Gelap (Dark Mode)'),
                  subtitle: const Text('Disimpan via SharedPreferences (key: dark_mode)'),
                  value: isDark,
                  onChanged: (val) {
                    ref.read(darkModeProvider.notifier).toggle();
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(
                    isOffline ? Icons.wifi_off : Icons.wifi,
                    color: isOffline ? Colors.orange : Colors.green,
                  ),
                  title: const Text('Simulasi Offline (Force Offline)'),
                  subtitle: const Text('Memutus koneksi jaringan untuk menguji offline-first'),
                  value: isOffline,
                  onChanged: (val) {
                    ref.read(forceOfflineProvider.notifier).toggle();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Terakhir Dibuka'),
              subtitle: lastOpenedAsync.when(
                data: (val) => Text(
                  val ?? 'Baru pertama kali dibuka',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                loading: () => const Text('Memuat...'),
                error: (e, _) => Text('Error: $e'),
              ),
              trailing: const Icon(Icons.info_outline, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Penyimpanan Lokal Minggu 5',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. SharedPreferences: Mengelola preferensi key-value sederhana (tema gelap, flag force offline, timestamp terakhir dibuka).\n\n'
                    '2. SQLite (sqflite): Mengelola data catatan relasional dengan dukungan dirty flag untuk sinkronisasi offline-first dan tabel cached_posts untuk cache-first API.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
