import 'package:euterpefy/views/tracks_generating/advanced_criterias.dart';
import 'package:flutter/material.dart';

class CustomCriteriaSlider extends StatelessWidget {
  final Criteria criteria;
  final Function(RangeValues) onChanged;

  const CustomCriteriaSlider({
    super.key,
    required this.criteria,
    required this.onChanged,
  });

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
                  criteria.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (criteria.description != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showDescriptionDialog(context),
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
            values: criteria.values,
            min: criteria.min,
            max: criteria.max,
            divisions: criteria.divisions,
            labels: RangeLabels(
              criteria.values.start.toStringAsFixed(3),
              criteria.values.end.toStringAsFixed(3),
            ),
            onChanged: onChanged,
          ),
        ),
        // Right-hand side label for the range
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            "${criteria.values.start.toStringAsFixed(3)} - ${criteria.values.end.toStringAsFixed(3)}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  void _showDescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(criteria.label),
          content: Text(criteria.description!),
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
