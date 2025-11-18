import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/land_listing.dart' as land;
import '../../../services/api_service.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/loading_indicator.dart';
import 'step3_terms.dart';

class RestorerRegistrationStep2 extends StatefulWidget {
  final Map<String, dynamic> personalData;

  const RestorerRegistrationStep2({
    Key? key,
    required this.personalData,
  }) : super(key: key);

  @override
  State<RestorerRegistrationStep2> createState() => _RestorerRegistrationStep2State();
}

class _RestorerRegistrationStep2State extends State<RestorerRegistrationStep2> {
  final ApiService _apiService = ApiService();
  List<land.RestorationType> _restorationTypes = [];
  final Set<int> _selectedTypeIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestorationTypes();
  }

  Future<void> _loadRestorationTypes() async {
    try {
      final types = await _apiService.getRestorationTypes();
      setState(() {
        _restorationTypes = types;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onNext() {
    if (_selectedTypeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one restoration type'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Combine data and pass to next step
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestorerRegistrationStep3(
          registrationData: {
            ...widget.personalData,
            'restoration_type_ids': _selectedTypeIds.toList(),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Restorer'),
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading...')
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    const LinearProgressIndicator(value: 0.66),
                    const SizedBox(height: AppTheme.md),
                    const Text('Step 2 of 3', style: AppTheme.bodySmall),
                    const SizedBox(height: AppTheme.xl),

                    Text('Projects I Can Support', style: AppTheme.h3),
                    const SizedBox(height: AppTheme.md),
                    Text(
                      'Select at least one restoration type',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),

                    // Restoration types checkboxes
                    Expanded(
                      child: ListView.builder(
                        itemCount: _restorationTypes.length,
                        itemBuilder: (context, index) {
                          final type = _restorationTypes[index];
                          final isSelected = _selectedTypeIds.contains(type.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: AppTheme.md),
                            child: CheckboxListTile(
                              title: Text(
                                type.displayName,
                                style: AppTheme.bodyLarge,
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedTypeIds.add(type.id);
                                  } else {
                                    _selectedTypeIds.remove(type.id);
                                  }
                                });
                              },
                              activeColor: AppTheme.primaryBlue,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppTheme.lg),

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
    );
  }
}