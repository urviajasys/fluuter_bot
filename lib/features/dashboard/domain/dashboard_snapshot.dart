class DashboardSnapshot {
  const DashboardSnapshot({
    required this.botEnabled,
    required this.paperMode,
    required this.riskPerTrade,
    required this.dailyLossLimit,
    required this.maxOpenPositions,
    required this.openPositions,
    required this.ordersToday,
    required this.pnlToday,
    required this.strategyName,
    required this.brokerConnected,
    required this.hasTotp,
    required this.hasStaticIp,
    required this.positions,
    required this.orders,
  });

  final bool botEnabled;
  final bool paperMode;
  final double riskPerTrade;
  final double dailyLossLimit;
  final int maxOpenPositions;
  final int openPositions;
  final int ordersToday;
  final double pnlToday;
  final String strategyName;
  final bool brokerConnected;
  final bool hasTotp;
  final bool hasStaticIp;
  final List<Map<String, dynamic>> positions;
  final List<Map<String, dynamic>> orders;

  static double _toDouble(dynamic value, [double fallback = 0]) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  factory DashboardSnapshot.fromMap(Map<String, dynamic> map) {
    final summary = map['summary'] as Map<String, dynamic>? ?? const {};
    final config = map['config'] as Map<String, dynamic>? ?? const {};
    final strategy = map['strategy'] as Map<String, dynamic>? ?? const {};
    final broker = map['broker'] as Map<String, dynamic>? ?? const {};
    final positions = (map['positions'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final orders = (map['orders'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return DashboardSnapshot(
      botEnabled: config['enabled'] as bool? ?? false,
      paperMode: config['paper_mode'] as bool? ?? true,
      riskPerTrade: _toDouble(config['risk_per_trade']),
      dailyLossLimit: _toDouble(config['daily_loss_limit']),
      maxOpenPositions: _toInt(config['max_open_positions']),
      openPositions: _toInt(summary['open_positions']),
      ordersToday: _toInt(summary['orders_today']),
      pnlToday: _toDouble(summary['pnl_today']),
      strategyName: strategy['name'] as String? ?? 'Trend Momentum',
      brokerConnected: broker['connected'] as bool? ?? false,
      hasTotp: broker['has_totp'] as bool? ?? false,
      hasStaticIp: broker['has_static_ip'] as bool? ?? false,
      positions: positions,
      orders: orders,
    );
  }
}
