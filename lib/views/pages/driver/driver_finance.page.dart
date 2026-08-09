import 'package:chaskiy/constants/app_colors.dart';
import 'package:chaskiy/requests/driver_finance.request.dart';
import 'package:flutter/material.dart';
import 'package:chaskiy/views/pages/driver/driver_payment_accounts.page.dart';

class DriverFinancePage extends StatefulWidget {
  const DriverFinancePage({super.key});

  @override
  State<DriverFinancePage> createState() => _DriverFinancePageState();
}

class _DriverFinancePageState extends State<DriverFinancePage> {
  final DriverFinanceRequest _request = DriverFinanceRequest();
  late DateTime _start = DateTime.now().subtract(const Duration(days: 7));
  late DateTime _end = DateTime.now();
  Map<String, dynamic> _metrics = const {};
  List<Map<String, dynamic>> _earnings = const [];
  List<Map<String, dynamic>> _payouts = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _request.metrics(),
        _request.earnings(start: _start, end: _end),
        _request.payouts(start: _start, end: _end),
      ]);
      if (!mounted) return;
      setState(() {
        _metrics = results[0] as Map<String, dynamic>;
        _earnings = results[1] as List<Map<String, dynamic>>;
        _payouts = results[2] as List<Map<String, dynamic>>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (range == null) return;
    _start = range.start;
    _end = range.end;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$_error', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Finanzas',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Cuentas de pago',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DriverPaymentAccountsPage(),
                      ),
                    ),
                    icon: const Icon(Icons.account_balance_outlined),
                  ),
                  IconButton(
                    tooltip: 'Filtrar por fecha',
                    onPressed: _selectRange,
                    icon: const Icon(Icons.date_range_outlined),
                  ),
                ],
              ),
            ),
            _Metrics(metrics: _metrics),
            const TabBar(tabs: [Tab(text: 'Ganancias'), Tab(text: 'Pagos')]),
            Expanded(
              child: TabBarView(
                children: [
                  _ReportList(data: _earnings, type: _ReportType.earning),
                  _ReportList(data: _payouts, type: _ReportType.payout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.metrics});
  final Map<String, dynamic> metrics;

  @override
  Widget build(BuildContext context) {
    final cards = _cards();
    if (cards.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 126,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Container(
            width: 174,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  maxLines: 1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  card.lines.join('\n'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<_MetricCardData> _cards() {
    final cards = <_MetricCardData>[];
    final earnings = _map(metrics['earnings']);
    final orders = _map(metrics['orders']);
    final money = _map(metrics['money']);

    if (earnings.isNotEmpty) {
      cards.add(_MetricCardData('Ganancias', [
        'Actual: ${_amount(earnings['current'])}',
        'Hoy: ${_amount(earnings['today'])}',
      ]));
    }
    if (orders.isNotEmpty) {
      cards.add(_MetricCardData('Pedidos', [
        'Hoy: ${_number(orders['today'])}',
        'Semana: ${_number(orders['week'])}',
      ]));
    }
    if (money.isNotEmpty) {
      cards.add(_MetricCardData('Dinero', [
        'Por remitir: ${_amount(money['pending_remittance'])}',
        if (money.containsKey('remitted'))
          'Remitido: ${_amount(money['remitted'])}',
      ]));
    }

    // Mantiene compatibilidad si el backend incorpora una métrica escalar.
    if (cards.isEmpty) {
      for (final entry in metrics.entries.take(3)) {
        if (entry.value is num || entry.value is String) {
          cards.add(_MetricCardData(
            _label(entry.key),
            [_number(entry.value)],
          ));
        }
      }
    }
    return cards;
  }

  Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  String _number(dynamic value) {
    final number = num.tryParse('${value ?? 0}') ?? 0;
    return number == number.roundToDouble()
        ? number.toInt().toString()
        : number.toStringAsFixed(2);
  }

  String _amount(dynamic value) => _number(value);

  String _label(String value) {
    const labels = {
      'earnings': 'Ganancias',
      'orders': 'Pedidos',
      'money': 'Dinero',
      'pending_remittance': 'Por remitir',
    };
    return labels[value] ?? value.replaceAll('_', ' ');
  }
}

class _MetricCardData {
  const _MetricCardData(this.title, this.lines);
  final String title;
  final List<String> lines;
}

enum _ReportType { earning, payout }

class _ReportList extends StatelessWidget {
  const _ReportList({required this.data, required this.type});
  final List<Map<String, dynamic>> data;
  final _ReportType type;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('No existen movimientos'));
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: data.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = data[index];
        final amount = type == _ReportType.earning
            ? item['total_earning'] ?? item['amount']
            : item['amount'];
        final status = item['status'];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            type == _ReportType.earning
                ? Icons.trending_up
                : Icons.payments_outlined,
          ),
          title: Text('${item['date'] ?? item['formatted_date'] ?? ''}'),
          subtitle: status == null ? null : Text('$status'),
          trailing: Text(
            '${amount ?? '0.00'}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}
