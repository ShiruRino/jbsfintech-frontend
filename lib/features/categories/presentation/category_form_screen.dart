import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_result.dart';
import '../../shared/providers.dart';
import '../domain/category.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key, this.categoryId});

  final int? categoryId;

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _type = 'expense';
  String? _icon = 'wallet';
  bool _isActive = true;
  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    Future.microtask(_prefill);
  }

  Future<void> _prefill() async {
    if (widget.categoryId == null) {
      return;
    }
    final detail = await ref.read(
      categoryDetailProvider(widget.categoryId!).future,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _nameController.text = detail.$1.name;
      _type = detail.$1.type;
      _icon = detail.$1.icon;
      _isActive = detail.$1.isActive;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    final repo = ref.read(categoriesRepositoryProvider);
    final result = await ApiResult.guard(() async {
      if (widget.categoryId == null) {
        await repo.createCategory(
          name: _nameController.text.trim(),
          type: _type,
          icon: _icon,
          isActive: _isActive,
        );
      } else {
        await repo.updateCategory(
          id: widget.categoryId!,
          name: _nameController.text.trim(),
          type: _type,
          icon: _icon,
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
        ref.invalidate(categoriesProvider);
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
        title: Text(
          widget.categoryId == null ? 'Tambah Kategori' : 'Ubah Kategori',
        ),
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
                    labelText: 'Nama kategori',
                    errorText: _fieldErrors['name']?.join(', '),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'income', label: Text('Pemasukan')),
                    ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      setState(() => _type = selection.first),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _icon,
                  decoration: const InputDecoration(labelText: 'Ikon'),
                  items: [
                    for (final entry in categoryIconLabels.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: (value) => setState(() => _icon = value),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  title: const Text('Kategori aktif'),
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
