import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/booking.dart';

void main() {
  group('Booking', () {
    test('constructor assigns every field', () {
      const Booking booking = Booking(
        id: 1,
        bookingNumber: 1001,
        summary: '2 x Repo Man',
        total: 19.00,
        date: '2026-11-27T19:30:00.000',
      );

      expect(booking.id, 1);
      expect(booking.bookingNumber, 1001);
      expect(booking.summary, '2 x Repo Man');
      expect(booking.total, 19.00);
      expect(booking.date, '2026-11-27T19:30:00.000');
    });

    test('id is null for a new booking that has not been saved', () {
      const Booking booking = Booking(
        bookingNumber: 1002,
        summary: '1 x Paranormal Activity',
        total: 7.00,
        date: '2026-11-28T21:45:00.000',
      );

      expect(booking.id, isNull);
      expect(booking.bookingNumber, 1002);
      expect(booking.summary, '1 x Paranormal Activity');
      expect(booking.total, 7.00);
      expect(booking.date, '2026-11-28T21:45:00.000');
    });

    test('summary can describe several films on one booking', () {
      const Booking booking = Booking(
        bookingNumber: 1003,
        summary: '2 x Repo Man, 1 x Paranormal Activity',
        total: 26.00,
        date: '2026-11-27T19:30:00.000',
      );

      expect(booking.summary, '2 x Repo Man, 1 x Paranormal Activity');
      expect(booking.total, 26.00);
    });

    test('total keeps pence', () {
      const Booking booking = Booking(
        bookingNumber: 1004,
        summary: '1 x Repo Man',
        total: 9.50,
        date: '2026-11-27T19:30:00.000',
      );

      expect(booking.total, isA<double>());
      expect(booking.total, 9.50);
    });

    test('bookings with different numbers keep their own values', () {
      const Booking first = Booking(
        id: 1,
        bookingNumber: 1,
        summary: '1 x Repo Man',
        total: 9.50,
        date: '2026-11-27T19:30:00.000',
      );
      const Booking second = Booking(
        id: 2,
        bookingNumber: 2,
        summary: '1 x Paranormal Activity',
        total: 7.00,
        date: '2026-11-28T21:45:00.000',
      );

      expect(first.id, 1);
      expect(first.bookingNumber, 1);
      expect(second.id, 2);
      expect(second.bookingNumber, 2);
      expect(first.summary, isNot(second.summary));
    });
  });
}
