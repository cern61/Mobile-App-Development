/// Data model for the user displayed on the profile card and on every tab.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.location,
    required this.website,
    required this.officeHours,
    required this.avatarUrl,
    required this.bio,
    required this.skills,
    required this.mission,
    required this.vision,
    required this.experienceYears,
    required this.projectCount,
  });

  final String name;
  final String title;
  final String email;
  final String phone;
  final String location;
  final String website;
  final String officeHours;
  final String avatarUrl;
  final String bio;
  final List<String> skills;
  final String mission;
  final String vision;
  final int experienceYears;
  final int projectCount;

  /// Initials shown in the avatar when the image cannot be loaded (e.g. offline).
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
