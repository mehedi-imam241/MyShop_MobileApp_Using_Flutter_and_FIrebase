import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleIsFavourite(String userID, String authTOken) async {
    final url =
        'https://myshop-a2822-default-rtdb.firebaseio.com/userFavourites/$userID/products/$id.json?auth=$authTOken';

    try {
      isFavourite = !isFavourite;
      notifyListeners();
      final res = await http.patch(
        url,
        body: json.encode(
          {
            'isFavourite': isFavourite,
          },
        ),
      );
      if (res.statusCode >= 400) {
        isFavourite = !isFavourite;
        notifyListeners();
      }
    } catch (e) {
      isFavourite = !isFavourite;
      notifyListeners();
    }
  }
}
