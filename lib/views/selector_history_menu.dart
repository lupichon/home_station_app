import 'package:flutter/material.dart';
import 'history_view.dart';

void openSelectorMenu(
  BuildContext context, {
  required String title,
  required List<({String title, String fieldKey, String unit})> fields,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          ...fields.map((f) => _MenuItem(
                title: f.title,
                fieldKey: f.fieldKey,
                unit: ' ${f.unit}',
              )),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final String title;
  final String fieldKey;
  final String unit;

  const _MenuItem({
    required this.title,
    required this.fieldKey,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.show_chart),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryView(
              title: title,
              fieldKey: fieldKey,
              unit: unit,
            ),
          ),
        );
      },
    );
  }
}