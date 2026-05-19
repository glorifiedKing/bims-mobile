import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../../core/models/auxiliary/whistle_blower_category.dart';
import '../../../core/models/auxiliary/admin_unit.dart';
import '../../../core/models/auxiliary/admin_unit_type.dart';
import '../../auth/bloc/bco_auth_bloc.dart';
import '../../auth/bloc/bco_auth_state.dart';
import '../bloc/whistleblows/bco_whistleblows_bloc.dart';
import '../bloc/whistleblows/bco_whistleblows_event.dart';
import '../bloc/whistleblows/bco_whistleblows_state.dart';

class BcoWhistleblowsScreen extends StatefulWidget {
  const BcoWhistleblowsScreen({super.key});

  @override
  State<BcoWhistleblowsScreen> createState() => _BcoWhistleblowsScreenState();
}

class _BcoWhistleblowsScreenState extends State<BcoWhistleblowsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String? _selectedFeedbackType;
  String? _selectedAdminUnitTypeId;
  String? _selectedAdminUnitId;

  List<WhistleBlowerCategory> _categories = [];
  List<AdminUnitType> _adminUnitTypes = [];
  List<AdminUnit> _adminUnits = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFilters();
    _fetchData();
  }

  void _loadFilters() {
    final auxRepo = context.read<AuxiliaryRepository>();
    setState(() {
      _categories = auxRepo.getWhistleBlowerCategories();
      _adminUnitTypes = auxRepo.getAdminUnitTypes();
    });
  }

  void _onAdminUnitTypeSelected(String? val) {
    setState(() {
      _selectedAdminUnitTypeId = val;
      _selectedAdminUnitId = null;
      if (val != null) {
        _adminUnits = context.read<AuxiliaryRepository>().getAdminUnits(int.parse(val));
      } else {
        _adminUnits = [];
      }
    });
    _fetchData();
  }

  void _fetchData({bool isRefresh = false}) {
    context.read<BcoWhistleblowsBloc>().add(
          FetchBcoWhistleblows(
            isRefresh: isRefresh,
            feedbackType: _selectedFeedbackType,
            adminUnitId: _selectedAdminUnitId,
            search: _searchController.text.trim(),
          ),
        );
  }

  void _onSearchChanged(String query) {
    setState(() {});
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _fetchData();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedFeedbackType = null;
      _selectedAdminUnitTypeId = null;
      _selectedAdminUnitId = null;
      _adminUnits = [];
    });
    _fetchData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BcoWhistleblowsBloc>().add(LoadMoreBcoWhistleblows());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Inspector Header
          BlocBuilder<BcoAuthBloc, BcoAuthState>(
            builder: (context, state) {
              String name = 'Officer';
              String roleName = 'BUILDING CONTROL OFFICER';
              String adminUnitName = 'NBRB';

              if (state is BcoAuthAuthenticated) {
                final user = state.user;
                name = user.names;
                roleName = user.role;
                if (user.administrativeUnitName.isNotEmpty) {
                  adminUnitName = user.administrativeUnitName;
                }
              }

              return Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 20,
                  left: 25,
                  right: 25,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00331a), AppTheme.primaryGreen],
                  ),
                  border: Border(
                    bottom: BorderSide(color: AppTheme.accentGold, width: 4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roleName.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.campaign,
                                size: 14,
                                color: AppTheme.accentGold,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'WHISTLEBLOWS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: "Location: "),
                          TextSpan(
                            text: adminUnitName,
                            style: const TextStyle(color: AppTheme.accentGold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Filters & Search section
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by location, name, email...',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: (_searchController.text.isNotEmpty ||
                            _selectedFeedbackType != null ||
                            _selectedAdminUnitTypeId != null ||
                            _selectedAdminUnitId != null)
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                            onPressed: _resetFilters,
                            tooltip: 'Reset Filters',
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Category', style: TextStyle(fontSize: 12)),
                            value: _selectedFeedbackType,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Categories', style: TextStyle(fontSize: 12))),
                              ..._categories.map((c) => DropdownMenuItem(
                                    value: c.id.toString(),
                                    child: Text(c.name, style: const TextStyle(fontSize: 12)),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedFeedbackType = val);
                              _fetchData();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Unit Type', style: TextStyle(fontSize: 12)),
                            value: _selectedAdminUnitTypeId,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Types', style: TextStyle(fontSize: 12))),
                              ..._adminUnitTypes.map((u) => DropdownMenuItem(
                                    value: u.id.toString(),
                                    child: Text(
                                      u.name.length > 20 ? '${u.name.substring(0, 20)}...' : u.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )),
                            ],
                            onChanged: _onAdminUnitTypeSelected,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Admin Unit', style: TextStyle(fontSize: 12)),
                            value: _selectedAdminUnitId,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('All Units', style: TextStyle(fontSize: 12))),
                              ..._adminUnits.map((u) => DropdownMenuItem(
                                    value: u.id.toString(),
                                    child: Text(
                                      u.name.length > 20 ? '${u.name.substring(0, 20)}...' : u.name,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  )),
                            ],
                            onChanged: (val) {
                              setState(() => _selectedAdminUnitId = val);
                              _fetchData();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _fetchData(isRefresh: true),
              child: BlocBuilder<BcoWhistleblowsBloc, BcoWhistleblowsState>(
                builder: (context, state) {
                  if (state is BcoWhistleblowsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is BcoWhistleblowsError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                          TextButton(
                            onPressed: _fetchData,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    );
                  }

                  if (state is BcoWhistleblowsLoaded) {
                    if (state.whistleblows.isEmpty) {
                      return const Center(child: Text('No reports found.', style: TextStyle(color: Colors.grey)));
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(15),
                      itemCount: state.whistleblows.length + (state.hasReachedMax ? 0 : 1),
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        if (index >= state.whistleblows.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final report = state.whistleblows[index];
                        return InkWell(
                          onTap: () {
                            context.push('/bco/whistleblows/${report.reference}');
                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF4F4),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        report.feedbackType,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.danger,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      report.createdAt.split('T').first,
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  report.location.isNotEmpty ? report.location : 'No Location Provided',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        report.name,
                                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.location_city, size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        '${report.administrativeUnitType} - ${report.administrativeUnitName}',
                                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
