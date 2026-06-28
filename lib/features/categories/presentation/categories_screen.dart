import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/debouncer.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../../shared/providers.dart';
import 'category_icon_registry.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _debouncer = Debouncer();
  String _query = '';
  String _filterType = 'semua';

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori'),
        actions: [
          IconButton(
            onPressed: () => context.push('/categories/new'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(categoriesProvider.future),
        child: categoriesAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingCard(height: 60),
              SizedBox(height: 12),
              LoadingCard(height: 96),
              SizedBox(height: 12),
              LoadingCard(height: 96),
            ],
          ),
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.refresh(categoriesProvider),
          ),
          data: (categories) {
            final filtered = categories.where((category) {
              final matchesText = category.name.toLowerCase().contains(
                _query.toLowerCase(),
              );
              final matchesType =
                  _filterType == 'semua' || category.type == _filterType;
              return matchesText && matchesType;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari kategori',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => _debouncer(() {
                    if (mounted) {
                      setState(() => _query = value);
                    }
                  }),
                ),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'semua', label: Text('Semua')),
                    ButtonSegment(value: 'income', label: Text('Pemasukan')),
                    ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                  ],
                  selected: {_filterType},
                  onSelectionChanged: (selection) {
                    setState(() => _filterType = selection.first);
                  },
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const EmptyStateView(
                    title: 'Kategori tidak ada',
                    message:
                        'Tambahkan kategori untuk mengelompokkan transaksi.',
                  )
                else
                  for (final category in filtered)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.12),
                          child: Icon(
                            categoryIconOptionFor(category.icon).icon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(category.name),
                        subtitle: Text(
                          '${category.type == 'income' ? 'Pemasukan' : 'Pengeluaran'} - ${category.isActive ? 'Aktif' : 'Nonaktif'}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              context.push('/categories/${category.id}/edit');
                              return;
                            }

                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus kategori?'),
                                content: const Text(
                                  'Transaksi terkait bisa ikut terpengaruh sesuai perilaku backend.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (shouldDelete == true) {
                              await ref
                                  .read(categoriesRepositoryProvider)
                                  .deleteCategory(category.id);
                              ref.invalidate(categoriesProvider);
                              ref.invalidate(transactionsProvider);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Ubah')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
