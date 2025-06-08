import 'package:flutter/material.dart';

class Frequency {
  final String code;
  const Frequency(this.code);

  static const Frequency daily = Frequency('daily');
  static const Frequency weekly = Frequency('weekly');
  static const Frequency monthly = Frequency('monthly');
  static const Frequency defaultValue = Frequency('daily');

  static Frequency fromString(String value) {
    // Replace with your actual logic to parse the string and return a Frequency instance
    switch (value) {
      case 'daily':
        return Frequency.daily;
      case 'weekly':
        return Frequency.weekly;
      case 'monthly':
        return Frequency.monthly;
      default:
        return Frequency.defaultValue; // Replace with your default value
    }
  }
}

final ValueNotifier<Frequency> frequencyNotifier = ValueNotifier(
  const Frequency('daily'),
);
