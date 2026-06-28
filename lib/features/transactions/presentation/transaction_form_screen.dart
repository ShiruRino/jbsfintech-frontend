import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/providers.dart';

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
  final _attachmentController = TextEditingController();

  String _type = 'expense';
  int? _accountId;
  int? _categoryId;
  DateTime _selectedDate = DateTime.now();
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
      _attachmentController.text = transaction.attachmentPath ?? '';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
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
          attachmentPath: _attachmentController.text.trim().isEmpty
              ? null
              : _attachmentController.text.trim(),
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
          attachmentPath: _attachmentController.text.trim().isEmpty
              ? null
              : _attachmentController.text.trim(),
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
                TextFormField(
                  controller: _attachmentController,
                  decoration: InputDecoration(
                    labelText: 'Attachment path',
                    helperText:
                        'Opsional. Hanya metadata/path, tanpa upload file.',
                    errorText: _fieldErrors['attachment_path']?.join(', '),
                  ),
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
