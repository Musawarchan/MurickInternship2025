import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';

class RoleDropdown extends StatelessWidget {
  final UserRole selectedRole;
  final void Function(UserRole) onChanged;

  const RoleDropdown({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      value: selectedRole,
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: const [
        DropdownMenuItem(
          value: UserRole.student,
          child: Row(
            children: [
              Icon(Icons.school, size: 20),
              SizedBox(width: 8),
              Text('Student'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: UserRole.instructor,
          child: Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 8),
              Text('Instructor'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: UserRole.admin,
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, size: 20),
              SizedBox(width: 8),
              Text('Admin'),
            ],
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
