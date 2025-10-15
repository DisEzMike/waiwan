class GroupJobDetails {
  final String title;
  final String description;
  final String dateRange; // e.g. "YYYY-MM-DD - YYYY-MM-DD"
  final String timeFrom; // HH:MM
  final String timeTo; // HH:MM
  final String location;
  final int maxSeniors;
  final int pricePerPerson;

  GroupJobDetails({
    required this.title,
    required this.description,
    required this.dateRange,
    required this.timeFrom,
    required this.timeTo,
    required this.location,
    required this.maxSeniors,
    required this.pricePerPerson,
  });
}
