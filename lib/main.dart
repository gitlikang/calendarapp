import 'package:calendarapp/screens/calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calendarapp/screens/sputil.dart' show SpUtils;

void main() {
  initializeDateFormatting()
      .then((_) => {runApp(const MainApp()), loadAsync()});
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Calendar(),
      ),
    );
  }
}

void loadAsync() async {
  await SpUtils.getInstance();
}
