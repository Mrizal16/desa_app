import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
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
      final result =
          await ApiService.getDashboard();

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
        builder: (_) =>
            const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F5F9),
      appBar: AppBar(
        title:
            const Text('Desa Sidorejo'),
        backgroundColor:
            const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: logout,
            icon:
                const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Text(error!),
                )
              : Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard Warga',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child:
                            SingleChildScrollView(
                          child: Text(
                            dashboard
                                .toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}