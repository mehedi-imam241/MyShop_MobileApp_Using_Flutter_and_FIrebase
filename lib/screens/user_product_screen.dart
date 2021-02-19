import 'package:flutter/material.dart';
import 'package:myshop/providers/product.dart';
import 'package:myshop/providers/products.dart';
import 'package:myshop/screens/edit_product_screen.dart';
import 'package:myshop/widgets/app_drawer.dart';
import 'package:myshop/widgets/user_product_item.dart';
import 'package:provider/provider.dart';

class UserProductScreen extends StatelessWidget {
  const UserProductScreen({Key key}) : super(key: key);
  static const routeName = '/userProducts';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Consumer<Products>(
                    builder: (context, _productsData, _) => ListView.builder(
                      itemBuilder: (context, index) => Column(
                        children: [
                          UserProductItem(
                            id: _productsData.items[index].id,
                            title: _productsData.items[index].title,
                            imageUrl: _productsData.items[index].imageUrl,
                          ),
                          Divider(),
                        ],
                      ),
                      itemCount: _productsData.items.length,
                    ),
                  ),
                ),
              ),
      ),
      drawer: AppDrawer(),
    );
  }
}
