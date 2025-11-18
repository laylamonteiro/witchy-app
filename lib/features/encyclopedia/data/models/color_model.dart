import 'package:flutter/material.dart';

class ColorModel {
  final String name;
  final Color color;
  final String meaning;
  final List<String> intentions;
  final List<String> usageTips;

  const ColorModel({
    required this.name,
    required this.color,
    required this.meaning,
    required this.intentions,
    required this.usageTips,
  });
}
