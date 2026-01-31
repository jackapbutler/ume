import 'package:flutter/material.dart';

class CompletenessScores extends StatefulWidget {
  final Map<String, int> themes;
  final String title;

  const CompletenessScores({
    super.key,
    required this.themes,
    required this.title,
  });

  @override
  State<CompletenessScores> createState() => _CompletenessScoresState();
}

class _CompletenessScoresState extends State<CompletenessScores> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Container contentBox(context) {
    // sorted properties
    final sortedThemes = Map.fromEntries(widget.themes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (widget.themes.isEmpty) ...[
              const Text('No data available yet.'),
            ] else ...[
              const Text(
                "Overall",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              CustomPowerBar(
                value: widget.themes.values.reduce((a, b) => a + b) ~/
                    widget.themes.length,
              ),
              const SizedBox(height: 20),
              const Text(
                "Breakdown",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 200, // Adjust height as needed
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedThemes.length,
                  itemBuilder: (context, index) {
                    final propertyName = sortedThemes.keys.elementAt(index);
                    final propertyValue = sortedThemes.values.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(propertyName),
                          ),
                          Expanded(
                            flex: 3,
                            child: CustomPowerBar(value: propertyValue),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPowerBar extends StatelessWidget {
  final int value;

  const CustomPowerBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final barWidth = constraints.maxWidth;
        final filledWidth = barWidth * (value / 100);
        return Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Container(
                    width: filledWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: _getBarColor(value),
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(10, (index) {
                  return Container(
                    width: 1,
                    color: Colors.white,
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getBarColor(int value) {
    if (value < 30) {
      return Colors.red;
    } else if (value < 60) {
      return Colors.orange;
    } else if (value < 80) {
      return Colors.green;
    } else {
      return Colors.green.shade900;
    }
  }
}
