import 'package:flutter/material.dart';

class CustomRangeSlider extends StatelessWidget {
  final String label;
  final RangeValues rangeValues;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<RangeValues> onChanged;
  final int decimalPlaces; // For formatting the labels
  final String? description; // Optional property for the description

  const CustomRangeSlider({
    Key? key,
    required this.label,
    required this.rangeValues,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.decimalPlaces = 2, // Default to 2 decimal places
    this.description, // Initialize the optional description property
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, // Adjust spacing overall
      children: [
        // Wrap label and icon in a Flexible widget to manage space dynamically
        Flexible(
          flex:
              0, // Still aiming for compact size but with better space management
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Keep content tightly packed
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (description != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () =>
                        _showDescriptionDialog(context, description!),
                    tooltip: 'Info',
                    padding:
                        const EdgeInsets.only(left: 4), // Keep padding tight
                    constraints:
                        const BoxConstraints(), // Tighten constraints around the icon
                  ),
              ],
            ),
          ),
        ),
        // Slider takes up the rest of the space
        Expanded(
          child: RangeSlider(
            values: rangeValues,
            min: min,
            max: max,
            divisions: divisions,
            labels: RangeLabels(
              rangeValues.start.toStringAsFixed(decimalPlaces),
              rangeValues.end.toStringAsFixed(decimalPlaces),
            ),
            onChanged: onChanged,
          ),
        ),
        // Right-hand side label for the range
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            "${rangeValues.start.toStringAsFixed(decimalPlaces)} - ${rangeValues.end.toStringAsFixed(decimalPlaces)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showDescriptionDialog(BuildContext context, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
