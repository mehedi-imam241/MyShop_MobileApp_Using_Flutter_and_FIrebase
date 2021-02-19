import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:myshop/models/http_exception.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authTOken;
  final String userID;
  List<OrderItem> _orders = [];
  Orders(
    this.userID,
    this.authTOken,
    this._orders,
  );

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://myshop-a2822-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authTOken';
    try {
      final res = await http.get(url);

      if (res.statusCode >= 400)
        throw HttpException("An Error occured");
      else {
        final List<OrderItem> loadedOrders = [];
        final extractTedData = json.decode(res.body) as Map<String, dynamic>;
        extractTedData.forEach((key, orderItem) {
          final orderItemProducts = orderItem['products'] as List<dynamic>;

          loadedOrders.add(
            OrderItem(
              id: key,
              amount: orderItem['amount'],
              products: orderItemProducts
                  .map(
                    (cartProduct) => CartItem(
                      id: cartProduct['id'],
                      title: cartProduct['title'],
                      quantity: cartProduct['quantity'],
                      price: cartProduct['price'],
                    ),
                  )
                  .toList(),
              dateTime: DateTime.parse(orderItem['dateTime']),
            ),
          );
        });
        _orders = loadedOrders;
        notifyListeners();
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://myshop-a2822-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authTOken';

    final timeStamp = DateTime.now();

    try {
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((cartProduct) => {
                      'id': cartProduct.id,
                      'title': cartProduct.title,
                      'quantity': cartProduct.quantity,
                      'price': cartProduct.price,
                    })
                .toList(),
          }));

      if (res.statusCode >= 400) {
        throw HttpException('Error occured');
      }

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ),
      );
      notifyListeners();
    } catch (e) {}
  }
}
