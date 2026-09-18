import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'letter_detail_screen.dart';
import 'create_letter_screen.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() =>
      _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  List<dynamic> letters = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadLetters();
  }

  Future<void> loadLetters() async {
    try {
      final result = await ApiService.getLetters();

      if (!mounted) return;

      setState(() {
        letters = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        loading = false;
      });
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'MENUNGGU VERIFIKASI':
        return Colors.amber;

      case 'DIPROSES':
        return Colors.blue;

      case 'PERLU PERBAIKAN':
        return Colors.orange;

      case 'DITOLAK':
        return Colors.red;

      case 'SELESAI':
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  String formatDate(String? value) {
    if (value == null) {
      return '-';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Permohonan Surat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateLetterScreen(),
            ),
          );

          if (result == true) {
            loadLetters();
          }
        },
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Ajukan Surat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadLetters,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadLetters,
                  child: letters.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: const [
                            SizedBox(height: 120),
                            Icon(
                              Icons.description_outlined,
                              size: 64,
                              color: Color(0xFF94A3B8),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada permohonan surat.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Permohonan surat yang kamu ajukan akan tampil di sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            100,
                          ),
                          itemCount: letters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final letter = letters[index];

                            final letterType =
                                letter['letter_type'];

                            final status =
                                letter['status'] ??
                                    '-';

                            final statusColor =
                                getStatusColor(status);

                            return InkWell(
                              borderRadius:
                                  BorderRadius.circular(20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LetterDetailScreen(
                                      letterId: letter['id'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                const Color(
                                              0xFFE0F2FE,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons
                                                .description_outlined,
                                            color:
                                                Color(0xFF0284C7),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 14,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                letterType?[
                                                        'name'] ??
                                                    'Surat',
                                                style:
                                                    const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                letter[
                                                        'request_number'] ??
                                                    '-',
                                                style:
                                                    const TextStyle(
                                                  color:
                                                      Color(
                                                    0xFF64748B,
                                                  ),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: statusColor
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    const Divider(
                                      height: 1,
                                    ),

                                    const SizedBox(height: 14),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons
                                              .calendar_today_outlined,
                                          size: 16,
                                          color:
                                              Color(0xFF64748B),
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          formatDate(
                                            letter[
                                                'created_at'],
                                          ),
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(0xFF64748B),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}