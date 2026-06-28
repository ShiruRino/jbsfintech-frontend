import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/debouncer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../domain/account.dart';
import '../../shared/providers.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final _debouncer = Debouncer();
  String _search = '';
  String _selectedType = 'semua';
  bool? _activeFilter;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun'),
        actions: [
          IconButton(
            onPressed: () => context.push('/accounts/new'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(accountsProvider.future),
        child: accountsAsync.when(
          loading: () => ListView(
            padding: const EdgeInsets.all(20),
            children: const [
              LoadingCard(height: 64),
              SizedBox(height: 12),
              LoadingCard(height: 120),
              SizedBox(height: 12),
              LoadingCard(height: 120),
            ],
          ),
          error: (error, _) => ErrorStateView(
            message: error.toString(),
            onRetry: () => ref.refresh(accountsProvider),
          ),
          data: (accounts) {
            final filtered = accounts.where((account) {
              final matchesSearch = account.name.toLowerCase().contains(
                _search.toLowerCase(),
              );
              final matchesType =
                  _selectedType == 'semua' || account.type == _selectedType;
              final matchesActive =
                  _activeFilter == null || account.isActive == _activeFilter;
              return matchesSearch && matchesType && matchesActive;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari akun',
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
                    for (final type in ['semua', 'cash', 'bank', 'ewallet'])
                      ChoiceChip(
                        label: Text(type == 'semua' ? 'Semua' : type),
                        selected: _selectedType == type,
                        onSelected: (_) => setState(() => _selectedType = type),
                      ),
                    ChoiceChip(
                      label: const Text('Aktif'),
                      selected: _activeFilter == true,
                      onSelected: (_) => setState(
                        () =>
                            _activeFilter = _activeFilter == true ? null : true,
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Nonaktif'),
                      selected: _activeFilter == false,
                      onSelected: (_) => setState(
                        () => _activeFilter = _activeFilter == false
                            ? null
                            : false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (filtered.isEmpty)
                  const EmptyStateView(
                    title: 'Akun tidak ditemukan',
                    message: 'Coba ubah kata kunci atau tambahkan akun baru.',
                  )
                else
                  for (final account in filtered)
                    _AccountCard(account: account),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push('/accounts/${account.id}'),
        title: Text(account.name),
        subtitle: Text(
          '${account.type.toUpperCase()} • ${account.isActive ? 'Aktif' : 'Nonaktif'}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatters.currency(account.balance),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Awal ${AppFormatters.currency(account.initialBalance)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
