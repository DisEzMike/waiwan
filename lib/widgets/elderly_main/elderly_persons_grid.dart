import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waiwan/providers/font_size_provider.dart';
import '../../model/elderly_person.dart';
import 'card.dart';
import 'loading_state.dart';
import 'error_state.dart';

class ElderlyPersonsGrid extends StatelessWidget {
  final List<ElderlyPerson> elderlyPersons;
  final bool isLoading;
  final bool isRefreshing;
  final String errorMessage;
  final VoidCallback onRetry;
  final Function(ElderlyPerson) onPersonTap;
  final Set<String> selectedIds;
  final Function(ElderlyPerson) onAdd;
  final bool showActionButton;
  final Color? cardColor;

  const ElderlyPersonsGrid({
    super.key,
    required this.elderlyPersons,
    required this.isLoading,
    required this.isRefreshing,
    required this.errorMessage,
    required this.onRetry,
    required this.onPersonTap,
    this.selectedIds = const {},
    required this.onAdd,
    this.showActionButton = true,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading indicator for initial load
    if (isLoading && !isRefreshing) {
      return const LoadingState();
    }

    // Show loading indicator during refresh when list is empty
    if (isRefreshing && elderlyPersons.isEmpty) {
      return const LoadingState();
    }

    if (errorMessage.isNotEmpty) {
      return ErrorState(onRetry: onRetry);
    }

    // Don't show "no data found" message, just show empty grid
    return Consumer<FontSizeProvider>(
      builder: (context, fontProvider, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.60,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: elderlyPersons.length,
          itemBuilder: (context, index) {
            final person = elderlyPersons[index];
            return ElderlyPersonCard(
              person: person,
              onTap: () => onPersonTap(person),
              isSelected: selectedIds.contains(person.id),
              onAdd: () => onAdd(person),
              showActionButton: showActionButton,
              cardColor: cardColor,
            );
          },
        );
      },
    );
  }
}
