import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';

class CreateLetterScreen extends StatefulWidget {
  const CreateLetterScreen({super.key});

  @override
  State<CreateLetterScreen> createState() =>
      _CreateLetterScreenState();
}

class _CreateLetterScreenState extends State<CreateLetterScreen> {
  final purposeController = TextEditingController();

  List<dynamic> letterTypes = [];

  int? selectedLetterTypeId;
  String? deliveryMethod;

  PlatformFile? ktpFile;
  PlatformFile? kkFile;
  PlatformFile? supportingFile;

  bool loadingTypes = true;
  bool submitting = false;

  dynamic get selectedLetterType {
    if (selectedLetterTypeId == null) {
      return null;
    }

    try {
      return letterTypes.firstWhere(
        (item) => item['id'] == selectedLetterTypeId,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    loadLetterTypes();
  }

  Future<void> loadLetterTypes() async {
    try {
      final result = await ApiService.getLetterTypes();

      if (!mounted) return;

      setState(() {
        letterTypes = result;
        loadingTypes = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingTypes = false;
      });

      showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<PlatformFile?> pickFile() async {
    final FilePickerResult? result =
        await FilePicker.pickFiles(
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

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final PlatformFile file = result.files.single;

    if (file.size > 2 * 1024 * 1024) {
      showError(
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

  Future<void> submit() async {
    if (selectedLetterTypeId == null) {
      showError(
        'Pilih jenis surat terlebih dahulu.',
      );
      return;
    }

    if (purposeController.text.trim().isEmpty) {
      showError(
        'Keperluan wajib diisi.',
      );
      return;
    }

    final type = selectedLetterType;

    final allowPdf =
        type?['allow_pdf'] == true ||
        type?['allow_pdf'] == 1;

    final allowPickup =
        type?['allow_pickup'] == true ||
        type?['allow_pickup'] == 1;

    if ((allowPdf || allowPickup) &&
        deliveryMethod == null) {
      showError(
        'Pilih metode pengiriman surat.',
      );
      return;
    }

    if (ktpFile == null) {
      showError(
        'KTP wajib dipilih.',
      );
      return;
    }

    if (kkFile == null) {
      showError(
        'Kartu Keluarga wajib dipilih.',
      );
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      await ApiService.createLetter(
        letterTypeId: selectedLetterTypeId!,
        purpose: purposeController.text.trim(),
        deliveryMethod: deliveryMethod,
        ktpFile: ktpFile!,
        kkFile: kkFile!,
        supportingFile: supportingFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengajuan surat berhasil dikirim.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      showError(
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

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget fileButton({
    required String title,
    required PlatformFile? file,
    required VoidCallback onTap,
    bool requiredFile = false,
  }) {
    return InkWell(
      onTap: submitting ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                file == null
                    ? Icons.upload_file_outlined
                    : Icons.check_circle_outline,
                color: const Color(0xFF0284C7),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    requiredFile
                        ? '$title *'
                        : title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    file?.name ??
                        'Pilih file JPG, PNG, atau PDF',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                  if (file != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatFileSize(file.size),
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
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
  void dispose() {
    purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = selectedLetterType;

    final allowPdf =
        type?['allow_pdf'] == true ||
        type?['allow_pdf'] == 1;

    final allowPickup =
        type?['allow_pickup'] == true ||
        type?['allow_pickup'] == 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Ajukan Surat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: loadingTypes
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'Jenis Surat',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedLetterTypeId,
                  decoration: InputDecoration(
                    hintText: 'Pilih jenis surat',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  items: letterTypes.map((type) {
                    return DropdownMenuItem<int>(
                      value: type['id'],
                      child: Text(
                        type['name'],
                      ),
                    );
                  }).toList(),
                  onChanged: submitting
                      ? null
                      : (value) {
                          setState(() {
                            selectedLetterTypeId =
                                value;
                            deliveryMethod = null;
                          });
                        },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Keperluan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: purposeController,
                  enabled: !submitting,
                  maxLines: 5,
                  maxLength: 1000,
                  decoration: InputDecoration(
                    hintText:
                        'Jelaskan keperluan pengajuan surat...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
                if (type != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Metode Pengiriman',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (allowPdf)
                    RadioListTile<String>(
                      value: 'pdf',
                      groupValue: deliveryMethod,
                      onChanged: submitting
                          ? null
                          : (value) {
                              setState(() {
                                deliveryMethod =
                                    value;
                              });
                            },
                      title: const Text(
                        'PDF / Digital',
                      ),
                      subtitle: const Text(
                        'Surat diterima dalam bentuk digital.',
                      ),
                    ),
                  if (allowPickup)
                    RadioListTile<String>(
                      value: 'pickup',
                      groupValue: deliveryMethod,
                      onChanged: submitting
                          ? null
                          : (value) {
                              setState(() {
                                deliveryMethod =
                                    value;
                              });
                            },
                      title: const Text(
                        'Ambil di Kantor Desa',
                      ),
                      subtitle: const Text(
                        'Surat diambil langsung setelah selesai.',
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                const Text(
                  'Dokumen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Format JPG, JPEG, PNG, atau PDF. Maksimal 2 MB per file.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),
                fileButton(
                  title: 'KTP',
                  file: ktpFile,
                  onTap: pickKtp,
                  requiredFile: true,
                ),
                const SizedBox(height: 12),
                fileButton(
                  title: 'Kartu Keluarga',
                  file: kkFile,
                  onTap: pickKk,
                  requiredFile: true,
                ),
                const SizedBox(height: 12),
                fileButton(
                  title: 'Dokumen Pendukung',
                  file: supportingFile,
                  onTap: pickSupporting,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        submitting ? null : submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Kirim Pengajuan',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}