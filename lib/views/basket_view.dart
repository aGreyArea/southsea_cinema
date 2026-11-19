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
    final BasketRepository cart = BasketRepository.instance;
    final int tickets = cart.totalQuantity;
    final String total = _formatPrice(cart.totalDue);
    setState(() {
      cart.clear();
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
    final BasketRepository cart = BasketRepository.instance;
    final List<CartItem> items = cart.getItems();

    final Widget content;
    if (items.isEmpty) {
      if (_confirmationMessage.isNotEmpty) {
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _EmptyBasket(),
            Text(_confirmationMessage),
          ],
        );
      } else {
        content = const _EmptyBasket();
      }
    } else {
      content = _BasketList(
        cart: cart,
        onDelete: _removeTickets,
        onUpdateOrder: _updateOrder,
        onBuyTickets: _buyTickets,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: content,
      ),
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
