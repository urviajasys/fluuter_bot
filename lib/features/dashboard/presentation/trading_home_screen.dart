import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/dashboard_repository.dart';
import '../domain/dashboard_snapshot.dart';

class TradingHomeScreen extends StatefulWidget {
  const TradingHomeScreen({super.key});

  @override
  State<TradingHomeScreen> createState() => _TradingHomeScreenState();
}

class _TradingHomeScreenState extends State<TradingHomeScreen> {
  final _repository = DashboardRepository();
  late Future<DashboardSnapshot> _dashboardFuture;

  final _capitalController = TextEditingController(text: '100000');
  final _dailyLossController = TextEditingController(text: '300');
  final _riskController = TextEditingController(text: '100');
  final _clientCodeController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _mpinController = TextEditingController();
  final _totpController = TextEditingController();
  final _staticIpController = TextEditingController();
  final _symbolController = TextEditingController(text: 'RELIANCE');
  bool _botEnabled = false;
  String? _brokerStatus;
  String? _cycleStatus;
  String? _signalStatus;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _repository.fetchDashboard();
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _repository.fetchDashboard();
    });
  }

  Future<void> _saveRisk() async {
    await _repository.updateRisk({
      'capital': double.tryParse(_capitalController.text) ?? 100000,
      'daily_loss_limit': double.tryParse(_dailyLossController.text) ?? 300,
      'risk_per_trade': double.tryParse(_riskController.text) ?? 100,
      'max_open_positions': 3,
      'paper_mode': false,
    });
    await _refresh();
  }

  Future<void> _saveBroker() async {
    await _repository.saveBrokerCredentials({
      'broker': 'angel_one',
      'client_code': _clientCodeController.text.trim(),
      'api_key': _apiKeyController.text.trim(),
      'mpin': _mpinController.text.trim(),
      'totp_secret': _totpController.text.trim(),
      'primary_static_ip': _staticIpController.text.trim(),
    });
    await _refresh();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Broker credentials saved')),
      );
    }
  }

  Future<void> _testBroker() async {
    final result = await _repository.testBrokerSession();
    setState(() {
      _brokerStatus = result['configured'] == true
          ? 'Broker config looks ready'
          : 'Broker config incomplete';
    });
  }

  Future<void> _runCycle() async {
    final result = await _repository.runBotCycle();
    setState(() {
      _cycleStatus = '${result['status']} | scanned: ${result['signals_scanned'] ?? 0}';
    });
    await _refresh();
  }

  Future<void> _testSignal() async {
    final result = await _repository.evaluateSignal({
      'symbol': _symbolController.text.trim(),
      'ltp': 1250,
      'ema_fast': 1248,
      'ema_slow': 1240,
      'vwap': 1244,
      'atr': 8,
      'volume': 250000,
      'avg_volume': 100000,
      'breakout_high': 1249,
    });
    setState(() {
      _signalStatus = 'Signal: ${result['signal']}';
    });
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _dailyLossController.dispose();
    _riskController.dispose();
    _clientCodeController.dispose();
    _apiKeyController.dispose();
    _mpinController.dispose();
    _totpController.dispose();
    _staticIpController.dispose();
    _symbolController.dispose();
    super.dispose();
  }

  Future<void> _toggleBot(bool enabled) async {
    await _repository.toggleBot(enabled);
    setState(() {
      _botEnabled = enabled;
    });
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Angel One Algo Bot'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<DashboardSnapshot>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          _botEnabled = data.botEnabled;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusCard(
                botEnabled: data.botEnabled,
                brokerConnected: data.brokerConnected,
                hasTotp: data.hasTotp,
                hasStaticIp: data.hasStaticIp,
                strategyName: data.strategyName,
                pnlToday: money.format(data.pnlToday),
                openPositions: data.openPositions,
                ordersToday: data.ordersToday,
                onChanged: _toggleBot,
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Risk Engine',
                child: Column(
                  children: [
                    TextField(
                      controller: _capitalController,
                      decoration: const InputDecoration(labelText: 'Capital'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _riskController,
                      decoration: const InputDecoration(labelText: 'Risk Per Trade'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _dailyLossController,
                      decoration: const InputDecoration(labelText: 'Daily Loss Limit'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _saveRisk,
                      child: const Text('Save Risk Limits'),
                    ),
                    const SizedBox(height: 8),
                    const Text('Risk per trade is capped at Rs 100.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Broker Credentials',
                child: Column(
                  children: [
                    TextField(
                      controller: _clientCodeController,
                      decoration: const InputDecoration(labelText: 'Angel Client Code'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(labelText: 'SmartAPI Key'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _mpinController,
                      decoration: const InputDecoration(labelText: 'MPIN'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _totpController,
                      decoration: const InputDecoration(labelText: 'TOTP Secret'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _staticIpController,
                      decoration: const InputDecoration(labelText: 'Primary Static IP'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _saveBroker,
                            child: const Text('Save Broker'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _testBroker,
                            child: const Text('Test Broker'),
                          ),
                        ),
                      ],
                    ),
                    if (_brokerStatus != null) ...[
                      const SizedBox(height: 8),
                      Text(_brokerStatus!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Bot Actions',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: _runCycle,
                            child: const Text('Run Bot Cycle'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _testSignal,
                            child: const Text('Test Signal'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _symbolController,
                      decoration: const InputDecoration(labelText: 'Signal Test Symbol'),
                    ),
                    if (_cycleStatus != null) ...[
                      const SizedBox(height: 8),
                      Text(_cycleStatus!),
                    ],
                    if (_signalStatus != null) ...[
                      const SizedBox(height: 8),
                      Text(_signalStatus!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Live Logic',
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entry: EMA20 > EMA50, price above VWAP, breakout with volume confirmation.'),
                    SizedBox(height: 8),
                    Text('Risk: ATR stop loss, trailing stop, daily kill switch, max positions cap.'),
                    SizedBox(height: 8),
                    Text('Execution: Live orders only when broker session is active and RMS checks pass.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Recent Orders',
                child: Column(
                  children: data.orders.isEmpty
                      ? const [Text('No recent orders yet')]
                      : data.orders
                          .map(
                            (order) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${order['symbol']} • ${order['side']}'),
                              subtitle: Text('Status: ${order['status']}'),
                              trailing: Text('Qty ${order['quantity']}'),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Open Positions',
                child: Column(
                  children: data.positions.isEmpty
                      ? const [Text('No open positions yet')]
                      : data.positions
                          .map(
                            (position) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text('${position['symbol']} • ${position['side']}'),
                              subtitle: Text('Avg: ${position['average_price']} | LTP: ${position['ltp']}'),
                              trailing: Text('Qty ${position['quantity']}'),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.botEnabled,
    required this.brokerConnected,
    required this.hasTotp,
    required this.hasStaticIp,
    required this.strategyName,
    required this.pnlToday,
    required this.openPositions,
    required this.ordersToday,
    required this.onChanged,
  });

  final bool botEnabled;
  final bool brokerConnected;
  final bool hasTotp;
  final bool hasStaticIp;
  final String strategyName;
  final String pnlToday;
  final int openPositions;
  final int ordersToday;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    strategyName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Switch(
                  value: botEnabled,
                  onChanged: onChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Broker: ${brokerConnected ? 'Connected' : 'Needs session'}'),
            Text('TOTP: ${hasTotp ? 'Saved' : 'Missing'}'),
            Text('Static IP: ${hasStaticIp ? 'Saved' : 'Missing'}'),
            Text('P&L Today: $pnlToday'),
            Text('Open Positions: $openPositions'),
            Text('Orders Today: $ordersToday'),
            const SizedBox(height: 8),
            const Text('Profit is never guaranteed. Bot uses capped-risk logic.'),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
