import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'revise_letter_screen.dart';

class LetterDetailScreen extends StatefulWidget {
  final int letterId;

  const LetterDetailScreen({
    super.key,
    required this.letterId,
  });

  @override
  State<LetterDetailScreen> createState() =>
      _LetterDetailScreenState();
}

class _LetterDetailScreenState
    extends State<LetterDetailScreen> {
  Map<String, dynamic>? letter;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    try {
      if (mounted) {
        setState(() {
          loading = true;
          error = null;
        });
      }

      final result =
          await ApiService.getLetterDetail(
        widget.letterId,
      );

      if (!mounted) return;

      setState(() {
        letter = result;
        loading = false;
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

  Widget infoCard(
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openRevision() async {
    if (letter == null) {
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviseLetterScreen(
          letterId:
              letter!['id'] ?? widget.letterId,

          requestNumber:
              letter!['request_number']
                      ?.toString() ??
                  '-',

          purpose:
              letter!['purpose']
                      ?.toString() ??
                  '',

          adminNote:
              letter!['admin_note']
                  ?.toString(),
        ),
      ),
    );

    if (result == true) {
      await loadDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status =
        letter?['status']?.toString() ?? '';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F5F9),

      appBar: AppBar(
        title: const Text(
          'Detail Surat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF0F172A),
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      24,
                    ),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .error_outline_rounded,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          error!,
                          textAlign:
                              TextAlign.center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElevatedButton(
                          onPressed: loadDetail,
                          child:
                              const Text(
                            'Coba Lagi',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDetail,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(
                          20,
                        ),
                        decoration:
                            BoxDecoration(
                          gradient:
                              const LinearGradient(
                            colors: [
                              Color(
                                0xFF0EA5E9,
                              ),
                              Color(
                                0xFF2563EB,
                              ),
                            ],
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            24,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Icon(
                              Icons
                                  .description_outlined,
                              color:
                                  Colors.white,
                              size: 34,
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            Text(
                              letter?[
                                          'letter_type']
                                      ?['name'] ??
                                  'Surat',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontSize: 22,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              letter?[
                                      'request_number'] ??
                                  '-',
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Container(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                          border: Border.all(
                            color:
                                const Color(
                              0xFFE2E8F0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            const Text(
                              'Status',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    getStatusColor(
                                  status,
                                ).withOpacity(
                                  0.12,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  999,
                                ),
                              ),
                              child: Text(
                                status.isEmpty
                                    ? '-'
                                    : status,
                                style:
                                    TextStyle(
                                  color:
                                      getStatusColor(
                                    status,
                                  ),
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      infoCard(
                        'Keperluan',
                        letter?['purpose']
                                ?.toString() ??
                            '-',
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      infoCard(
                        'Metode Pengiriman',
                        letter?['delivery_method'] ==
                                'pdf'
                            ? 'PDF'
                            : letter?['delivery_method'] ==
                                    'pickup'
                                ? 'Ambil di Kantor Desa'
                                : '-',
                      ),

                      if ((letter?['admin_note'] ??
                              '')
                          .toString()
                          .isNotEmpty) ...[
                        const SizedBox(
                          height: 14,
                        ),
                        Container(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFFFF7ED,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                            border:
                                Border.all(
                              color:
                                  const Color(
                                0xFFFED7AA,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons
                                        .info_outline,
                                    size: 20,
                                    color: Color(
                                      0xFFEA580C,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    'Catatan Admin',
                                    style:
                                        TextStyle(
                                      color:
                                          Color(
                                        0xFFEA580C,
                                      ),
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                letter?[
                                        'admin_note'] ??
                                    '-',
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (status ==
                          'PERLU PERBAIKAN') ...[
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              ElevatedButton.icon(
                            onPressed:
                                openRevision,
                            icon:
                                const Icon(
                              Icons
                                  .edit_document,
                            ),
                            label:
                                const Text(
                              'Perbaiki Pengajuan',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFFEA580C,
                              ),
                              foregroundColor:
                                  Colors.white,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      if ((letter?[
                                      'documents']
                                  as List?)
                              ?.isNotEmpty ??
                          false) ...[
                        const SizedBox(
                          height: 22,
                        ),
                        const Text(
                          'Dokumen',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        ...List.generate(
                          (letter?[
                                      'documents']
                                  as List)
                              .length,
                          (index) {
                            final document =
                                letter?[
                                        'documents']
                                    [index];

                            return Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom: 10,
                              ),
                              padding:
                                  const EdgeInsets
                                      .all(
                                14,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  16,
                                ),
                                border:
                                    Border.all(
                                  color:
                                      const Color(
                                    0xFFE2E8F0,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .attach_file,
                                    color:
                                        Color(
                                      0xFF0284C7,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 12,
                                  ),
                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          document[
                                                  'document_type'] ??
                                              '-',
                                          style:
                                              const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height:
                                              3,
                                        ),
                                        Text(
                                          document[
                                                  'file_name'] ??
                                              '-',
                                          overflow:
                                              TextOverflow
                                                  .ellipsis,
                                          style:
                                              const TextStyle(
                                            color:
                                                Color(
                                              0xFF64748B,
                                            ),
                                            fontSize:
                                                12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],

                      const SizedBox(
                        height: 28,
                      ),
                    ],
                  ),
                ),
    );
  }
}