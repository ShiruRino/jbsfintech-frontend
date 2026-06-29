import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../../shared/providers.dart';
import '../domain/transaction_item.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _debouncer = Debouncer();
  String _search = '';
  String _type = 'semua';
  int? _accountId;
  int? _categoryId;
  bool _newestFirst = true;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            onPressed: () => context.push('/categories'),
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(transactionsProvider.future),
        child: transactionsAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingCard(height: 64),
              SizedBox(height: 12),
              LoadingCard(height: 100),
              SizedBox(height: 12),
              LoadingCard(height: 100),
            ],
          ),
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.refresh(transactionsProvider),
          ),
          data: (transactions) {
            final accounts = accountsAsync.asData?.value ?? const [];
            final categories = categoriesAsync.asData?.value ?? const [];
            final filtered =
                [...transactions].where((transaction) {
                  final matchesText =
                      [
                            transaction.category?.name,
                            transaction.account?.name,
                            transaction.note,
                          ]
                          .whereType<String>()
                          .join(' ')
                          .toLowerCase()
                          .contains(_search.toLowerCase());
                  final matchesType =
                      _type == 'semua' || transaction.type == _type;
                  final matchesAccount =
                      _accountId == null ||
                      transaction.account?.id == _accountId;
                  final matchesCategory =
                      _categoryId == null ||
                      transaction.category?.id == _categoryId;
                  return matchesText &&
                      matchesType &&
                      matchesAccount &&
                      matchesCategory;
                }).toList()..sort((a, b) {
                  final first = a.transactionDate ?? DateTime(2000);
                  final second = b.transactionDate ?? DateTime(2000);
                  return _newestFirst
                      ? second.compareTo(first)
                      : first.compareTo(second);
                });

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari transaksi',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => _debouncer(() {
                    if (mounted) {
                      setState(() => _search = value);
                    }
                  }),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in ['semua', 'income', 'expense'])
                      ChoiceChip(
                        label: Text(switch (type) {
                          'income' => 'Pemasukan',
                          'expense' => 'Pengeluaran',
                          _ => 'Semua',
                        }),
                        selected: _type == type,
                        onSelected: (_) => setState(() => _type = type),
                      ),
                    ChoiceChip(
                      label: Text(_newestFirst ? 'Terbaru' : 'Terlama'),
                      selected: true,
                      onSelected: (_) =>
                          setState(() => _newestFirst = !_newestFirst),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _accountId,
                        decoration: const InputDecoration(labelText: 'Akun'),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Semua akun'),
                          ),
                          for (final account in accounts)
                            DropdownMenuItem<int?>(
                              value: account.id,
                              child: Text(account.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _accountId = value),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Semua kategori'),
                          ),
                          for (final category in categories)
                            DropdownMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _categoryId = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const EmptyStateView(
                    title: 'Transaksi kosong',
                    message:
                        'Tambahkan transaksi pertama Anda dari tombol Catat.',
                  )
                else
                  ..._groupTransactionsByDate(context, filtered),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _groupTransactionsByDate(
    BuildContext context,
    List<TransactionItem> items,
  ) {
    final Map<String, List<TransactionItem>> grouped = {};
    for (final item in items) {
      final key = item.transactionDate == null
          ? 'Tanpa Tanggal'
          : _dateGroupLabel(item.transactionDate!);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return [
      for (final entry in grouped.entries) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            entry.key,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        for (final item in entry.value) _TransactionTile(item: item),
        const SizedBox(height: 8),
      ],
    ];
  }

  String _dateGroupLabel(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(value.year, value.month, value.day);
    final difference = today.difference(date).inDays;

    return switch (difference) {
      0 => 'Hari Ini',
      1 => 'Kemarin',
      _ => AppFormatters.displayDate(value),
    };
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final TransactionItem item;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final isIncome = item.type == 'income';

    return Card(
      child: ListTile(
        onTap: () => context.push('/transactions/${item.id}'),
        leading: CircleAvatar(
          backgroundColor: (isIncome ? palette.success : palette.danger)
              .withValues(alpha: 0.15),
          child: Icon(
            isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: isIncome ? palette.success : palette.danger,
          ),
        ),
        title: Text(item.category?.name ?? 'Tanpa kategori'),
        subtitle: Text(
          [
            item.account?.name,
            item.note,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' | '),
        ),
        trailing: Text(
          AppFormatters.compactCurrency(isIncome ? item.amount : -item.amount),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isIncome ? palette.success : palette.danger,
          ),
        ),
      ),
    );
  }
}
