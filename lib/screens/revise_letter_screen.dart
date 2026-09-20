import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ReviseLetterScreen extends StatefulWidget {
  final int letterId;
  final String requestNumber;
  final String? adminNote;

  const ReviseLetterScreen({
    super.key,
    required this.letterId,
    required this.requestNumber,
    this.adminNote,
  });

  @override
  State<ReviseLetterScreen> createState() =>
      _ReviseLetterScreenState();
}

class _ReviseLetterScreenState
    extends State<ReviseLetterScreen> {
  PlatformFile? ktpFile;
  PlatformFile? kkFile;
  PlatformFile? supportingFile;

  bool submitting = false;

  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'jpeg',
        'png',
        'pdf',
      ],
      withData: true,
      allowMultiple: false,
    );

    if (result == null ||
        result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;

    if (file.size > 2 * 1024 * 1024) {
      showMessage(
        'Ukuran file maksimal 2 MB.',
      );

      return null;
    }

    return file;
  }

  Future<void> pickKtp() async {
    final file = await pickFile();

    if (file == null) return;

    setState(() {
      ktpFile = file;
    });
  }

  Future<void> pickKk() async {
    final file = await pickFile();

    if (file == null) return;

    setState(() {
      kkFile = file;
    });
  }

  Future<void> pickSupporting() async {
    final file = await pickFile();

    if (file == null) return;

    setState(() {
      supportingFile = file;
    });
  }

  Future<void> submitRevision() async {
    if (ktpFile == null &&
        kkFile == null &&
        supportingFile == null) {
      showMessage(
        'Pilih minimal satu dokumen yang ingin diperbaiki.',
      );

      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      await ApiService.reviseLetter(
        letterId: widget.letterId,
        ktpFile: ktpFile,
        kkFile: kkFile,
        supportingFile: supportingFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Revisi berhasil dikirim.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget fileButton({
    required String title,
    required PlatformFile? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: submitting ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color:
                const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFFFEDD5),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Icon(
                file == null
                    ? Icons.upload_file_outlined
                    : Icons.check_circle_outline,
                color:
                    const Color(0xFFEA580C),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file?.name ??
                        'Pilih file pengganti',
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF1F5F9),

      appBar: AppBar(
        title: const Text(
          'Perbaiki Pengajuan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor:
            const Color(0xFF0F172A),
      ),

      body: ListView(
        padding:
            const EdgeInsets.all(18),
        children: [
          Container(
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  const Color(0xFFFFF7ED),
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color:
                    const Color(0xFFFED7AA),
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons
                          .error_outline_rounded,
                      color:
                          Color(0xFFEA580C),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Perlu Perbaikan',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF9A3412),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.requestNumber,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                if (widget.adminNote !=
                        null &&
                    widget.adminNote!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Catatan dari Admin',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.adminNote!,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Upload Dokumen Perbaikan',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Upload hanya dokumen yang perlu diganti. Format JPG, JPEG, PNG atau PDF. Maksimal 2 MB.',
            style: TextStyle(
              color:
                  Color(0xFF64748B),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          fileButton(
            title: 'KTP',
            file: ktpFile,
            onTap: pickKtp,
          ),

          const SizedBox(height: 12),

          fileButton(
            title: 'Kartu Keluarga',
            file: kkFile,
            onTap: pickKk,
          ),

          const SizedBox(height: 12),

          fileButton(
            title:
                'Dokumen Pendukung',
            file: supportingFile,
            onTap: pickSupporting,
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: submitting
                  ? null
                  : submitRevision,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFEA580C,
                ),
                foregroundColor:
                    Colors.white,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                            Colors.white,
                      ),
                    )
                  : const Text(
                      'Kirim Perbaikan',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}