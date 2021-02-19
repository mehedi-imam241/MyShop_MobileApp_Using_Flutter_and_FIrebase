import 'package:flutter/material.dart';
import 'package:myshop/providers/cart.dart' show Cart;
import 'package:myshop/providers/orders.dart';
import 'package:provider/provider.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key key}) : super(key: key);

  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    onPressed: (cart.items.length <= 0 || _isLoading)
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await Provider.of<Orders>(
                              context,
                              listen: false,
                            ).addOrder(
                              cart.items.values.toList(),
                              cart.totalAmount,
                            );
                            cart.clearCart();
                            setState(() {
                              _isLoading = false;
                            });
                          },
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            "ORDER NOW",
                            style: TextStyle(
                              color: (cart.itemNumber <= 0)
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemNumber,
              itemBuilder: (_, index) => CartItem(
                id: cart.items.values.toList()[index].id,
                title: cart.items.values.toList()[index].title,
                quantity: cart.items.values.toList()[index].quantity,
                price: cart.items.values.toList()[index].price,
                productId: cart.items.keys.toList()[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
