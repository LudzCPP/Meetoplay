import 'package:flutter/material.dart';
import 'package:meetoplay/event_details_page.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/models/meetings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<Meeting> _selectedEvents = [];
  final Map<DateTime, List<String>> _allEvents = {};
  bool isInitialized = false; // Flaga inicjalizacji

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL', null).then((_) {
      setState(() {
        _focusedDay = DateTime.now();
        _selectedDay = _focusedDay;
        _selectedEvents = _getEventsForDay(_selectedDay);
        Intl.defaultLocale = 'pl_PL';
        isInitialized = true; // Ustawienie flagi po zakończeniu inicjalizacji
      });
    });
  }

  List<Meeting> _getEventsForDay(DateTime day) {
    List<Meeting> meetings = [];
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    for (var meeting in globalMeetings) {
      if (meeting.date == '${day.day}/${day.month}/${day.year}') {
        if (meeting.participants
            .any((participant) => participant.userId == currentUserId)) {
          meetings.add(meeting);
        }
      }
    }
    return meetings;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay =
          DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
      _focusedDay = focusedDay;
      _selectedEvents = _getEventsForDay(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sprawdź, czy inicjalizacja jest zakończona
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: darkBlue,
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: lightBlue,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBlue,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              color: darkBlue,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: TableCalendar(
                locale: 'pl_PL',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: lightBlue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: pink,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: orange,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.blueGrey),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) => DateFormat.E(locale)
                      .format(date)
                      .substring(0, 3)
                      .replaceAll('.', ''),
                  weekdayStyle: const TextStyle(color: pink),
                  weekendStyle: const TextStyle(color: pink),
                ),
                daysOfWeekHeight: 30,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: white, fontSize: 18),
                  leftChevronIcon: Icon(Icons.chevron_left, color: white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _selectedEvents.isNotEmpty
                  ? ListView.builder(
                      itemCount: _selectedEvents.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: lightBlue,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsPage(
                                      meeting: _selectedEvents[index]),
                                ),
                              );
                            },
                            title: Text(
                              _selectedEvents[index].name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            leading:
                                const Icon(Icons.event, color: Colors.orange),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        'Brak wydarzeń tego dnia.',
                        style: TextStyle(color: white.withOpacity(0.6)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
