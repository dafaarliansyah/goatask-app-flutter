// calendar_service.dart

import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:url_launcher/url_launcher.dart';
import 'package:todo_app_with_firebase/models/todo.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Tambahkan package google_sign_in
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:todo_app_with_firebase/services/access_token_auth_client.dart';


final _scopes = [calendar.CalendarApi.calendarScope];

// Inisialisasi Google Sign-In
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: _scopes,
);

Future<calendar.CalendarApi?> getCalendarApi() async {
  try {
    // Sign in dengan Google Sign-In
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount == null) {
      print('User did not sign in.');
      return null;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    // Dapatkan access token
    final accessToken = googleSignInAuthentication.accessToken;

    if (accessToken == null) {
      print('No access token obtained.');
      return null;
    }

    // Buat OAuth2Client dengan access token
    final authClient = AccessTokenAuthClient(
      AccessToken(
        'Bearer',
        accessToken,
        DateTime.now().toUtc().add(Duration(hours: 1))
      ),
    );

    // Buat instance Calendar API
    return calendar.CalendarApi(authClient);
  } catch (e) {
    print('Error during authentication: $e');
    return null;
  }
}

// Fungsi prompt tidak diperlukan lagi
void prompt(String url) async {
  print('Please go to the following URL and grant access:');
  print(url);
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    print('Could not launch $url');
  }
}

Future<void> addEventToCalendar(Todo todo) async {
  final calendarApi = await getCalendarApi();
  if (calendarApi == null) {
    print('Calendar API not initialized.');
    return;
  }

  final event = calendar.Event(
    summary: todo.title,
    description: todo.description,
    start: calendar.EventDateTime(dateTime: todo.dueDate, timeZone: 'UTC'),
    end: calendar.EventDateTime(dateTime: todo.dueDate.add(Duration(hours: 1)), timeZone: 'UTC'),
  );

  try {
    final calendarId = 'primary';
    final result = await calendarApi.events.insert(event, calendarId);
    print('Event added to calendar: ${result.id}');
    // Simpan event ID ke dalam Todo object Anda
  } catch (e) {
    print('Error adding event to calendar: $e');
  }
}

Future<void> updateEventInCalendar(Todo todo) async {
  final calendarApi = await getCalendarApi();
  if (calendarApi == null) {
    print('Calendar API not initialized.');
    return;
  }

  final event = calendar.Event(
    summary: todo.title,
    description: todo.description,
    start: calendar.EventDateTime(dateTime: todo.dueDate, timeZone: 'UTC'),
    end: calendar.EventDateTime(dateTime: todo.dueDate.add(Duration(hours: 1)), timeZone: 'UTC'),
  );

  try {
    final calendarId = 'primary';
    await calendarApi.events.update(event, calendarId, todo.calendarEventId!);
    print('Event updated in calendar: ${todo.calendarEventId}');
  } catch (e) {
    print('Error updating event in calendar: $e');
  }
}

Future<void> deleteEventFromCalendar(String calendarEventId) async {
  final calendarApi = await getCalendarApi();
  if (calendarApi == null) {
    print('Calendar API not initialized.');
    return;
  }

  try {
    final calendarId = 'primary';
    await calendarApi.events.delete(calendarId, calendarEventId);
    print('Event deleted from calendar: $calendarEventId');
  } catch (e) {
    print('Error deleting event from calendar: $e');
  }
}

