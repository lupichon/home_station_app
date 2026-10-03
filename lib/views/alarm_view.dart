import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/alarm_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/section_label.dart';

class AlarmView extends StatefulWidget {
  const AlarmView({super.key});

  @override
  State<AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends State<AlarmView> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final existing = context.read<AlarmController>().alarmTarget;
    final base = existing ?? DateTime.now().add(const Duration(minutes: 5));
    _selectedDate = DateTime(base.year, base.month, base.day);
    _selectedTime = TimeOfDay.fromDateTime(base);
  }

  DateTime get _selectedDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _confirm() async {
    final controller = context.read<AlarmController>();
    final target = _selectedDateTime;

    try {
      await controller.setAlarm(target);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réveil réglé pour ${DateFormat('dd/MM à HH:mm').format(target)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _cancel() async {
    final controller = context.read<AlarmController>();
    try {
      await controller.cancelAlarm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réveil annulé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AlarmController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Réveil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (!controller.supportsAlarm)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Connecte-toi en Bluetooth pour régler le réveil.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          const SizedBox(height: 20),

          const AppSectionLabel('État actuel'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  controller.isAlarmArmed ? Icons.alarm_on : Icons.alarm_off,
                  color: controller.isAlarmArmed ? AppColors.green : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.isAlarmArmed
                        ? 'Armé pour le ${DateFormat('dd/MM à HH:mm').format(controller.alarmTarget!)}'
                        : 'Aucun réveil programmé',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const AppSectionLabel('Programmer un réveil'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ListTile(
                  tileColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: const Text('Heure'),
                  subtitle: Text(_selectedTime.format(context)),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.supportsAlarm ? _confirm : null,
            child: const Text('Armer le réveil'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: (controller.supportsAlarm && controller.isAlarmArmed) ? _cancel : null,
            child: const Text('Annuler le réveil'),
          ),
        ],
      ),
    );
  }
}