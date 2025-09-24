class ElderlyPerson {
  final String name;
  final String distance;
  final String ability;
  final String imageUrl;
  final bool isVerified;

  ElderlyPerson({
    required this.name,
    required this.distance,
    required this.ability,
    required this.imageUrl,
    this.isVerified = false,
  });
}