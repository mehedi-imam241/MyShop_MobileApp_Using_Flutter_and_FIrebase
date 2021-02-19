import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:myshop/providers/products.dart';
import 'package:myshop/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  const ProductsGrid({
    Key key,
    this.showFavs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final _products =
        showFavs ? productsData.favouriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: _products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) => Card(
        child: ChangeNotifierProvider.value(
          value: _products[i],
          child: ProductItem(),
        ),
      ),
    );
  }
}
