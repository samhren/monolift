import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/settings_models.dart';

class WeightUnitScreen extends StatelessWidget {
  const WeightUnitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text(
          'Weight Unit',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              
              // Description
              const Text(
                'Choose your preferred weight unit for all exercises and tracking. This will affect how weights are displayed and entered throughout the app.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Weight Units
              _buildSectionHeader('Select Weight Unit'),
              const SizedBox(height: 12),
              _buildWeightUnitOptions(context, settingsProvider),
              
              const SizedBox(height: 32),
              
              // Conversion Examples
              _buildSectionHeader('Quick Reference'),
              const SizedBox(height: 12),
              _buildConversionExamples(settingsProvider.settings.weightUnit),
              
              const SizedBox(height: 32),
              
              // Information Section
              _buildSectionHeader('About Weight Units'),
              const SizedBox(height: 12),
              _buildInfoSection(),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF666666),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildWeightUnitOptions(BuildContext context, SettingsProvider settingsProvider) {
    return Column(
      children: WeightUnit.values.map((unit) {
        final isSelected = settingsProvider.settings.weightUnit == unit;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: const Color(0xFFFFFFFF), width: 2)
                : null,
          ),
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF666666),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFFFFFFF) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Color(0xFF000000),
                    )
                  : null,
            ),
            title: Text(
              unit.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFFFFFFFF) : const Color(0xFFCCCCCC),
              ),
            ),
            subtitle: Text(
              _getUnitDescription(unit),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            trailing: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFFFFFFFF),
                  )
                : null,
            onTap: () => settingsProvider.updateWeightUnit(unit),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConversionExamples(WeightUnit currentUnit) {
    final examples = [
      {'lbs': 135, 'kg': 61.2},
      {'lbs': 185, 'kg': 83.9},
      {'lbs': 225, 'kg': 102.1},
      {'lbs': 315, 'kg': 142.9},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Pounds (lbs)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: currentUnit == WeightUnit.lbs 
                          ? const Color(0xFFFFFFFF) 
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Kilograms (kg)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: currentUnit == WeightUnit.kg 
                          ? const Color(0xFFFFFFFF) 
                          : const Color(0xFF999999),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF333333), height: 1),
          ...examples.map((example) {
            final lbs = example['lbs']!;
            final kg = example['kg']!;
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${lbs.round()} lbs',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentUnit == WeightUnit.lbs 
                            ? const Color(0xFFFFFFFF) 
                            : const Color(0xFF999999),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.swap_horiz,
                    color: Color(0xFF666666),
                    size: 20,
                  ),
                  Expanded(
                    child: Text(
                      '$kg kg',
                      style: TextStyle(
                        fontSize: 16,
                        color: currentUnit == WeightUnit.kg 
                            ? const Color(0xFFFFFFFF) 
                            : const Color(0xFF999999),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF666666),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Weight Unit Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• Pounds (lbs): Most common in the United States\n\n'
            '• Kilograms (kg): Standard metric unit used worldwide\n\n'
            '• All existing workout data will be automatically converted when you change units\n\n'
            '• Progress charts and calculations will reflect your selected unit\n\n'
            '• 1 kg = 2.20462 lbs\n• 1 lb = 0.453592 kg',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getUnitDescription(WeightUnit unit) {
    switch (unit) {
      case WeightUnit.lbs:
        return 'Imperial system, common in US gyms';
      case WeightUnit.kg:
        return 'Metric system, used worldwide';
    }
  }
}