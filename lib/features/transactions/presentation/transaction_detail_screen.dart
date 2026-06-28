import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../../shared/providers.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(
      transactionDetailProvider(transactionId),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            onPressed: () => context.push('/transactions/$transactionId/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: transactionAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [LoadingCard(height: 260)],
        ),
        error: (error, _) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.refresh(transactionDetailProvider(transactionId)),
        ),
        data: (transaction) {
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
                        AppFormatters.currency(transaction.amount),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 14),
                      _DetailRow(label: 'Tipe', value: transaction.type),
                      _DetailRow(
                        label: 'Akun',
                        value: transaction.account?.name ?? '-',
                      ),
                      _DetailRow(
                        label: 'Kategori',
                        value: transaction.category?.name ?? '-',
                      ),
                      _DetailRow(
                        label: 'Tanggal',
                        value: transaction.transactionDate == null
                            ? '-'
                            : AppFormatters.displayDate(
                                transaction.transactionDate!,
                              ),
                      ),
                      _DetailRow(
                        label: 'Catatan',
                        value: transaction.note ?? '-',
                      ),
                      _DetailRow(
                        label: 'Lampiran',
                        value: transaction.attachmentPath ?? '-',
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
                      title: const Text('Hapus transaksi?'),
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
                  if (shouldDelete == true) {
                    await ref
                        .read(transactionsRepositoryProvider)
                        .deleteTransaction(transactionId);
                    ref.invalidate(transactionsProvider);
                    ref.invalidate(dashboardProvider);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus transaksi'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
