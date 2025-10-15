import 'package:flutter/material.dart';

class PresetMessagesBar extends StatelessWidget {
  final List<String> presetMessages;
  final Function(String) onPresetSelected;

  const PresetMessagesBar({
    super.key,
    required this.presetMessages,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (presetMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[100],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: presetMessages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ElevatedButton(
              onPressed: () => onPresetSelected(presetMessages[index]),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: Text(
                presetMessages[index],
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}