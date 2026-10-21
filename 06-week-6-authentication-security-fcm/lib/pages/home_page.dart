import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _simulateForegroundPush(BuildContext context) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        leading: const Icon(Icons.notifications_active, color: Colors.blue),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: Colors.blue.shade50,
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Jadwal kuliah berubah',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 2),
            Text(
              'Kelas Mobile pindah ke Ruang A2 jam 13.00',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('Tutup'),
          ),
          FilledButton.tonal(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              context.push(AppRoutes.announcementPath('1'));
            },
            child: const Text('Buka Pengumuman'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(fcmTokenProvider);
    final isSubscribed = ref.watch(topicSubscribedProvider);
    final announcements = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              'Campus Notify',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar (Logout)',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar dari Akun?'),
                  content: const Text(
                    'Token sesi dan refresh token di secure storage akan dibersihkan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authStateProvider.notifier).logout();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card 1: FCM Token Security & Debug
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
                      Icon(Icons.security, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Status Token FCM (Tersamar & Aman)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  tokenAsync.when(
                    data: (token) => Text(
                      'Registration Token: ${PushService.maskToken(token)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    loading: () => const Text('Memuat token FCM...'),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Simulasi Token Refresh'),
                        onPressed: () {
                          ref.read(fcmTokenProvider.notifier).rotateToken();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Token baru diterbitkan & dikirim ke POST /devices backend!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Card 2: Topic Subscription & Push Simulation
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.campaign, color: Colors.purple),
                  title: const Text('Topik: pengumuman-kampus'),
                  subtitle: const Text(
                    'Berlangganan broadcast seluruh mahasiswa',
                  ),
                  value: isSubscribed,
                  onChanged: (val) {
                    ref.read(topicSubscribedProvider.notifier).toggle();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.send_to_mobile, color: Colors.blue),
                  title: const Text('Uji Push Notification (Foreground)'),
                  subtitle: const Text(
                    'Simulasikan banner notifikasi lokal saat app terbuka',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => _simulateForegroundPush(context),
                    child: const Text('Kirim'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Header Pengumuman
          const Row(
            children: [
              Icon(Icons.announcement, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Daftar Pengumuman Kampus',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List Announcements
          ...announcements.map((ann) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                onTap: () =>
                    context.push(AppRoutes.announcementPath(ann.id)),
                leading: CircleAvatar(
                  backgroundColor: ann.important
                      ? Colors.red.shade100
                      : Colors.blue.shade100,
                  child: Icon(
                    ann.important ? Icons.priority_high : Icons.campaign,
                    color: ann.important ? Colors.red : Colors.blue,
                  ),
                ),
                title: Text(
                  ann.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      ann.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ann.category} • ${ann.date}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          }),
        ],
      ),
    );
  }
}
