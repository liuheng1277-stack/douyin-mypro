import 'package:flutter/material.dart';

class SpeedMenu extends StatelessWidget {
  final double currentSpeed;
  final Function(double) onSpeedChanged;
  final VoidCallback onClose;

  const SpeedMenu({
    super.key,
    required this.currentSpeed,
    required this.onSpeedChanged,
    required this.onClose,
  });

  final List<Map<String, dynamic>> speeds = const [
    {'label': '0.5x', 'value': 0.5},
    {'label': '0.75x', 'value': 0.75},
    {'label': '1.0x', 'value': 1.0},
    {'label': '1.25x', 'value': 1.25},
    {'label': '1.5x', 'value': 1.5},
    {'label': '2.0x', 'value': 2.0},
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    '播放速度',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: speeds.map((speed) {
                      final isSelected = currentSpeed == speed['value'];
                      return ChoiceChip(
                        label: Text(speed['label']),
                        selected: isSelected,
                        onSelected: (_) {
                          onSpeedChanged(speed['value']);
                          onClose();
                        },
                        backgroundColor: Colors.grey.shade800,
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
