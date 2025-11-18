import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import 'step2_terms.dart';

class OrganizationRegistrationStep1 extends StatefulWidget {
  const OrganizationRegistrationStep1({Key? key}) : super(key: key);

  @override
  State<OrganizationRegistrationStep1> createState() =>
      _OrganizationRegistrationStep1State();
}

class _OrganizationRegistrationStep1State
    extends State<OrganizationRegistrationStep1> {
  final _formKey = GlobalKey<FormState>();
  final _orgNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrganizationRegistrationStep2(
            registrationData: {
              'organization_name': _orgNameController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Organization'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                const LinearProgressIndicator(value: 0.5),
                const SizedBox(height: AppTheme.md),
                const Text('Step 1 of 2', style: AppTheme.bodySmall),
                const SizedBox(height: AppTheme.xl),

                Text('Organization Information', style: AppTheme.h3),
                const SizedBox(height: AppTheme.lg),

                // Organization Name
                AppTextField(
                  label: 'Organization Name',
                  controller: _orgNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.md),

                // Email
                AppTextField(
                  label: 'Organization Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.md),

                // Password
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.md),

                // Confirm Password
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.xl),

                // Next Button
                AppButton(
                  text: 'Next',
                  onPressed: _onNext,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}