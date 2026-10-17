import '../models/user_profile.dart';

/// Simulates a remote API.
///
/// A real app would call an HTTP endpoint here. To keep the assignment
/// focused on `Future`, `async` / `await` and `setState`, the "server" is a
/// small in-memory list and the network delay is faked with
/// `Future.delayed`. Every call returns the next user in the list, so the
/// "Refresh User" button visibly changes the card.
class UserService {
  int _nextIndex = 0;

  static const List<UserProfile> _sampleUsers = [
    UserProfile(
      name: 'Alex Morgan',
      title: 'Flutter Software Specialist',
      email: 'alex.morgan@example.edu',
      phone: '+90 212 555 01 01',
      location: 'Istanbul, Türkiye',
      website: 'www.alexmorgan.dev',
      officeHours: 'Mon - Fri, 09:00 - 17:00',
      avatarUrl: 'https://i.pravatar.cc/300?img=12',
      bio: 'Alex builds cross-platform mobile apps with Flutter and helps '
          'developers write clean, testable Dart code. Outside of work, Alex '
          'mentors students and contributes to open source projects.',
      skills: ['Flutter', 'Dart', 'REST APIs', 'State Management', 'Firebase'],
      mission: 'To make high-quality mobile development accessible by '
          'building simple, reliable apps and sharing what I learn along '
          'the way.',
      vision: 'A future where every student can turn an idea into a polished '
          'mobile app and publish it with confidence.',
      experienceYears: 8,
      projectCount: 24,
    ),
    UserProfile(
      name: 'Elif Demir',
      title: 'Mobile UI/UX Designer',
      email: 'elif.demir@example.edu',
      phone: '+90 312 555 02 02',
      location: 'Ankara, Türkiye',
      website: 'www.elifdemir.design',
      officeHours: 'Tue - Thu, 10:00 - 16:00',
      avatarUrl: 'https://i.pravatar.cc/300?img=47',
      bio: 'Elif designs intuitive mobile interfaces and prototypes them '
          'directly in Flutter. She focuses on accessibility, motion and '
          'design systems that scale across platforms.',
      skills: ['UI Design', 'Figma', 'Material 3', 'Prototyping', 'Accessibility'],
      mission: 'To design mobile experiences that feel effortless and '
          'respect every user, regardless of ability or device.',
      vision: 'Interfaces that are beautiful by default and inclusive by '
          'design.',
      experienceYears: 6,
      projectCount: 31,
    ),
    UserProfile(
      name: 'Daniel Carter',
      title: 'Backend & API Engineer',
      email: 'daniel.carter@example.edu',
      phone: '+90 232 555 03 03',
      location: 'Izmir, Türkiye',
      website: 'www.danielcarter.io',
      officeHours: 'Mon, Wed, Fri, 13:00 - 18:00',
      avatarUrl: 'https://i.pravatar.cc/300?img=33',
      bio: 'Daniel designs fast and secure APIs that power mobile apps. He '
          'enjoys cloud infrastructure, databases and turning messy '
          'requirements into clean architecture.',
      skills: ['REST & GraphQL', 'Node.js', 'PostgreSQL', 'Cloud', 'Security'],
      mission: 'To build dependable back-end services so mobile teams can '
          'ship features without worrying about the server.',
      vision: 'Software systems that scale gracefully, stay secure and are '
          'easy for the next engineer to understand.',
      experienceYears: 10,
      projectCount: 40,
    ),
  ];

  /// Fetches the next user after a simulated 2-second network delay.
  Future<UserProfile> fetchUser() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = _sampleUsers[_nextIndex % _sampleUsers.length];
    _nextIndex++;
    return user;
  }
}
