import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../models/land_listing.dart' as land;
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  List<County> _counties = [];
  List<Subcounty> _subcounties = [];
  List<land.RestorationType> _allRestorationTypes = [];
  
  County? _selectedCounty;
  Subcounty? _selectedSubcounty;
  final Set<int> _selectedTypeIds = {};

  bool _isLoading = true;
  bool _isLoadingSubcounties = false;
  bool _isSubmitting = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser!;
    
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _phoneController = TextEditingController(text: user.phone ?? '');
    _emailController = TextEditingController(text: user.email);
    
    _selectedTypeIds.addAll(
      user.restorationTypes?.map((t) => t.id) ?? [],
    );
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final counties = await _apiService.getCounties();
      final types = await _apiService.getRestorationTypes();
      
      final user = Provider.of<AppState>(context, listen: false).currentUser!;
      
      final county = counties.firstWhere((c) => c.id == user.countyId);

      setState(() {
        _counties = counties;
        _allRestorationTypes = types;
        _selectedCounty = county;
        _isLoading = false;
      });

      await _loadSubcounties(county.id);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSubcounties(int countyId) async {
    setState(() => _isLoadingSubcounties = true);

    try {
      final subcounties = await _apiService.getSubcounties(countyId);
      final user = Provider.of<AppState>(context, listen: false).currentUser!;
      
      final subcounty = subcounties.firstWhere(
        (s) => s.id == user.subcountyId,
      );

      setState(() {
        _subcounties = subcounties;
        _selectedSubcounty = subcounty;
        _isLoadingSubcounties = false;
      });
    } catch (e) {
      setState(() => _isLoadingSubcounties = false);
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

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one restoration type'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final appState = Provider.of<AppState>(context, listen: false);

    final data = {
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'county': _selectedCounty!.id,
      'subcounty': _selectedSubcounty!.id,
      'restoration_type_ids': _selectedTypeIds.toList(),
    };

    try {
      await appState.updateProfile(data);
      
      setState(() {
        _isSubmitting = false;
        _hasChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      
      if (mounted) {
        ErrorDialog.show(context, e.toString());
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading profile...');
    }

    if (_isSubmitting) {
      return const LoadingIndicator(message: 'Updating profile...');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Form(
        key: _formKey,
        onChanged: () => setState(() => _hasChanges = true),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Profile', style: AppTheme.h2),
            const SizedBox(height: AppTheme.lg),

            Text('Identity', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),
            
            AppTextField(
              label: 'First Name',
              controller: _firstNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.md),

            AppTextField(
              label: 'Last Name',
              controller: _lastNameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.lg),

            Text('Location', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),

            DropdownButtonFormField<County>(
              decoration: const InputDecoration(labelText: 'County'),
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
                  _hasChanges = true;
                  if (value != null) {
                    _loadSubcounties(value.id);
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.md),

            DropdownButtonFormField<Subcounty>(
              decoration: const InputDecoration(labelText: 'Subcounty'),
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
                      setState(() {
                        _selectedSubcounty = value;
                        _hasChanges = true;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.lg),

            Text('Contact', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),

            AppTextField(
              label: 'Phone Number (Optional)',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppTheme.md),

            AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                if (!value.contains('@')) {
                  return 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppTheme.lg),

            Text('Restoration Types Supported', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),

            ..._allRestorationTypes.map((type) {
              final isSelected = _selectedTypeIds.contains(type.id);
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.sm),
                child: CheckboxListTile(
                  title: Text(type.displayName),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedTypeIds.add(type.id);
                      } else {
                        _selectedTypeIds.remove(type.id);
                      }
                      _hasChanges = true;
                    });
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              );
            }).toList(),
            const SizedBox(height: AppTheme.lg),

            Text('Password', style: AppTheme.h3),
            const SizedBox(height: AppTheme.md),

            OutlinedButton.icon(
              onPressed: _showChangePasswordDialog,
              icon: const Icon(Icons.lock),
              label: const Text('Change Password'),
            ),
            const SizedBox(height: AppTheme.xl),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    onPressed: _hasChanges
                        ? () {
                            setState(() => _hasChanges = false);
                            _loadData();
                          }
                        : null,
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: AppButton(
                    text: 'Save',
                    onPressed: _hasChanges ? _onSave : null,
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