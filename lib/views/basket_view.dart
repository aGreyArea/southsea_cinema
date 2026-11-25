import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/database/cinema_db.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/repositories/basket_repository.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class BasketView extends StatefulWidget {
  const BasketView({super.key});

  @override
  State<BasketView> createState() {
    return _BasketViewState();
  }
}

class _BasketViewState extends State<BasketView> {
  String _confirmationMessage = '';

  // past bookings shown below the basket
  List<Booking> _bookings = [];
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final List<Booking> bookings =
          await CinemaDatabase.instance.getAllBookings();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookings = bookings;
        _loading = false;
        _errorMessage = '';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Could not load your bookings: $error';
      });
    }
  }

  void _removeTickets(CartItem item) {
    setState(() {
      BasketRepository.instance.removeTickets(item.movie);
    });
  }

  String _buildSummary(List<CartItem> items) {
    final List<String> parts = [];
    for (final CartItem item in items) {
      parts.add('${item.quantity} x ${item.movie.name}');
    }
    return parts.join(', ');
  }

  String _formatDate(DateTime now) {
    final String day = now.day.toString().padLeft(2, '0');
    final String month = now.month.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$day/$month/${now.year} $hour:$minute';
  }

  Future<void> _checkout(BasketRepository cart, List<CartItem> items) async {
    final String summary = _buildSummary(items);
    final double total = cart.totalDue;
    final String date = _formatDate(DateTime.now());

    try {
      final CinemaDatabase database = CinemaDatabase.instance;
      final int bookingNumber = await database.getNextBookingNumber();
      final Booking booking = Booking(
        bookingNumber: bookingNumber,
        summary: summary,
        total: total,
        date: date,
      );

      await database.insertBooking(booking);
      cart.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _confirmationMessage = 'Booking $bookingNumber saved';
      });
      await _loadBookings();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _confirmationMessage = 'Could not save your booking: $error';
      });
    }
  }

  void _updateOrder() {
    // back to the home page to change the tickets
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final BasketRepository cart = BasketRepository.instance;
    final List<CartItem> items = cart.getItems();

    final Widget content;
    if (items.isEmpty) {
      content = const _EmptyBasket();
    } else {
      content = _BasketList(
        cart: cart,
        onDelete: _removeTickets,
        onUpdateOrder: _updateOrder,
        onBuyTickets: () => _checkout(cart, items),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            // shown after checkout, or if saving the booking failed
            if (_confirmationMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _confirmationMessage,
                  style: const TextStyle(color: cinemaBrand, fontSize: 16),
                ),
              ),
            const SizedBox(height: 32),
            _PastBookings(
              bookings: _bookings,
              loading: _loading,
              errorMessage: _errorMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// "PAST BOOKINGS" list below the basket, newest booking number first
class _PastBookings extends StatelessWidget {
  final List<Booking> bookings;
  final bool loading;
  final String errorMessage;

  const _PastBookings({
    required this.bookings,
    required this.loading,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(color: cinemaFontWhite, fontSize: 16);

    final Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage.isNotEmpty) {
      body = Text(errorMessage, style: textStyle);
    } else if (bookings.isEmpty) {
      body = const Text('You have no past bookings.', style: textStyle);
    } else {
      body = Column(
        children: [
          for (final Booking booking in bookings)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking ${booking.bookingNumber}',
                          style: const TextStyle(
                            color: cinemaBrand,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(booking.summary, style: textStyle),
                        Text(
                          booking.date,
                          style: const TextStyle(
                            color: cinemaFontMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(_formatPrice(booking.total), style: textStyle),
                ],
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'PAST BOOKINGS',
            style: TextStyle(
              color: cinemaFontWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body,
      ],
    );
  }
}

String _formatPrice(double price) {
  return '£${price.toStringAsFixed(2)}';
}

// "MY ORDER" heading shown at the top of the basket
class _OrderHeading extends StatelessWidget {
  const _OrderHeading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Text(
        'MY ORDER',
        style: TextStyle(
          color: cinemaFontWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// replaces 'Empty basket placeholder'
class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrderHeading(),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Your basket is empty.',
            style: TextStyle(color: cinemaFontWhite, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// replaces 'Basket list placeholder'
class _BasketList extends StatelessWidget {
  final BasketRepository cart;
  final void Function(CartItem item) onDelete;
  final VoidCallback onUpdateOrder;
  final VoidCallback onBuyTickets;

  const _BasketList({
    required this.cart,
    required this.onDelete,
    required this.onUpdateOrder,
    required this.onBuyTickets,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _OrderHeading(),
        const _BasketHeader(),
        const SizedBox(height: 12),
        for (final CartItem item in cart.getItems())
          _BasketRow(
            item: item,
            onDelete: () => onDelete(item),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Service Charge',
              style: TextStyle(color: cinemaFontWhite, fontSize: 16),
            ),
            Text(
              _formatPrice(cart.serviceCharge),
              style: const TextStyle(color: cinemaFontWhite, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Due',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatPrice(cart.totalDue),
              style: const TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            PrimaryButton(label: 'UPDATE ORDER', onPressed: onUpdateOrder),
            PrimaryButton(label: 'BUY TICKETS', onPressed: onBuyTickets),
          ],
        ),
      ],
    );
  }
}

// column headings: Item | Details | Price
class _BasketHeader extends StatelessWidget {
  const _BasketHeader();

  static const TextStyle _style = TextStyle(
    color: cinemaFontWhite,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 2, child: Text('Item', style: _style)),
        Expanded(flex: 4, child: Text('Details', style: _style)),
        Expanded(
          flex: 2,
          child: Text('Price', style: _style, textAlign: TextAlign.right),
        ),
        SizedBox(width: 72), // lines up with the delete buttons below
      ],
    );
  }
}

// one line in the basket, e.g. "2 Tickets | 2 Standard ... | £19.00 | delete"
class _BasketRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onDelete;

  const _BasketRow({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      color: cinemaFontWhite,
      fontSize: 16,
      height: 1.5,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${item.quantity} Tickets',
              style: const TextStyle(
                color: cinemaBrand,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              '${item.quantity} Standard\n'
              '${item.movie.name.toUpperCase()}, ${item.movie.screeningDateTime}, '
              'Southsea Cinema Room',
              style: textStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatPrice(item.lineTotal),
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            height: 60,
            child: ElevatedButton(
              key: Key('delete-${item.movie.id}'),
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: cinemaBrand,
                foregroundColor: cinemaFontWhite,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // square like the site
                ),
              ),
              child: const Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }
}
