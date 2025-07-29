import 'package:flutter/material.dart';
import '../models/workout_models.dart';

class NeonColors {
  // Define a palette of neon colors
  static const List<Color> neonPalette = [
    Color(0xFF00FFFF), // Cyan
    Color(0xFFFF0080), // Hot Pink
    Color(0xFF00FF00), // Lime Green
    Color(0xFFFF4000), // Orange Red
    Color(0xFF8000FF), // Purple
    Color(0xFFFFFF00), // Yellow
    Color(0xFF0080FF), // Electric Blue
    Color(0xFFFF8000), // Orange
    Color(0xFF80FF00), // Chartreuse
    Color(0xFFFF0040), // Deep Pink
    Color(0xFF4000FF), // Blue Violet
    Color(0xFF00FF80), // Spring Green
  ];

  /// Select the best neon color for a new template
  /// Algorithm: Find unused colors first, then least-used colors
  static Color selectBestColor(List<WorkoutTemplate> existingTemplates) {
    if (existingTemplates.isEmpty) {
      return neonPalette.first; // Return first color if no templates exist
    }

    // Count usage of each color
    Map<int, int> colorUsage = {};
    for (Color color in neonPalette) {
      colorUsage[color.toARGB32()] = 0;
    }

    // Count how many times each color is used
    for (WorkoutTemplate template in existingTemplates) {
      if (colorUsage.containsKey(template.colorValue)) {
        colorUsage[template.colorValue] = colorUsage[template.colorValue]! + 1;
      }
    }

    // Find colors with minimum usage (0 = unused)
    int minUsage = colorUsage.values.reduce((a, b) => a < b ? a : b);
    
    // Get all colors with minimum usage
    List<Color> availableColors = neonPalette
        .where((color) => colorUsage[color.toARGB32()] == minUsage)
        .toList();

    // Return the first available color (could randomize here if desired)
    return availableColors.first;
  }

  /// Convert Color to int value for storage
  static int colorToInt(Color color) {
    return color.toARGB32();
  }

  /// Convert int value back to Color
  static Color intToColor(int colorValue) {
    return Color(colorValue);
  }

  /// Get color as Flutter Color object from WorkoutTemplate
  static Color getTemplateColor(WorkoutTemplate template) {
    return Color(template.colorValue);
  }

  /// Check if a color is in our neon palette
  static bool isNeonColor(Color color) {
    return neonPalette.any((neonColor) => neonColor.toARGB32() == color.toARGB32());
  }

  /// Get a contrasting text color for a given neon color
  static Color getContrastingTextColor(Color neonColor) {
    // For bright neon colors, black text usually works better
    double luminance = neonColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}