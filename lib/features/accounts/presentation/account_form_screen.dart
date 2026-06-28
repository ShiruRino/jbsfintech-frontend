import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../../core/utils/formatters.dart';
import '../../shared/providers.dart';

class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.accountId});

  final int? accountId;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _type = 'cash';
  bool _isActive = true;
  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_prefill);
  }

  Future<void> _prefill() async {
    if (widget.accountId == null) {
      return;
    }
    final detail = await ref.read(
      accountDetailProvider(widget.accountId!).future,
    );
    final account = detail.$1;
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text = account.name;
      _balanceController.text = account.initialBalance.toString();
      _type = account.type;
      _isActive = account.isActive;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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

    final amount =
        int.tryParse(_balanceController.text.replaceAll('.', '')) ?? 0;
    final repo = ref.read(accountsRepositoryProvider);
    final result = await ApiResult.guard(() async {
      if (widget.accountId == null) {
        await repo.createAccount(
          name: _nameController.text.trim(),
          type: _type,
          initialBalance: amount,
          isActive: _isActive,
        );
      } else {
        await repo.updateAccount(
          id: widget.accountId!,
          name: _nameController.text.trim(),
          type: _type,
          initialBalance: amount,
          isActive: _isActive,
        );
      }
    });

    if (!mounted) {
      return;
    }

    setState(() => _submitting = false);

    switch (result) {
      case ApiSuccess<void>():
        ref.invalidate(accountsProvider);
        ref.invalidate(dashboardProvider);
        if (widget.accountId != null) {
          ref.invalidate(accountDetailProvider(widget.accountId!));
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accountId == null ? 'Tambah Akun' : 'Ubah Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama akun',
                    errorText: _fieldErrors['name']?.join(', '),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(labelText: 'Tipe'),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'bank', child: Text('Bank')),
                    DropdownMenuItem(value: 'ewallet', child: Text('E-Wallet')),
                  ],
                  onChanged: (value) => setState(() => _type = value ?? 'cash'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Saldo awal',
                    helperText: 'Contoh: ${AppFormatters.currency(250000)}',
                    errorText: _fieldErrors['initial_balance']?.join(', '),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Saldo awal wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Akun aktif'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
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
                          : const Text('Simpan'),
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
