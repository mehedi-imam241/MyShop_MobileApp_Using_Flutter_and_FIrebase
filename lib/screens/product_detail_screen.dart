import 'package:flutter/material.dart';
import 'package:myshop/providers/products.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // const ProductDetailScreen({Key key}) : super(key: key);

  static String routeName = "/ProductDetailScreen";

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context).settings.arguments;
    final _productsData = Provider.of<Products>(context, listen: false);
    final _product = _productsData.findByID(id);
    return Scaffold(
        appBar: AppBar(
          title: Text(_product.id),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  _product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '\$${_product.price}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  _product.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ));
  }
}
