import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../auth/restorer_registration/step1_personal_info.dart';
import '../auth/organisation_registration/step1_org_info.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check screen size for responsive layout
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose your role',
                style: AppTheme.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.xxl),
              
              // Cards layout - responsive
              Expanded(
                child: isDesktop
                    ? Row(
                        children: [
                          Expanded(child: _buildRoleCard(context, true)),
                          const SizedBox(width: AppTheme.lg),
                          Expanded(child: _buildRoleCard(context, false)),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(child: _buildRoleCard(context, true)),
                          const SizedBox(height: AppTheme.lg),
                          Expanded(child: _buildRoleCard(context, false)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, bool isRestorer) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => isRestorer
                  ? const RestorerRegistrationStep1()
                  : const OrganizationRegistrationStep1(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.xl),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent, width: 2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlueLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  isRestorer ? Icons.eco : Icons.business,
                  size: 50,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: AppTheme.lg),
              Text(
                isRestorer ? 'Local Restorer' : 'Project Operator',
                style: AppTheme.h3.copyWith(color: AppTheme.primaryBlue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.sm),
              Text(
                isRestorer
                    ? 'Register your land for projects'
                    : 'Find land for your restoration projects',
                style: AppTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}