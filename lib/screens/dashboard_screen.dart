import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? dashboard;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      final result = await ApiService.getDashboard();

      if (!mounted) return;

      setState(() {
        dashboard = result['data'];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> logout() async {
    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF0284C7),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Desa Sidorejo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Text(error!),
                )
              : RefreshIndicator(
                  onRefresh: loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dashboard Warga',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ringkasan layanan Desa Sidorejo',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        statCard(
                          title: 'Total Permohonan Surat',
                          value:
                              '${dashboard?['letters']?['total'] ?? 0}',
                          icon: Icons.description_outlined,
                        ),

                        const SizedBox(height: 14),

                        statCard(
                          title: 'Menunggu Verifikasi',
                          value:
                              '${dashboard?['letters']?['waiting'] ?? 0}',
                          icon: Icons.schedule_outlined,
                        ),

                        const SizedBox(height: 14),

                        statCard(
                          title: 'Sedang Diproses',
                          value:
                              '${dashboard?['letters']?['process'] ?? 0}',
                          icon: Icons.sync_outlined,
                        ),

                        const SizedBox(height: 14),

                        statCard(
                          title: 'Surat Selesai',
                          value:
                              '${dashboard?['letters']?['completed'] ?? 0}',
                          icon: Icons.check_circle_outline,
                        ),

                        const SizedBox(height: 14),

                        statCard(
                          title: 'Total Pengaduan',
                          value:
                              '${dashboard?['complaints']?['total'] ?? 0}',
                          icon: Icons.chat_bubble_outline,
                        ),

                        const SizedBox(height: 14),

                        statCard(
                          title: 'Notifikasi Belum Dibaca',
                          value:
                              '${dashboard?['notifications']?['unread'] ?? 0}',
                          icon: Icons.notifications_none,
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Menu Layanan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.4,
                          children: const [
                            _MenuCard(
                              title: 'Ajukan Surat',
                              icon: Icons.description_outlined,
                            ),
                            _MenuCard(
                              title: 'Riwayat Surat',
                              icon: Icons.history,
                            ),
                            _MenuCard(
                              title: 'Pengaduan',
                              icon: Icons.chat_bubble_outline,
                            ),
                            _MenuCard(
                              title: 'Notifikasi',
                              icon: Icons.notifications_none,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _MenuCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: const Color(0xFF0284C7),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}