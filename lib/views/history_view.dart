import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
              start: _controller.start,
              end: _controller.end,
              isDefault: _controller.isDefaultRange,
              onPick: _pickRange,
              onReset: _controller.resetRange,
            ),
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
                  return _LineChart(
                    points: points,
                    unit: widget.unit,
                    start: _controller.start,
                    end: _controller.end,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final pickedDates = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: DateUtils.dateOnly(_controller.start),
        end: DateUtils.dateOnly(_controller.end),
      ),
    );
    if (pickedDates == null || !mounted) return;

    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_controller.start),
      helpText: 'Heure de début',
    );
    if (pickedStartTime == null || !mounted) return;

    final pickedEndTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_controller.end),
      helpText: 'Heure de fin',
    );
    if (pickedEndTime == null || !mounted) return;

    final start = DateTime(
      pickedDates.start.year,
      pickedDates.start.month,
      pickedDates.start.day,
      pickedStartTime.hour,
      pickedStartTime.minute,
    );
    final end = DateTime(
      pickedDates.end.year,
      pickedDates.end.month,
      pickedDates.end.day,
      pickedEndTime.hour,
      pickedEndTime.minute,
    );

    if (!end.isAfter(start) || end.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisissez une plage valide qui ne dépasse pas maintenant.'),
        ),
      );
      return;
    }
    _controller.setRange(start, end);
  }
}

// ─── Sélecteur de période ─────────────────────────────────────────────────────

class _RangeSelector extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final bool isDefault;
  final VoidCallback onPick;
  final VoidCallback onReset;

  const _RangeSelector({
    required this.start,
    required this.end,
    required this.isDefault,
    required this.onPick,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM HH:mm');
    final fullFmt = DateFormat('dd/MM/yyyy HH:mm');
    final label = isDefault
        ? 'Dernières 24 h'
      : '${fmt.format(start)} → ${fmt.format(end)}';
    final fullLabel = isDefault
        ? label
        : '${fullFmt.format(start)} → ${fullFmt.format(end)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.date_range, size: 18),
              label: Tooltip(
                message: fullLabel,
                child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
          if (!isDefault)
            IconButton(
              tooltip: 'Revenir aux dernières 24 h',
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
            ),
        ],
      ),
    );
  }
}

// ─── Graphe ───────────────────────────────────────────────────────────────────

class _LineChart extends StatelessWidget {
  final List<HistoryPoint> points;
  final String unit;
  final DateTime start;
  final DateTime end;

  const _LineChart({
    required this.points,
    required this.unit,
    required this.start,
    required this.end,
  });

  static const _hourMs = 3600 * 1000;
  static const _dayMs = 24 * _hourMs;

  // Heure locale exprimée comme un "faux UTC" pour que les ticks tombent sur des heures locales rondes.
  static int _localMs(DateTime t) {
    final l = t.toLocal();
    return l.millisecondsSinceEpoch + l.timeZoneOffset.inMilliseconds;
  }

  static int _tickInterval(Duration span) {
    final h = span.inMinutes / 60;
    if (h <= 6) return _hourMs;
    if (h <= 12) return 2 * _hourMs;
    if (h <= 30) return 4 * _hourMs;
    if (h <= 54) return 8 * _hourMs;
    if (h <= 96) return 12 * _hourMs;
    return (h / 24 / 6).ceil() * _dayMs;
  }

  @override
  Widget build(BuildContext context) {
    final base = (_localMs(start) ~/ _dayMs) * _dayMs;
    double xOf(DateTime t) => (_localMs(t) - base).toDouble();

    final spots = points.map((p) => FlSpot(xOf(p.time), p.value)).toList();

    final minY = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final padding = ((maxY - minY) * 0.15).clamp(0.5, double.infinity);

    final interval = _tickInterval(end.difference(start));

    Widget? labelX(double v) {
      // fl_chart ajoute aussi les bornes min/max, qui ne sont pas alignées
      if (v % interval != 0) return null;
      final t = DateTime.fromMillisecondsSinceEpoch((base + v).toInt(), isUtc: true);
      final isDay = interval >= _dayMs || t.hour == 0;
      final text = isDay
          ? '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}'
          : '${t.hour.toString().padLeft(2, '0')}h';
      return Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontWeight: isDay ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 24, 24),
      child: LineChart(
        LineChartData(
          minX: xOf(start),
          maxX: xOf(end),
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
                interval: interval.toDouble(),
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  child: labelX(v) ?? const SizedBox(),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                final t = points[s.spotIndex].time.toLocal();
                final time = DateFormat('dd/MM HH:mm').format(t);
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
              isCurved: false,
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