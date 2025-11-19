import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialogue.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late final TextEditingController _orgNameController;
  late final TextEditingController _emailController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser!;
    
    _orgNameController = TextEditingController(text: user.organizationName);
    _emailController = TextEditingController(text: user.email);
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final appState = Provider.of<AppState>(context, listen: false);

    final data = {
      'organization_name': _orgNameController.text,
      'email': _emailController.text,
    };

    try {
      await _apiService.updateProfile(data);
      await appState.refreshProfile();

      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ErrorDialog.show(context, e.toString());
      }
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('This feature is coming soon.'),
        actions: [
          AppButton(
            text: 'OK',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _orgNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return const LoadingIndicator(message: 'Updating profile...');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Profile', style: AppTheme.h2),
            const SizedBox(height: AppTheme.xl),

            Text('Organization Information', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),

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

            AppTextField(
              label: 'Email',
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
            const SizedBox(height: AppTheme.xl),

            Text('Password', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),

            AppButton(
              text: 'Change Password',
              onPressed: _showChangePasswordDialog,
              type: ButtonType.secondary,
              width: double.infinity,
            ),
            const SizedBox(height: AppTheme.xl),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: () {
                      // Reset to original values
                      final user = Provider.of<AppState>(context, listen: false).currentUser!;
                      _orgNameController.text = user.organizationName ?? '';
                      _emailController.text = user.email;
                    },
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: AppButton(
                    text: 'Save',
                    onPressed: _onSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}