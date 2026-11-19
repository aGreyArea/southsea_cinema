import 'package:southsea_cinema/models/cart_item.dart';
import 'package:southsea_cinema/models/model.dart';

class BasketRepository {
  // one shared basket for the whole app, so every page sees the same tickets
  static final BasketRepository instance = BasketRepository();

  static const double serviceChargePerTicket = 0.80;

  final List<CartItem> _items = [];

  // read-only copy so the basket can only be changed through the methods below
  List<CartItem> getItems() {
    return List.unmodifiable(_items);
  }

  bool get isEmpty => _items.isEmpty;

  int get totalQuantity {
    int total = 0;
    for (final item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get total {
    double total = 0;
    for (final item in _items) {
      total += item.lineTotal;
    }
    return total;
  }

  double get serviceCharge => totalQuantity * serviceChargePerTicket;

  // what the customer pays: tickets plus service charge
  double get totalDue => total + serviceCharge;

  void addTickets(Movie movie, int quantity) {
    if (quantity <= 0) {
      return;
    }
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].movie.id == movie.id) {
        // same movie already in the basket, so add to its quantity
        _items[i] = CartItem(
          movie: movie,
          quantity: _items[i].quantity + quantity,
        );
        return;
      }
    }
    _items.add(CartItem(movie: movie, quantity: quantity));
  }

  void removeTickets(Movie movie) {
    _items.removeWhere((item) => item.movie.id == movie.id);
  }

  void clear() {
    _items.clear();
  }
}
