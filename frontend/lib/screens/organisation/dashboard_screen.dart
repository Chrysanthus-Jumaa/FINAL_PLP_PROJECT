import '../../services/api_service.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_dialogue.dart';
import '../auth/login_screen.dart';
import 'matches_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
//import 'matches_screen.dart' as org_matches;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _showInAcres = true;

  // Filters
  int? _selectedCountyFilter;
  String? _selectedRestorationTypeFilter;
  double? _minSize;
  double? _maxSize;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Build filter map
    final filters = <String, String>{};
    if (_selectedCountyFilter != null) {
      filters['county'] = _selectedCountyFilter.toString();
    }
    if (_selectedRestorationTypeFilter != null) {
      filters['restoration_type'] = _selectedRestorationTypeFilter!;
    }
    if (_minSize != null) {
      filters['min_size'] = _minSize.toString();
    }
    if (_maxSize != null) {
      filters['max_size'] = _maxSize.toString();
    }

    await appState.loadLandListings(filters: filters.isEmpty ? null : filters);
    await appState.loadMatchRequests();
    await appState.loadNotifications();
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _onLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.logout();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        selectedCounty: _selectedCountyFilter,
        selectedRestorationType: _selectedRestorationTypeFilter,
        minSize: _minSize,
        maxSize: _maxSize,
        onApply: (county, type, min, max) {
          setState(() {
            _selectedCountyFilter = county;
            _selectedRestorationTypeFilter = type;
            _minSize = min;
            _maxSize = max;
          });
          _loadData();
        },
        onClear: () {
          setState(() {
            _selectedCountyFilter = null;
            _selectedRestorationTypeFilter = null;
            _minSize = null;
            _maxSize = null;
          });
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.currentUser;
        
        if (user == null) {
          return const Scaffold(body: LoadingIndicator());
        }

        final isDesktop = MediaQuery.of(context).size.width > 1024;
        final isTablet = MediaQuery.of(context).size.width > 600;

        return Scaffold(
          appBar: isDesktop || isTablet ? _buildDesktopAppBar(user) : null,
          drawer: isDesktop || isTablet ? null : _buildDrawer(user),
          body: _buildBody(appState),
          bottomNavigationBar: isDesktop || isTablet ? null : _buildBottomNav(appState),
        );
      },
    );
  }

  PreferredSizeWidget _buildDesktopAppBar(user) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryBlue,
            child: Text(user.initials, style: AppTheme.buttonText),
          ),
          const SizedBox(width: AppTheme.md),
          Text('Welcome, ${user.organizationName}', style: AppTheme.h3),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => _onNavItemTapped(0),
          child: Text(
            'Browse Lands',
            style: TextStyle(
              color: _selectedIndex == 0 ? AppTheme.primaryBlue : AppTheme.mediumGray,
              fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _onNavItemTapped(1),
          child: Text(
            'Matches',
            style: TextStyle(
              color: _selectedIndex == 1 ? AppTheme.primaryBlue : AppTheme.mediumGray,
              fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Consumer<AppState>(
          builder: (context, appState, _) {
            final unreadCount = appState.unreadNotificationCount;
            return Stack(
              children: [
                TextButton(
                  onPressed: () => _onNavItemTapped(2),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      color: _selectedIndex == 2 ? AppTheme.primaryBlue : AppTheme.mediumGray,
                      fontWeight: _selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        TextButton(
          onPressed: () => _onNavItemTapped(3),
          child: Text(
            'Profile',
            style: TextStyle(
              color: _selectedIndex == 3 ? AppTheme.primaryBlue : AppTheme.mediumGray,
              fontWeight: _selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _onLogout,
          tooltip: 'Logout',
        ),
        const SizedBox(width: AppTheme.md),
      ],
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.white,
                  child: Text(
                    user.initials,
                    style: AppTheme.h3.copyWith(color: AppTheme.primaryBlue),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                Text(
                  'Welcome, ${user.organizationName}',
                  style: AppTheme.h3.copyWith(color: AppTheme.white),
                ),
                Text(
                  user.email,
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Browse Lands'),
            selected: _selectedIndex == 0,
            onTap: () {
              _onNavItemTapped(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.handshake),
            title: const Text('Matches'),
            selected: _selectedIndex == 1,
            onTap: () {
              _onNavItemTapped(1);
              Navigator.pop(context);
            },
          ),
          Consumer<AppState>(
            builder: (context, appState, _) {
              return ListTile(
                leading: Badge(
                  isLabelVisible: appState.unreadNotificationCount > 0,
                  label: Text('${appState.unreadNotificationCount}'),
                  child: const Icon(Icons.notifications),
                ),
                title: const Text('Notifications'),
                selected: _selectedIndex == 2,
                onTap: () {
                  _onNavItemTapped(2);
                  Navigator.pop(context);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Profile'),
            selected: _selectedIndex == 3,
            onTap: () {
              _onNavItemTapped(3);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorRed),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _onLogout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AppState appState) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onNavItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: AppTheme.mediumGray,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Browse',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.handshake),
          label: 'Matches',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: appState.unreadNotificationCount > 0,
            label: Text('${appState.unreadNotificationCount}'),
            child: const Icon(Icons.notifications),
          ),
          label: 'Notifications',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildBody(AppState appState) {
    switch (_selectedIndex) {
      case 0:
        return _buildBrowseLandsTab(appState);
      case 1:
        return const OrgMatchesScreen();
      case 2:
        return const NotificationsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildBrowseLandsTab(appState);
    }
  }

  Widget _buildBrowseLandsTab(AppState appState) {
    final hasFilters = _selectedCountyFilter != null ||
        _selectedRestorationTypeFilter != null ||
        _minSize != null ||
        _maxSize != null;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available Lands', style: AppTheme.h3),
                Row(
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Acres')),
                        ButtonSegment(value: false, label: Text('Hectares')),
                      ],
                      selected: {_showInAcres},
                      onSelectionChanged: (Set<bool> selection) {
                        setState(() => _showInAcres = selection.first);
                      },
                    ),
                    const SizedBox(width: AppTheme.sm),
                    IconButton(
                      icon: Badge(
                        isLabelVisible: hasFilters,
                        child: const Icon(Icons.filter_list),
                      ),
                      onPressed: _showFilters,
                      tooltip: 'Filters',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.md),

            if (appState.landListings.isEmpty)
              Expanded(child: _buildEmptyState())
            else
              Expanded(child: _buildLandGrid(appState)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.landscape, size: 80, color: AppTheme.lightGray),
          const SizedBox(height: AppTheme.md),
          Text(
            'No lands available',
            style: AppTheme.h3.copyWith(color: AppTheme.mediumGray),
          ),
          const SizedBox(height: AppTheme.sm),
          Text(
            'Try adjusting your filters',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.mediumGray),
          ),
        ],
      ),
    );
  }

  Widget _buildLandGrid(AppState appState) {
    // Check if already requested
    final requestedLandIds = appState.matchRequests
        .map((r) => r.landListingId)
        .toSet();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.1,
        crossAxisSpacing: AppTheme.md,
        mainAxisSpacing: AppTheme.md,
      ),
      itemCount: appState.landListings.length,
      itemBuilder: (context, index) {
        final land = appState.landListings[index];
        final alreadyRequested = requestedLandIds.contains(land.id);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryBlueLight,
                      child: Text(
                        land.userName?.split(' ').map((n) => n[0]).take(2).join() ?? 'U',
                        style: const TextStyle(color: AppTheme.primaryBlue),
                      ),
                    ),
                    const SizedBox(width: AppTheme.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            land.userName ?? 'Unknown',
                            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${land.countyName}, ${land.subcountyName}',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.md),
                Text(
                  land.title,
                  style: AppTheme.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.sm),
                Text(
                  _showInAcres
                      ? '${land.sizeAcres} acres'
                      : '${land.sizeHectares} hectares',
                  style: AppTheme.bodyLarge,
                ),
                Text(
                  land.restorationTypes.map((t) => t.displayName).join(', '),
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.mediumGray),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (alreadyRequested)
                  const Chip(
                    label: Text('REQUEST SENT'),
                    backgroundColor: AppTheme.mediumGray,
                    labelStyle: TextStyle(color: AppTheme.white, fontSize: 12),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _requestCollaboration(appState, land.id),
                      child: const Text('Request Collaboration'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestCollaboration(AppState appState, int landId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Collaboration?'),
        content: const Text('Send a collaboration request for this land?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await appState.createMatchRequest(landId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully')),
        );
      } else {
        ErrorDialog.show(context, appState.errorMessage ?? 'Failed to send request');
      }
    }
  }
}

// Filter Sheet Widget
class _FilterSheet extends StatefulWidget {
  final int? selectedCounty;
  final String? selectedRestorationType;
  final double? minSize;
  final double? maxSize;
  final Function(int?, String?, double?, double?) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    this.selectedCounty,
    this.selectedRestorationType,
    this.minSize,
    this.maxSize,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final ApiService _apiService = ApiService();
  List<County> _counties = [];
  final _restorationTypes = ['forest', 'agroforestry', 'wetlands', 'mangroves'];
  
  int? _selectedCounty;
  String? _selectedType;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCounty = widget.selectedCounty;
    _selectedType = widget.selectedRestorationType;
    if (widget.minSize != null) _minController.text = widget.minSize.toString();
    if (widget.maxSize != null) _maxController.text = widget.maxSize.toString();
    _loadCounties();
  }

  Future<void> _loadCounties() async {
    try {
      final counties = await _apiService.getCounties();
      setState(() {
        _counties = counties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppTheme.lg,
        right: AppTheme.lg,
        top: AppTheme.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTheme.h3),
              TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),

          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'County'),
            value: _selectedCounty,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Counties')),
              ..._counties.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (value) => setState(() => _selectedCounty = value),
          ),
          const SizedBox(height: AppTheme.md),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Restoration Type'),
            value: _selectedType,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Types')),
              ..._restorationTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))),
            ],
            onChanged: (value) => setState(() => _selectedType = value),
          ),
          const SizedBox(height: AppTheme.md),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  decoration: const InputDecoration(labelText: 'Min Size (acres)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppTheme.md),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  decoration: const InputDecoration(labelText: 'Max Size (acres)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final min = double.tryParse(_minController.text);
                final max = double.tryParse(_maxController.text);
                widget.onApply(_selectedCounty, _selectedType, min, max);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: AppTheme.lg),
        ],
      ),
    );
  }
}