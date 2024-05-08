import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  List<String> _selectedEvents = [];
  Map<DateTime, List<String>> _allEvents = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    DateTime now = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    _allEvents = {
      now: ['Spotkanie biznesowe'],
      now.add(const Duration(days: 2)): [
        'Wycieczka szkolna',
        'Spotkanie klubu książki'
      ],
      now.add(const Duration(days: 3)): ['Urodziny przyjaciela'],
    };
    _selectedEvents = _getEventsForDay(_selectedDay);
  }

  List<String> _getEventsForDay(DateTime day) {
    List<String> meetings = [];

    for (var meeting in globalMeetings){
      if(meeting.date == '${day.day}/${day.month}/${day.year}'){
          meetings.add(meeting.name);
      }
    }
    return meetings;
    //return _allEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Card(
              color: darkBlue,
              margin: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                calendarStyle: const CalendarStyle(
                  todayDecoration:
                      BoxDecoration(color: darkBlue, shape: BoxShape.circle),
                  selectedDecoration:
                      BoxDecoration(color: lightBlue, shape: BoxShape.circle),
                  markerDecoration:
                      BoxDecoration(color: pink, shape: BoxShape.circle),
                  weekendTextStyle: TextStyle(color: Colors.blueGrey),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: pink,
                    ),
                    weekendStyle: TextStyle(
                      color: pink,
                    )),
                daysOfWeekHeight: 30,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                       print("Kliknięto wydarzenie: ${_selectedEvents[index]}");
                    },
                    child: ListTile(
                      title: Text(_selectedEvents[index],
                          style: const TextStyle(color: Colors.white)),
                      tileColor: lightBlue,
                      leading: const Icon(Icons.event, color: Colors.orange),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
