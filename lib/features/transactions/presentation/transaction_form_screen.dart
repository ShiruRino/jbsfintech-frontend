import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/providers.dart';
import '../domain/transaction_attachment.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.transactionId});

  final int? transactionId;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _type = 'expense';
  int? _accountId;
  int? _categoryId;
  DateTime _selectedDate = DateTime.now();
  Uint8List? _attachmentPreviewBytes;
  String? _attachmentName;
  String? _existingAttachmentPath;
  TransactionAttachmentFile? _selectedAttachment;
  bool _removeExistingAttachment = false;
  String? _attachmentError;
  bool _isPickingAttachment = false;
  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_prefill);
  }

  Future<void> _prefill() async {
    if (widget.transactionId == null) {
      return;
    }
    final transaction = await ref.read(
      transactionDetailProvider(widget.transactionId!).future,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _type = transaction.type;
      _accountId = transaction.account?.id;
      _categoryId = transaction.category?.id;
      _selectedDate = transaction.transactionDate ?? DateTime.now();
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note ?? '';
      _existingAttachmentPath =
          transaction.attachmentUrl ?? transaction.attachmentPath;
      _attachmentName = _existingAttachmentPath;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_attachmentError != null) {
      return;
    }

    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });

    final repo = ref.read(transactionsRepositoryProvider);
    final amount =
        int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final result = await ApiResult.guard(() async {
      if (widget.transactionId == null) {
        await repo.createTransaction(
          accountId: _accountId!,
          categoryId: _categoryId!,
          type: _type,
          amount: amount,
          transactionDate: _selectedDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          attachment: _selectedAttachment,
        );
      } else {
        await repo.updateTransaction(
          id: widget.transactionId!,
          accountId: _accountId!,
          categoryId: _categoryId!,
          type: _type,
          amount: amount,
          transactionDate: _selectedDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          attachment: _selectedAttachment,
          removeAttachment: _removeExistingAttachment,
        );
      }
    });

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);

    switch (result) {
      case ApiSuccess<void>():
        ref.invalidate(transactionsProvider);
        ref.invalidate(dashboardProvider);
        if (widget.transactionId != null) {
          ref.invalidate(transactionDetailProvider(widget.transactionId!));
        }
        context.pop();
      case ApiFailure<void>(exception: final error):
        setState(() => _fieldErrors = error.fieldErrors);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _pickAttachment(ImageSource source) async {
    setState(() => _isPickingAttachment = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );

      if (picked == null) {
        return;
      }

      final mimeType = TransactionAttachmentFile.mimeTypeFromFilename(
        picked.name,
      );
      if (mimeType == null) {
        setState(() {
          _attachmentError = 'Format file harus JPG, JPEG, atau PNG.';
        });
        return;
      }

      final sizeBytes = await picked.length();
      if (sizeBytes > TransactionAttachmentFile.maxSizeBytes) {
        setState(() {
          _attachmentError = 'Ukuran foto maksimal 5 MB.';
        });
        return;
      }

      final bytes = await picked.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _attachmentPreviewBytes = bytes;
        _attachmentName = picked.name;
        _selectedAttachment = TransactionAttachmentFile(
          path: picked.path,
          filename: _safeFilename(picked.name),
          sizeBytes: sizeBytes,
          mimeType: mimeType,
        );
        _removeExistingAttachment = false;
        _attachmentError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $error')));
    } finally {
      if (mounted) {
        setState(() => _isPickingAttachment = false);
      }
    }
  }

  void _clearAttachment() {
    setState(() {
      _attachmentPreviewBytes = null;
      _attachmentName = null;
      _selectedAttachment = null;
      _attachmentError = null;
      if (_existingAttachmentPath != null) {
        _removeExistingAttachment = true;
      }
    });
  }

  String _safeFilename(String filename) {
    final sanitized = filename.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return sanitized.isEmpty ? 'attachment.jpg' : sanitized;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider).asData?.value ?? const [];
    final categories = ref.watch(categoriesProvider).asData?.value ?? const [];
    final filteredCategories = categories
        .where((category) => category.type == _type)
        .toList();

    if (_categoryId != null &&
        filteredCategories.every((category) => category.id != _categoryId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _categoryId = null);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transactionId == null ? 'Tambah Transaksi' : 'Ubah Transaksi',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  key: const Key('transaction-type-switch'),
                  segments: const [
                    ButtonSegment(value: 'income', label: Text('Pemasukan')),
                    ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.first;
                      _categoryId = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: _accountId,
                  decoration: InputDecoration(
                    labelText: 'Akun',
                    errorText: _fieldErrors['account_id']?.join(', '),
                  ),
                  items: [
                    for (final account in accounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _accountId = value),
                  validator: (value) => value == null ? 'Pilih akun' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  key: const Key('transaction-category-dropdown'),
                  initialValue: _categoryId,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    errorText: _fieldErrors['category_id']?.join(', '),
                  ),
                  items: [
                    for (final category in filteredCategories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                  validator: (value) => value == null ? 'Pilih kategori' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Nominal',
                    helperText: 'Contoh: ${AppFormatters.currency(100000)}',
                    errorText: _fieldErrors['amount']?.join(', '),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nominal wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tanggal transaksi'),
                  subtitle: Text(AppFormatters.displayDate(_selectedDate)),
                  trailing: IconButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_month_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Catatan',
                    errorText: _fieldErrors['note']?.join(', '),
                  ),
                ),
                const SizedBox(height: 16),
                _AttachmentPickerCard(
                  previewBytes: _attachmentPreviewBytes,
                  attachmentName: _attachmentName,
                  selectedAttachment: _selectedAttachment,
                  existingAttachmentPath: _existingAttachmentPath,
                  removeExistingAttachment: _removeExistingAttachment,
                  isPicking: _isPickingAttachment,
                  errorText:
                      _attachmentError ??
                      _fieldErrors['attachment']?.join(', '),
                  onPickGallery: () => _pickAttachment(ImageSource.gallery),
                  onPickCamera: () => _pickAttachment(ImageSource.camera),
                  onClear: _clearAttachment,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _submitting
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('Simpan transaksi'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentPickerCard extends StatelessWidget {
  const _AttachmentPickerCard({
    required this.previewBytes,
    required this.attachmentName,
    required this.selectedAttachment,
    required this.existingAttachmentPath,
    required this.removeExistingAttachment,
    required this.isPicking,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onClear,
    this.errorText,
  });

  final Uint8List? previewBytes;
  final String? attachmentName;
  final TransactionAttachmentFile? selectedAttachment;
  final String? existingAttachmentPath;
  final bool removeExistingAttachment;
  final bool isPicking;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAttachment =
        selectedAttachment != null ||
        (existingAttachmentPath != null && !removeExistingAttachment);
    final existingPreviewUrl = AppConfig.resolveStorageUrl(
      existingAttachmentPath,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: scheme.surface,
        border: Border.all(
          color: errorText == null ? scheme.outlineVariant : scheme.error,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F3558).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.image_rounded, color: scheme.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lampiran gambar',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Upload JPG/PNG asli ke field attachment.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (hasAttachment)
                IconButton(
                  tooltip: 'Hapus lampiran',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: previewBytes != null
                  ? Image.memory(previewBytes!, fit: BoxFit.cover)
                  : existingPreviewUrl != null &&
                        hasAttachment &&
                        !removeExistingAttachment
                  ? Image.network(
                      existingPreviewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _AttachmentEmptyPreview(
                            hasAttachment: hasAttachment,
                            attachmentName:
                                attachmentName ?? existingAttachmentPath,
                            removed: removeExistingAttachment,
                          ),
                    )
                  : _AttachmentEmptyPreview(
                      hasAttachment: hasAttachment,
                      attachmentName: attachmentName ?? existingAttachmentPath,
                      removed: removeExistingAttachment,
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: isPicking ? null : onPickGallery,
                icon: isPicking
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_rounded),
                label: const Text('Galeri'),
              ),
              FilledButton.tonalIcon(
                onPressed: isPicking ? null : onPickCamera,
                icon: const Icon(Icons.photo_camera_rounded),
                label: const Text('Kamera'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedAttachment != null)
            Text(
              '${selectedAttachment!.filename} - ${TransactionAttachmentFile.formatSize(selectedAttachment!.sizeBytes)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            )
          else if (hasAttachment)
            Text(
              existingAttachmentPath!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Text(
              'Belum ada bukti transaksi.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttachmentEmptyPreview extends StatelessWidget {
  const _AttachmentEmptyPreview({
    required this.hasAttachment,
    required this.attachmentName,
    required this.removed,
  });

  final bool hasAttachment;
  final String? attachmentName;
  final bool removed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                removed
                    ? Icons.delete_outline_rounded
                    : hasAttachment
                    ? Icons.insert_photo_rounded
                    : Icons.add_photo_alternate_rounded,
                color: scheme.primary,
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                removed
                    ? 'Lampiran akan dihapus'
                    : hasAttachment
                    ? 'Lampiran tersimpan'
                    : 'Belum ada gambar',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (attachmentName != null && attachmentName!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  attachmentName!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
