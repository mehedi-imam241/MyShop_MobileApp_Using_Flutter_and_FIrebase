import 'package:flutter/material.dart';
import 'package:myshop/providers/auth.dart';
import 'package:myshop/providers/cart.dart';
import 'package:myshop/providers/product.dart';
import 'package:myshop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(
      context,
    );
    final _cart = Provider.of<Cart>(
      context,
    );
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          title: Text(
            _product.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          backgroundColor: Color.fromRGBO(8, 8, 8, .6),
          leading: IconButton(
            icon: Icon(
              _product.isFavourite ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () =>
                _product.toggleIsFavourite(authData.userID, authData.token),
          ),
          trailing: IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                _cart.addCartItem(
                  _product.id,
                  _product.price,
                  _product.title,
                );
                Scaffold.of(context).hideCurrentSnackBar();
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added item to cart',
                      textAlign: TextAlign.center,
                    ),
                    duration: Duration(milliseconds: 2000),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        _cart.removeItem(_product.id);
                      },
                    ),
                  ),
                );
              }),
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              ProductDetailScreen.routeName,
              arguments: _product.id,
            );
          },
          child: Image.network(
            _product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
