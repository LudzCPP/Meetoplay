import 'package:flutter/material.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TableCalendar(
          availableCalendarFormats: const {CalendarFormat.month: 'xd'},
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: orange, shape: BoxShape.circle),
            tableBorder: TableBorder(
                // horizontalInside: BorderSide(color: Colors.black),
                // verticalInside: BorderSide(color: Colors.black),
                ),
            weekendTextStyle: TextStyle(color: Colors.white),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: pink,
              ),
              weekendStyle: TextStyle(
                color: pink,
              )),
          daysOfWeekHeight: 30,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
        ),
      ),
    );
  }
}
