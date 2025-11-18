import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/user.dart';
import '../../../services/api_service.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/loading_indicator.dart';
import 'step2_project_support.dart';

class RestorerRegistrationStep1 extends StatefulWidget {
  const RestorerRegistrationStep1({Key? key}) : super(key: key);

  @override
  State<RestorerRegistrationStep1> createState() => _RestorerRegistrationStep1State();
}

class _RestorerRegistrationStep1State extends State<RestorerRegistrationStep1> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Data
  List<County> _counties = [];
  List<Subcounty> _subcounties = [];
  County? _selectedCounty;
  Subcounty? _selectedSubcounty;
  bool _isLoadingCounties = true;
  bool _isLoadingSubcounties = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadCounties();
  }

  Future<void> _loadCounties() async {
    try {
      final counties = await _apiService.getCounties();
      setState(() {
        _counties = counties;
        _isLoadingCounties = false;
      });
    } catch (e) {
      setState(() => _isLoadingCounties = false);
    }
  }

  Future<void> _loadSubcounties(int countyId) async {
    setState(() {
      _isLoadingSubcounties = true;
      _selectedSubcounty = null;
      _subcounties = [];
    });

    try {
      final subcounties = await _apiService.getSubcounties(countyId);
      setState(() {
        _subcounties = subcounties;
        _isLoadingSubcounties = false;
      });
    } catch (e) {
      setState(() => _isLoadingSubcounties = false);
    }
  }

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      // Pass data to next step
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestorerRegistrationStep2(
            personalData: {
              'first_name': _firstNameController.text,
              'last_name': _lastNameController.text,
              'phone': _phoneController.text,
              'email': _emailController.text,
              'password': _passwordController.text,
              'county': _selectedCounty!.id,
              'subcounty': _selectedSubcounty!.id,
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Restorer'),
      ),
      body: _isLoadingCounties
          ? const LoadingIndicator(message: 'Loading...')
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator
                      const LinearProgressIndicator(value: 0.33),
                      const SizedBox(height: AppTheme.md),
                      const Text('Step 1 of 3', style: AppTheme.bodySmall),
                      const SizedBox(height: AppTheme.xl),

                      Text('Personal Information', style: AppTheme.h3),
                      const SizedBox(height: AppTheme.lg),

                      // First Name
                      AppTextField(
                        label: 'First Name',
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.md),

                      // Last Name
                      AppTextField(
                        label: 'Last Name',
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.md),

                      // County
                      DropdownButtonFormField<County>(
                        decoration: const InputDecoration(
                          labelText: 'County',
                        ),
                        value: _selectedCounty,
                        items: _counties.map((county) {
                          return DropdownMenuItem(
                            value: county,
                            child: Text(county.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCounty = value;
                            if (value != null) {
                              _loadSubcounties(value.id);
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a county';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.md),

                      // Subcounty
                      DropdownButtonFormField<Subcounty>(
                        decoration: const InputDecoration(
                          labelText: 'Subcounty',
                        ),
                        value: _selectedSubcounty,
                        items: _subcounties.map((subcounty) {
                          return DropdownMenuItem(
                            value: subcounty,
                            child: Text(subcounty.name),
                          );
                        }).toList(),
                        onChanged: _isLoadingSubcounties
                            ? null
                            : (value) {
                                setState(() => _selectedSubcounty = value);
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a subcounty';
                          }
                          return null;
                        },
                      ),
                      if (_isLoadingSubcounties) ...[
                        const SizedBox(height: AppTheme.sm),
                        const Text(
                          'Loading subcounties...',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: AppTheme.md),

                      // Phone
                      AppTextField(
                        label: 'Phone Number (Optional)',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppTheme.md),

                      // Email
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
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
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