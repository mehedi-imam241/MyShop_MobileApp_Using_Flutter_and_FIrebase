import 'package:flutter/material.dart';
import 'package:myshop/providers/cart.dart';
import 'package:myshop/providers/products.dart';
import 'package:myshop/screens/cart_screen.dart';
import 'package:myshop/widgets/app_drawer.dart';
import 'package:myshop/widgets/badge.dart';
import 'package:myshop/widgets/products_grid.dart';
import 'package:provider/provider.dart';

enum FilterOptions { Favourite, All }

class ProductsOverViewScreen extends StatefulWidget {
  @override
  _ProductsOverViewScreenState createState() => _ProductsOverViewScreenState();
}

class _ProductsOverViewScreenState extends State<ProductsOverViewScreen> {
  bool _showOnlyFavourites = false;
  bool isInit = true;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (isInit) {
      setState(() {
        isLoading = true;
      });
      try {
        await Provider.of<Products>(context).fetchAndSetProducts();
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An Error Occured'),
            content: Text('Something went wrong!'),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK')),
            ],
          ),
        );
      }

      setState(() {
        isLoading = false;
      });
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('MyShop'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text("Only Favourites"),
                  value: FilterOptions.Favourite,
                ),
                PopupMenuItem(
                  child: Text("Show All"),
                  value: FilterOptions.All,
                ),
              ],
              onSelected: (FilterOptions selectedValue) {
                if (selectedValue == FilterOptions.Favourite) {
                  setState(() {
                    _showOnlyFavourites = true;
                  });
                } else if (selectedValue == FilterOptions.All) {
                  setState(() {
                    _showOnlyFavourites = false;
                  });
                }
              },
              icon: Icon(Icons.more_vert),
            ),
            Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                child: ch,
                value: cart.itemNumber.toString(),
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    CartScreen.routeName,
                  );
                },
              ),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: isLoading
            ? Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : ProductsGrid(
                showFavs: _showOnlyFavourites,
              ),
      ),
    );
  }
}
