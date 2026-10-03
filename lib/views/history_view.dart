import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/history_controller.dart';
import '../models/history_model.dart';
import 'theme/app_theme.dart';

class HistoryView extends StatefulWidget {
  final String title;
  final String fieldKey;
  final String unit;

  const HistoryView({
    super.key,
    required this.title,
    required this.fieldKey,
    required this.unit,
  });

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  late final HistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController(fieldKey: widget.fieldKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => Column(
          children: [
            _RangeSelector(
                current: _controller.lookback, onChanged: _controller.setLookback),
            Expanded(
              child: FutureBuilder<List<HistoryPoint>>(
                future: _controller.points,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text('Erreur : ${snap.error}'));
                  }
                  final points = snap.data!;
                  if (points.isEmpty) {
                    return const Center(child: Text('Aucune donnée sur cette période.'));
                  }
                  return _LineChart(points: points, unit: widget.unit);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sélecteur de période ─────────────────────────────────────────────────────

class _RangeSelector extends StatelessWidget {
  final Duration current;
  final ValueChanged<Duration> onChanged;

  const _RangeSelector({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = {
      '24h': const Duration(days: 1),
      '7j':  const Duration(days: 7),
      '30j': const Duration(days: 30),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.entries.map((e) {
          final selected = current == e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(e.key),
              selected: selected,
              onSelected: (_) => onChanged(e.value),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Graphe ───────────────────────────────────────────────────────────────────

class _LineChart extends StatelessWidget {
  final List<HistoryPoint> points;
  final String unit;

  const _LineChart({required this.points, required this.unit});

  @override
  Widget build(BuildContext context) {
    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.15).clamp(0.5, double.infinity);

    // Pour les labels X : on affiche l'heure locale
    String labelX(int index) {
      final t = points[index].time.toLocal();
      return '${t.hour.toString().padLeft(2, '0')}h';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 24, 24),
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white12,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (v, _) => Text(
                  '${v.toStringAsFixed(1)}$unit',
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (points.length / 6).ceilToDouble(),
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= points.length) return const SizedBox();
                  return Text(
                    labelX(i),
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final t = points[s.x.toInt()].time.toLocal();
                final time = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                return LineTooltipItem(
                  '$time\n${s.y.toStringAsFixed(1)}$unit',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.green,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}