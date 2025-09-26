import 'package:flutter/material.dart';
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

  const ElderlyPersonsGrid({
    super.key,
    required this.elderlyPersons,
    required this.isLoading,
    required this.isRefreshing,
    required this.errorMessage,
    required this.onRetry,
    required this.onPersonTap,
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
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: elderlyPersons.length,
      itemBuilder: (context, index) {
        final person = elderlyPersons[index];
        return ElderlyPersonCard(
          person: person,
          onTap: () => onPersonTap(person),
        );
      },
    );
  }
}