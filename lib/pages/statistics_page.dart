import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.statisticsTitle),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            AppLocalizations.of(context)!.statisticsDescription,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
