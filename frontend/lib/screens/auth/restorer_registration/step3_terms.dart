import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/common/error_dialog.dart';
import '../login_screen.dart';

class RestorerRegistrationStep3 extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const RestorerRegistrationStep3({
    Key? key,
    required this.registrationData,
  }) : super(key: key);

  @override
  State<RestorerRegistrationStep3> createState() => _RestorerRegistrationStep3State();
}

class _RestorerRegistrationStep3State extends State<RestorerRegistrationStep3> {
  final ApiService _apiService = ApiService();
  bool _agreedToTerms = false;
  bool _isSubmitting = false;

  Future<void> _onSubmit() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Privacy Policy'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Prepare final registration data
      final data = {
        ...widget.registrationData,
        'role': 'restorer',
        'terms_accepted': true,
        'confirm_password': widget.registrationData['password'],
      };

      await _apiService.register(data);

      // Show success message
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successGreen),
                SizedBox(width: AppTheme.sm),
                Text('Success!'),
              ],
            ),
            content: const Text(
              'Registration successful! Redirecting to login...',
            ),
            actions: [
              AppButton(
                text: 'OK',
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _navigateToLogin();
                },
              ),
            ],
          ),
        );

        // Auto-redirect after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close dialog if still open
            _navigateToLogin();
          }
        });
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ErrorDialog.show(context, e.toString());
      }
    }
  }

  void _navigateToLogin() {
    // Navigate to login and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Creating your account...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Restorer'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              const LinearProgressIndicator(value: 1.0),
              const SizedBox(height: AppTheme.md),
              const Text('Step 3 of 3', style: AppTheme.bodySmall),
              const SizedBox(height: AppTheme.xl),

              Text('Terms & Privacy', style: AppTheme.h3),
              const SizedBox(height: AppTheme.lg),

              // Terms text
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: AppTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'By signing up, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.xl),

                      // Checkbox
                      Card(
                        child: CheckboxListTile(
                          title: const Text('I agree to the Terms and Privacy Policy'),
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() => _agreedToTerms = value ?? false);
                          },
                          activeColor: AppTheme.primaryBlue,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.lg),

              // Submit Button
              AppButton(
                text: 'Submit',
                onPressed: _agreedToTerms ? _onSubmit : null,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}