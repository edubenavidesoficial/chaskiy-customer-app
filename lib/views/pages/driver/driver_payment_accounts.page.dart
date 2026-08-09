import 'package:chaskiy/models/driver_payment_account.dart';
import 'package:chaskiy/requests/driver_finance.request.dart';
import 'package:flutter/material.dart';

class DriverPaymentAccountsPage extends StatefulWidget {
  const DriverPaymentAccountsPage({super.key});

  @override
  State<DriverPaymentAccountsPage> createState() =>
      _DriverPaymentAccountsPageState();
}

class _DriverPaymentAccountsPageState
    extends State<DriverPaymentAccountsPage> {
  final DriverFinanceRequest _request = DriverFinanceRequest();
  List<DriverPaymentAccount> _accounts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final accounts = await _request.paymentAccounts();
      if (mounted) setState(() => _accounts = accounts);
    } catch (error) {
      _message(error, error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([DriverPaymentAccount? account]) async {
    final name = TextEditingController(text: account?.name);
    final number = TextEditingController(text: account?.number);
    final instructions = TextEditingController(text: account?.instructions);
    var active = account?.isActive ?? true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(account == null ? 'Nueva cuenta' : 'Editar cuenta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: number,
                  decoration: const InputDecoration(labelText: 'Número'),
                ),
                TextField(
                  controller: instructions,
                  decoration: const InputDecoration(labelText: 'Instrucciones'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: active,
                  title: const Text('Activa'),
                  onChanged: (value) => setDialogState(() => active = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty || number.text.trim().isEmpty) {
                  return;
                }
                try {
                  await _request.savePaymentAccount(
                    id: account?.id,
                    name: name.text.trim(),
                    number: number.text.trim(),
                    instructions: instructions.text.trim(),
                    isActive: active,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$error')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _payout() async {
    final active = _accounts.where((account) => account.isActive).toList();
    if (active.isEmpty) {
      _message('Agrega una cuenta de pago activa.', error: true);
      return;
    }
    final balance = await _request.availableEarning();
    if (!mounted) return;
    final amount = TextEditingController();
    DriverPaymentAccount selected = active.first;
    final requested = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Solicitar retiro'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Disponible: $balance'),
              DropdownButtonFormField<DriverPaymentAccount>(
                initialValue: selected,
                items: active
                    .map((account) => DropdownMenuItem(
                          value: account,
                          child: Text('${account.name} · ${account.number}'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => selected = value);
                },
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final value = double.tryParse(amount.text) ?? 0;
                if (value <= 0 || value > balance) return;
                await _request.requestPayout(
                  amount: value,
                  paymentAccountId: selected.id,
                );
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Solicitar'),
            ),
          ],
        ),
      ),
    );
    if (requested == true) _message('Solicitud enviada correctamente');
  }

  void _message(Object value, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$value'),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Cuentas de pago'),
          actions: [
            IconButton(onPressed: _payout, icon: const Icon(Icons.payments)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _edit,
          icon: const Icon(Icons.add),
          label: const Text('Agregar'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: _accounts.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final account = _accounts[index];
                    return ListTile(
                      onTap: () => _edit(account),
                      leading: const Icon(Icons.account_balance_outlined),
                      title: Text(account.name),
                      subtitle: Text(account.number),
                      trailing: Icon(
                        account.isActive ? Icons.check_circle : Icons.pause_circle,
                        color: account.isActive ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
              ),
      );
}
