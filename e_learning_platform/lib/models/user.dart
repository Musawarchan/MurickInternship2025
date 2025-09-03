import '../providers/auth_provider.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser(
      {required this.id,
      required this.name,
      required this.email,
      required this.role});
}
