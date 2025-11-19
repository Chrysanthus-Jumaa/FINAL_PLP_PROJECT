import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../models/land_listing.dart' as land;
import '../../providers/app_state.dart';
import '../../services/api_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialogue.dart';

class AddLandScreen extends StatefulWidget {
  const AddLandScreen({Key? key}) : super(key: key);

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final _titleController = TextEditingController();
  final _sizeController = TextEditingController();

  // Data
  List<County> _counties = [];
  List<Subcounty> _subcounties = [];
  List<land.RestorationType> _availableRestorationTypes = [];
  
  County? _selectedCounty;
  Subcounty? _selectedSubcounty;
  String _selectedUnit = 'acres';
  bool _isAvailable = true;
  final Set<int> _selectedTypeIds = {};

  bool _isLoadingCounties = true;
  bool _isLoadingSubcounties = false;
  bool _isLoadingTypes = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final counties = await _apiService.getCounties();
      final types = await _apiService.getRestorationTypes();
      
      // Get user's restoration types
      final appState = Provider.of<AppState>(context, listen: false);
      final userTypeIds = appState.currentUser?.restorationTypes
          ?.map((t) => t.id)
          .toSet() ?? {};

      // Filter types to only show what user supports
      final filteredTypes = types.where((t) => userTypeIds.contains(t.id)).toList();

      setState(() {
        _counties = counties;
        _availableRestorationTypes = filteredTypes;
        _isLoadingCounties = false;
        _isLoadingTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCounties = false;
        _isLoadingTypes = false;
      });
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

  Future<void> _onSubmit() async {
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
      'title': _titleController.text,
      'size': double.parse(_sizeController.text),
      'unit': _selectedUnit,
      'county': _selectedCounty!.id,
      'subcounty': _selectedSubcounty!.id,
      'restoration_type_ids': _selectedTypeIds.toList(),
      'availability': _isAvailable ? 'available' : 'unavailable',
    };

    final success = await appState.addLandListing(data);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Land listing created successfully')),
        );
        Navigator.pop(context);
      } else {
        ErrorDialog.show(context, appState.errorMessage ?? 'Failed to create listing');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCounties || _isLoadingTypes) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading...'),
      );
    }

    if (_isSubmitting) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Creating land listing...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Land Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Land Details', style: AppTheme.h3),
                const SizedBox(height: AppTheme.lg),

                // Title
                AppTextField(
                  label: 'Land Title',
                  hint: 'e.g., Family Farm',
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.md),

                // Size and Unit
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Size',
                        controller: _sizeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Unit'),
                        value: _selectedUnit,
                        items: const [
                          DropdownMenuItem(value: 'acres', child: Text('Acres')),
                          DropdownMenuItem(value: 'hectares', child: Text('Hectares')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedUnit = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.md),

                // County
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
                const SizedBox(height: AppTheme.lg),

                // Restoration Types
                Text('Restoration Types', style: AppTheme.h3),
                const SizedBox(height: AppTheme.md),
                ..._availableRestorationTypes.map((type) {
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
                        });
                      },
                      activeColor: AppTheme.primaryBlue,
                    ),
                  );
                }).toList(),
                const SizedBox(height: AppTheme.lg),

                // Availability Toggle
                Card(
                  child: SwitchListTile(
                    title: const Text('Availability'),
                    subtitle: Text(_isAvailable ? 'Available' : 'Unavailable'),
                    value: _isAvailable,
                    onChanged: (value) {
                      setState(() => _isAvailable = value);
                    },
                    activeColor: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: AppTheme.xl),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.md),
                    Expanded(
                      child: AppButton(
                        text: 'Save',
                        onPressed: _onSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}