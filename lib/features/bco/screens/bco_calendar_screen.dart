import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme.dart';

class BcoCalendarScreen extends StatefulWidget {
  const BcoCalendarScreen({super.key});

  @override
  State<BcoCalendarScreen> createState() => _BcoCalendarScreenState();
}

class _BcoCalendarScreenState extends State<BcoCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Dummy events
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _generateDummyEvents();
  }

  void _generateDummyEvents() {
    final today = DateTime.now();
    _events = {
      DateTime(today.year, today.month, today.day): [
        {
          'title': 'Site Inspection - Plot 19',
          'time': '10:30 AM',
          'type': 'Foundation',
          'status': 'Pending'
        },
        {
          'title': 'General Quality Check',
          'time': '02:00 PM',
          'type': 'Roofing',
          'status': 'Approved'
        },
      ],
      DateTime(today.year, today.month, today.day).add(const Duration(days: 1)): [
        {
          'title': 'Wall Structural Test',
          'time': '09:00 AM',
          'type': 'Walls',
          'status': 'Pending'
        },
      ],
      DateTime(today.year, today.month, today.day).subtract(const Duration(days: 2)): [
        {
          'title': 'Electrical Wiring Inspection',
          'time': '11:15 AM',
          'type': 'Electrical',
          'status': 'Deferred'
        },
      ],
      DateTime(today.year, today.month, today.day).add(const Duration(days: 3)): [
        {
          'title': 'Plumbing Phase 1',
          'time': '01:30 PM',
          'type': 'Plumbing',
          'status': 'Pending'
        },
      ],
    };
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Exact match for day ignoring time
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Calendar', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppTheme.primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonTextStyle: TextStyle(color: AppTheme.primaryGreen, fontSize: 12),
                formatButtonDecoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide(color: AppTheme.primaryGreen)),
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'INSPECTIONS (${selectedEvents.length})',
                style: const TextStyle(
                  fontSize: 12,
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
                    child: Text('No inspections scheduled for this day.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.assignment, color: AppTheme.primaryGreen),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'],
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(event['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          event['type'],
                                          style: const TextStyle(fontSize: 12, color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: event['status'] == 'Approved' 
                                    ? Colors.green.withOpacity(0.1) 
                                    : event['status'] == 'Deferred' 
                                      ? Colors.red.withOpacity(0.1) 
                                      : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                event['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: event['status'] == 'Approved' 
                                      ? Colors.green 
                                      : event['status'] == 'Deferred' 
                                        ? Colors.red 
                                        : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
