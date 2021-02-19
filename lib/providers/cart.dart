import 'dart:convert';

import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  // final String authToken;

  // Cart(this.authToken, this._items);

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemNumber {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addCartItem(
    String id,
    double price,
    String title,
  ) {
    if (_items.containsKey(id)) {
      _items.update(
        id,
        (existingCartItem) => CartItem(
            id: existingCartItem.id,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity + 1,
            price: existingCartItem.price),
      );
    } else {
      _items.putIfAbsent(
        id,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void removeSingleItem(String productID) {
    if (!_items.containsKey(productID)) return;

    if (_items[productID].quantity > 1) {
      _items.update(
        productID,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
        ),
      );
    } else {
      _items.remove(productID);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
