import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:myshop/models/http_exception.dart';
import 'package:myshop/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String authTOken;
  final String userID;
  Products(this.userID, this.authTOken, this._items);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userID"' : '';

    var url =
        'https://myshop-a2822-default-rtdb.firebaseio.com/products.json?auth=$authTOken$filterString';
    try {
      final res = await http.get(url);
      // print(json.decode(res.body));
      final extractedData = json.decode(res.body) as Map<String, dynamic>;

      url =
          'https://myshop-a2822-default-rtdb.firebaseio.com/userFavourites/$userID/products.json?auth=$authTOken';

      final favouriteResponse = await http.get(url);
      final favouriteData =
          json.decode(favouriteResponse.body) as Map<String, dynamic>;

      // print(extractedData);
      //print(favouriteData);

      final List<Product> loadedProducts = [];
      extractedData.forEach((id, productData) {
        print(favouriteData[id]);
        loadedProducts.add(
          Product(
              id: id,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              isFavourite: favouriteData == null
                  ? false
                  : favouriteData[id] == null
                      ? false
                      : favouriteData[id]['isFavourite']),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      print('Hello world');
      print(e);
      throw e;
    }
  }

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findByID(id) {
    return _items.firstWhere(
      (element) => id == element.id,
    );
  }

  Future<void> addProduct(Product newProduct) async {
    final url =
        'https://myshop-a2822-default-rtdb.firebaseio.com/products.json?auth=$authTOken';
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'isFavourite': newProduct.isFavourite,
            'imageUrl': newProduct.imageUrl,
            'creatorId': userID,
          },
        ),
      );

      print(json.decode(res.body));
      _items.add(
        Product(
          id: json.decode(res.body)['name'],
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl,
        ),
      );
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://myshop-a2822-default-rtdb.firebaseio.com/products/$id.json?auth=$authTOken';

    try {
      final res = await http.delete(url);
      print(res.statusCode);
      if (res.statusCode >= 400) {
        print('Delete Error');
        throw HttpException('Could not delete product');
      } else {
        _items.removeWhere((element) => element.id == id);
        print('done');
        notifyListeners();
      }
    } catch (e) {
      print('Delete Error');
      throw e;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      final url =
          'https://myshop-a2822-default-rtdb.firebaseio.com/products/$id.json?auth=$authTOken';

      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          },
        ),
      );

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }
}
