import 'package:flutter/material.dart';
import 'history_view.dart';

void openHistory(BuildContext context, {
  required String title,
  required String fieldKey,
  required String unit,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HistoryView(title: title, fieldKey: fieldKey, unit: unit),
    ),
  );
}