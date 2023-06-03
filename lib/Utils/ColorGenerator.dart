import 'package:flutter/material.dart';

class ColorGenerator
{
  static MaterialColor createMaterialColor(Color color) 
  {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) 
    {
      strengths.add(0.1 * i);
    }

    for (int i = 0; i < strengths.length; i++)
    {
      final double ds = 0.5 - strengths[i];
      swatch[(strengths[i] * 1000).round()] = Color.fromRGBO
      (
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }
}