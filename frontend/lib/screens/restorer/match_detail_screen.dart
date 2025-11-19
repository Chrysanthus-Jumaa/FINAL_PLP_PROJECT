import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/match_request.dart';
//import '../../models/land_listing.dart' as land;
import '../../providers/app_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialogue.dart';

class MatchDetailScreen extends StatefulWidget {
  final MatchRequest matchRequest;

  const MatchDetailScreen({
    Key? key,
    required this.matchRequest,
  }) : super(key: key);

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool _isProcessing = false;

  Future<void> _handleAccept() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Request'),
        content: const Text(
          'Are you sure you want to accept this collaboration request? '
          'This will make the land unavailable and notify the organization.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.updateMatchRequestStatus(
      widget.matchRequest.id,
      'accept',
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted! Check your email for contact details.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      } else {
        ErrorDialog.show(
          context,
          appState.errorMessage ?? 'Failed to accept request',
        );
      }
    }
  }

  Future<void> _handleDecline() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: const Text(
          'Are you sure you want to decline this request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final success = await appState.updateMatchRequestStatus(
      widget.matchRequest.id,
      'decline',
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request declined')),
        );
        Navigator.pop(context);
      } else {
        ErrorDialog.show(
          context,
          appState.errorMessage ?? 'Failed to decline request',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Processing...'),
      );
    }

    final landDetails = widget.matchRequest.landListingDetails;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(widget.matchRequest.status),
            const SizedBox(height: AppTheme.lg),

            // Organization Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Organization', style: AppTheme.h3),
                    const SizedBox(height: AppTheme.md),
                    _buildInfoRow(
                      Icons.business,
                      widget.matchRequest.organizationName ?? 'Unknown',
                    ),
                    _buildInfoRow(
                      Icons.email,
                      widget.matchRequest.organizationEmail ?? 'No email',
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Requested on ${DateFormat('MMM dd, yyyy').format(DateTime.parse(widget.matchRequest.createdAt))}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.md),

            // Land Details
            if (landDetails != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Land Details', style: AppTheme.h3),
                      const SizedBox(height: AppTheme.md),
                      _buildInfoRow(
                        Icons.landscape,
                        landDetails['title'] ?? 'Unknown',
                      ),
                      _buildInfoRow(
                        Icons.straighten,
                        '${landDetails['size_acres']} acres (${landDetails['size_hectares']} hectares)',
                      ),
                      _buildInfoRow(
                        Icons.location_on,
                        '${landDetails['county_name']}, ${landDetails['subcounty_name']}',
                      ),
                      if (landDetails['restoration_types'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppTheme.sm),
                          child: Wrap(
                            spacing: AppTheme.xs,
                            children: (landDetails['restoration_types'] as List)
                                .map((type) => Chip(
                                      label: Text(
                                        type['display_name'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: AppTheme.primaryBlueLight,
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppTheme.xl),

            // Action Buttons (only for pending status)
            if (widget.matchRequest.isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Decline',
                      onPressed: _handleDecline,
                      type: ButtonType.destructive,
                    ),
                  ),
                  const SizedBox(width: AppTheme.md),
                  Expanded(
                    child: AppButton(
                      text: 'Accept',
                      onPressed: _handleAccept,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        color = AppTheme.warningOrange;
        label = 'PENDING';
        icon = Icons.schedule;
        break;
      case 'accepted':
        color = AppTheme.successGreen;
        label = 'ACCEPTED';
        icon = Icons.check_circle;
        break;
      case 'declined':
        color = AppTheme.mediumGray;
        label = 'DECLINED';
        icon = Icons.cancel;
        break;
      default:
        color = AppTheme.lightGray;
        label = status.toUpperCase();
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.md,
        vertical: AppTheme.sm,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.white, size: 20),
          const SizedBox(width: AppTheme.xs),
          Text(
            label,
            style: AppTheme.buttonText.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: AppTheme.sm),
          Expanded(
            child: Text(text, style: AppTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}