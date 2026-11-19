import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
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

  void _removeTickets(CartItem item) {
    setState(() {
      BasketRepository.instance.removeTickets(item.movie);
    });
  }

  void _buyTickets() {
    final BasketRepository basket = BasketRepository.instance;
    final int tickets = basket.totalQuantity;
    final String total = _formatPrice(basket.totalDue);
    setState(() {
      basket.clear();
      _confirmationMessage =
          'Thank you! Your order for $tickets tickets ($total) has been placed.';
    });
  }

  void _updateOrder() {
    // back to the home page to change the tickets
    Navigator.pushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final BasketRepository basket = BasketRepository.instance;
    final List<CartItem> items = basket.items;

    final Widget content;
    if (items.isEmpty) {
      if (_confirmationMessage.isNotEmpty) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _EmptyBasket(),
            const SizedBox(height: 16),
            Text(
              _confirmationMessage,
              style: const TextStyle(color: cinemaBrand, fontSize: 16),
            ),
          ],
        );
      } else {
        content = const _EmptyBasket();
      }
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BasketHeader(),
          const SizedBox(height: 12),
          for (final CartItem item in items)
            _BasketRow(
              item: item,
              onDelete: () => _removeTickets(item),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Charge',
                style: TextStyle(color: cinemaFontWhite, fontSize: 16),
              ),
              Text(
                _formatPrice(basket.serviceCharge),
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
                _formatPrice(basket.totalDue),
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
              PrimaryButton(label: 'UPDATE ORDER', onPressed: _updateOrder),
              PrimaryButton(label: 'BUY TICKETS', onPressed: _buyTickets),
            ],
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MY ORDER',
              style: TextStyle(
                color: cinemaFontWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            content,
          ],
        ),
      ),
    );
  }
}

String _formatPrice(double price) {
  return '£${price.toStringAsFixed(2)}';
}

class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Your basket is empty.',
      style: TextStyle(color: cinemaFontWhite, fontSize: 16),
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
