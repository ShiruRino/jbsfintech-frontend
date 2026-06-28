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
                      _AttachmentDetail(path: transaction.attachmentPath),
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

class _AttachmentDetail extends StatelessWidget {
  const _AttachmentDetail({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.trim().isEmpty) {
      return const _DetailRow(label: 'Lampiran', value: '-');
    }

    final isNetworkImage =
        path!.startsWith('http://') || path!.startsWith('https://');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lampiran', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          if (isNetworkImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  path!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _AttachmentPathPill(path: path!),
                ),
              ),
            )
          else
            _AttachmentPathPill(path: path!),
        ],
      ),
    );
  }
}

class _AttachmentPathPill extends StatelessWidget {
  const _AttachmentPathPill({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.secondary.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Icon(Icons.image_rounded, color: scheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
