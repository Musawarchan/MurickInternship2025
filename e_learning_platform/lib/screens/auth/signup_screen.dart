import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validation_utils.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/custom_form_field.dart';
import '../../widgets/role_dropdown.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthProvider>().signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

    if (mounted && context.read<AuthProvider>().isAuthenticated) {
      Navigator.of(context).pop();
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Create Account'),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) =>
                      _buildErrorBanner(auth.error),
                ),
                const SizedBox(height: 24),
                _buildFormFields(),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (context, auth, child) =>
                      _buildSignupButton(auth.isLoading),
                ),
                const SizedBox(height: 16),
                _buildLoginLink(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add,
          size: 64,
          color: AppTheme.vividPink,
        ),
        const SizedBox(height: 16),
        Text(
          'Join our E-Learning Platform',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create your account to start your learning journey',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String? error) {
    if (error == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        CustomFormField(
          controller: _nameController,
          labelText: 'Full Name',
          validator: ValidationUtils.validateName,
          prefixIcon: const Icon(Icons.person_outlined),
        ),
        const SizedBox(height: 16),
        CustomFormField(
          controller: _emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: ValidationUtils.validateEmail,
          prefixIcon: const Icon(Icons.email_outlined),
        ),
        const SizedBox(height: 16),
        CustomFormField(
          controller: _passwordController,
          labelText: 'Password',
          obscureText: true,
          validator: ValidationUtils.validatePassword,
          prefixIcon: const Icon(Icons.lock_outlined),
        ),
        const SizedBox(height: 16),
        CustomFormField(
          controller: _confirmPasswordController,
          labelText: 'Confirm Password',
          obscureText: true,
          validator: _validateConfirmPassword,
          prefixIcon: const Icon(Icons.lock_outlined),
        ),
        const SizedBox(height: 16),
        RoleDropdown(
          selectedRole: _selectedRole,
          onChanged: (role) => setState(() => _selectedRole = role),
        ),
      ],
    );
  }

  Widget _buildSignupButton(bool isLoading) {
    return AuthButton(
      text: 'Create Account',
      onPressed: _handleSignup,
      isLoading: isLoading,
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}
