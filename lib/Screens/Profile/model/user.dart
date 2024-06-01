class User {
  final String imagePath;
  final String name;
  final String email;
  final String about;
  final bool isDarkMode;
  final bool emergency;
  final double latitude;
  final double longitude;

  const User({
    required this.imagePath,
    required this.name,
    required this.email,
    required this.about,
    required this.isDarkMode,
    required this.emergency,
    required this.latitude,
    required this.longitude,
  });
}
