import 'package:add_2_calendar/add_2_calendar.dart' as calendar;
import '../models/event.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  Future<bool> addEventToCalendar(Event event) async {
    try {
      final eventToAdd = calendar.Event(
        title: event.title,
        description: event.description,
        location: event.location,
        startDate: event.startTime,
        endDate: event.endTime,
        allDay: false,
        iosParams: calendar.IOSParams(
          reminder: const Duration(minutes: 15),
        ),
        androidParams: calendar.AndroidParams(
          emailInvites: [],
        ),
      );

      return await calendar.Add2Calendar.addEvent2Cal(eventToAdd);
    } catch (e) {
      return false;
    }
  }
}
