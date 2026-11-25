import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // sqflite_common_ffi runs SQLite on this computer instead of Android.
  sqfliteFfiInit();

  setUp(() async {
    // A fresh in-memory database for each test, with an empty bookings table
    // (createTables does not add the sample bookings).
    final Database db =
        await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await CinemaDatabase.instance.createTables(db, 1);
    CinemaDatabase.instance.setDatabase(db);
  });

  tearDown(() async {
    // Close after each test so no data leaks into the next one.
    await CinemaDatabase.instance.close();
  });

  Booking buildBooking(int bookingNumber, String summary, double total) {
    return Booking(
      bookingNumber: bookingNumber,
      summary: summary,
      total: total,
      date: '01/01/2026 10:00',
    );
  }

  test('insertBooking stores a booking and returns its id', () async {
    final int id = await CinemaDatabase.instance.insertBooking(
      buildBooking(1001, '1 x Repo Man', 9.50),
    );
    expect(id, greaterThan(0));

    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();
    expect(bookings.length, 1);
    expect(bookings[0].id, id);
    expect(bookings[0].summary, '1 x Repo Man');
    expect(bookings[0].total, 9.50);
  });

  test('getNextBookingNumber increments the current maximum', () async {
    expect(await CinemaDatabase.instance.getNextBookingNumber(), 1001);

    await CinemaDatabase.instance.insertBooking(
      buildBooking(1005, 'Booking', 5.0),
    );
    expect(await CinemaDatabase.instance.getNextBookingNumber(), 1006);
  });

  test('getAllBookings returns newest booking number first', () async {
    await CinemaDatabase.instance.insertBooking(
      buildBooking(1001, 'First', 5.0),
    );
    await CinemaDatabase.instance.insertBooking(
      buildBooking(1003, 'Third', 9.0),
    );
    await CinemaDatabase.instance.insertBooking(
      buildBooking(1002, 'Second', 7.0),
    );

    final List<Booking> bookings =
        await CinemaDatabase.instance.getAllBookings();
    expect(bookings[0].bookingNumber, 1003);
    expect(bookings[1].bookingNumber, 1002);
    expect(bookings[2].bookingNumber, 1001);
  });
}
