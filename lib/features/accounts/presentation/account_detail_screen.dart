import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../../shared/providers.dart';

class AccountDetailScreen extends ConsumerWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final int accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(accountDetailProvider(accountId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Akun'),
        actions: [
          IconButton(
            onPressed: () => context.push('/accounts/$accountId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            LoadingCard(height: 180),
            SizedBox(height: 12),
            LoadingCard(height: 120),
          ],
        ),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.refresh(accountDetailProvider(accountId)),
        ),
        data: (detail) {
          final account = detail.$1;
          final transactions = detail.$2;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Saldo saat ini',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppFormatters.currency(account.balance),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Chip(label: Text('Tipe ${account.type}')),
                          Chip(
                            label: Text(
                              account.isActive ? 'Aktif' : 'Nonaktif',
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Awal ${AppFormatters.currency(account.initialBalance)}',
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Masuk ${AppFormatters.currency(account.totalIncome)}',
                            ),
                          ),
                          Chip(
                            label: Text(
                              'Keluar ${AppFormatters.currency(account.totalExpense)}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus akun?'),
                      content: const Text(
                        'Akun dan transaksi terkait akan terhapus permanen.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (shouldDelete == true && context.mounted) {
                    await ref
                        .read(accountsRepositoryProvider)
                        .deleteAccount(accountId);
                    ref.invalidate(accountsProvider);
                    ref.invalidate(dashboardProvider);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus akun'),
              ),
              const SizedBox(height: 20),
              Text(
                'Transaksi Terbaru',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (transactions.isEmpty)
                const EmptyStateView(
                  title: 'Belum ada transaksi',
                  message: 'Transaksi terbaru akan muncul di sini.',
                )
              else
                for (final transaction in transactions)
                  Card(
                    child: ListTile(
                      title: Text(
                        transaction.category?.name ?? 'Tanpa kategori',
                      ),
                      subtitle: Text(
                        transaction.transactionDate == null
                            ? '-'
                            : AppFormatters.displayDate(
                                transaction.transactionDate!,
                              ),
                      ),
                      trailing: Text(
                        AppFormatters.currency(transaction.amount),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
