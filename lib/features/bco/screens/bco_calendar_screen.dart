import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme.dart';
import '../../../core/repositories/auxiliary_repository.dart';
import '../../auth/bloc/bco_auth_bloc.dart';
import '../../auth/bloc/bco_auth_state.dart';
import '../bloc/inspections/bco_inspections_bloc.dart';
import '../bloc/inspections/bco_inspections_event.dart';
import '../bloc/inspections/bco_inspections_state.dart';
import '../models/bco_inspection_model.dart';
import 'package:intl/intl.dart';
import '../../../core/help/help_controller.dart';
import '../../../core/help/help_step.dart';
import '../../../core/help/help_tour_overlay.dart';
import '../../../core/help/help_preferences.dart';

class BcoCalendarScreen extends StatefulWidget {
  const BcoCalendarScreen({super.key});

  @override
  State<BcoCalendarScreen> createState() => _BcoCalendarScreenState();
}

class _BcoCalendarScreenState extends State<BcoCalendarScreen> {
  bool _isCalendarView = true;

  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Filter state (list view)
  int? _selectedStatusId;
  int? _selectedTypeId;

  // ── Help tour ──
  final _helpController = HelpController();
  final _keyToggle    = GlobalKey();
  final _keyBottomNav = GlobalKey();

  List<HelpStep> get _helpSteps => [
    HelpStep(
      emoji: '🗓️',
      title: 'Inspections View',
      description:
          'This screen shows all your scheduled inspections. '
          'Switch between a visual Calendar view and a scrollable List view.',
    ),
    HelpStep(
      emoji: '🔀',
      title: 'Calendar ↕ List Toggle',
      description:
          'Tap "📅 Calendar" to see inspections plotted on a monthly calendar. '
          'Tap "☰ List" to see all inspections in a scrollable list with filters.',
      targetKey: _keyToggle,
      cardPosition: HelpCardPosition.bottom,
    ),
    HelpStep(
      emoji: '🔍',
      title: 'Filters (List View)',
      description:
          'In List view, use the filter dropdowns at the top to narrow down '
          'inspections by type or status.',
    ),
    HelpStep(
      emoji: '📌',
      title: 'Inspection Cards',
      description:
          'Each card shows the application reference, location, date/time '
          'and current status. Tap a card to open its full details.',
    ),
    HelpStep(
      emoji: '🧭',
      title: 'Bottom Navigation',
      description:
          'Use the bottom bar to switch between Home, Applications, '
          'Invoices, and Profile.',
      targetKey: _keyBottomNav,
      cardPosition: HelpCardPosition.top,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCalendarMonth(_focusedDay);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seen = await HelpPreferences.hasSeenTour('tour_bco_calendar');
      if (!seen && mounted) {
        await HelpPreferences.markTourSeen('tour_bco_calendar');
        _helpController.start(_helpSteps);
      }
    });
  }

  @override
  void dispose() {
    _helpController.dispose();
    super.dispose();
  }

  void _loadCalendarMonth(DateTime month) {
    final start = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime(month.year, month.month, 1));
    final end = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime(month.year, month.month + 1, 0));
    context.read<BcoInspectionsBloc>().add(
      FetchBcoInspections(start: start, end: end, isRefresh: true),
    );
  }

  void _loadListView() {
    context.read<BcoInspectionsBloc>().add(
      FetchBcoInspections(
        inspectionTypeId: _selectedTypeId,
        inspectionStatusId: _selectedStatusId,
        isRefresh: true,
      ),
    );
  }

  void _switchView(bool toCalendar) {
    if (toCalendar == _isCalendarView) return;
    setState(() => _isCalendarView = toCalendar);
    if (toCalendar) {
      _loadCalendarMonth(_focusedDay);
    } else {
      _loadListView();
    }
  }

  Map<DateTime, List<BcoInspectionModel>> _buildEventMap(
    List<BcoInspectionModel> inspections,
  ) {
    final map = <DateTime, List<BcoInspectionModel>>{};
    for (final insp in inspections) {
      final day = DateTime(insp.start.year, insp.start.month, insp.start.day);
      map.putIfAbsent(day, () => []).add(insp);
    }
    return map;
  }

  List<BcoInspectionModel> _getEventsForDay(
    DateTime day,
    List<BcoInspectionModel> inspections,
  ) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _buildEventMap(inspections)[normalized] ?? [];
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'RE-SCHEDULED':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Color _statusBg(String status) => _statusColor(status).withOpacity(0.12);

  @override
  Widget build(BuildContext context) {
    return HelpTourOverlay(
      controller: _helpController,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F2F0),
        body: Column(
          children: [
            // Header
            BlocBuilder<BcoAuthBloc, BcoAuthState>(
            builder: (context, authState) {
              String name = 'Officer';
              String roleName = 'BUILDING CONTROL OFFICER';
              String adminUnitName = 'NBRB';

              if (authState is BcoAuthAuthenticated) {
                final user = authState.user;
                name = user.names;
                roleName = user.role;
                if (user.administrativeUnitName.isNotEmpty) {
                  adminUnitName = user.administrativeUnitName;
                }
              }

              return Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 0,
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
                        // Help + Inspections pill row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HelpIconButton(
                              controller: _helpController,
                              steps: _helpSteps,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 14,
                                    color: AppTheme.accentGold,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'INSPECTIONS',
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: 'Location: '),
                          TextSpan(
                            text: adminUnitName,
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Toggle bar inside header
                    KeyedSubtree(
                      key: _keyToggle,
                      child: _buildToggleBar(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            },
          ),

          // Body
          Expanded(
            child: BlocBuilder<BcoInspectionsBloc, BcoInspectionsState>(
              builder: (context, state) {
                if (state is BcoInspectionsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BcoInspectionsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _isCalendarView
                              ? _loadCalendarMonth(_focusedDay)
                              : _loadListView(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final inspections = state is BcoInspectionsLoaded
                    ? state.inspections
                    : <BcoInspectionModel>[];

                return _isCalendarView
                    ? _buildCalendarView(inspections)
                    : _buildListView(inspections, state);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        key: _keyBottomNav,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/bco/dashboard');
          if (index == 1) context.go('/bco/applications');
          if (index == 2) context.go('/bco/invoices');
          if (index == 3) context.go('/bco/profile');
        },
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      ),   // Scaffold
    );     // HelpTourOverlay
  }

  Widget _buildToggleBar() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleBtn('📅  Calendar', true)),
          Expanded(child: _toggleBtn('☰  List', false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool isCalendar) {
    final active = _isCalendarView == isCalendar;
    return GestureDetector(
      onTap: () => _switchView(isCalendar),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? AppTheme.primaryGreen : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(List<BcoInspectionModel> inspections) {
    final selectedEvents = _getEventsForDay(
      _selectedDay ?? _focusedDay,
      inspections,
    );

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TableCalendar<BcoInspectionModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) => _getEventsForDay(day, inspections),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
              _loadCalendarMonth(focused);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.accentGold,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: AppTheme.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonTextStyle: TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 12,
              ),
              formatButtonDecoration: BoxDecoration(
                border: Border.fromBorderSide(
                  BorderSide(color: AppTheme.primaryGreen),
                ),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'INSPECTIONS (${selectedEvents.length})',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        Expanded(
          child: selectedEvents.isEmpty
              ? const Center(
                  child: Text(
                    'No inspections scheduled for this day.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 20,
                  ),
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) =>
                      _buildInspectionCard(selectedEvents[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildListView(
    List<BcoInspectionModel> inspections,
    BcoInspectionsState state,
  ) {
    final auxRepo = context.read<AuxiliaryRepository>();
    final types = auxRepo.getInspectionTypes();
    final statuses = auxRepo.getInspectionStatuses();

    return Column(
      children: [
        // Filter bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All', null == _selectedStatusId, () {
                      setState(() => _selectedStatusId = null);
                      _loadListView();
                    }),
                    ...statuses.map((s) {
                      final id = s.id;
                      return _filterChip(s.name, _selectedStatusId == id, () {
                        setState(() => _selectedStatusId = id);
                        _loadListView();
                      });
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Type dropdown
              if (types.isNotEmpty)
                DropdownButtonFormField<int?>(
                  value: _selectedTypeId,
                  decoration: InputDecoration(
                    labelText: 'Inspection Type',
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...types.map(
                      (t) => DropdownMenuItem<int?>(
                        value: t.id,
                        child: Text(t.name),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedTypeId = val);
                    _loadListView();
                  },
                ),
            ],
          ),
        ),
        // List
        Expanded(
          child: inspections.isEmpty
              ? const Center(
                  child: Text(
                    'No inspections found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    top: 8,
                  ),
                  itemCount:
                      inspections.length +
                      (state is BcoInspectionsLoaded && !state.hasReachedMax
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index == inspections.length) {
                      context.read<BcoInspectionsBloc>().add(
                        LoadMoreBcoInspections(),
                      );
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildInspectionCard(inspections[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryGreen : const Color(0xFFF0F2F0),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryGreen : const Color(0xFFCCCCCC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildInspectionCard(BcoInspectionModel inspection) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, dd MMM yyyy');
    final statusColor = _statusColor(inspection.inspectionStatus);
    final statusBg = _statusBg(inspection.inspectionStatus);

    return GestureDetector(
      onTap: () {
        context.push('/bco/inspections/${inspection.inspectionRef}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      inspection.applicantName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      inspection.inspectionStatus,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dateFormat.format(inspection.start),
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 13,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${timeFormat.format(inspection.start)} – ${timeFormat.format(inspection.end)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      inspection.location,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inspection.inspectionType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  Text(
                    '#${inspection.applicationKey}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
