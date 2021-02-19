import 'package:flutter/material.dart';
import 'package:myshop/providers/auth.dart';
import 'package:myshop/providers/cart.dart';
import 'package:myshop/providers/orders.dart';
import 'package:myshop/providers/products.dart';
import 'package:myshop/screens/auth_screen.dart';
import 'package:myshop/screens/cart_screen.dart';
import 'package:myshop/screens/edit_product_screen.dart';
import 'package:myshop/screens/order_screen.dart';
import 'package:myshop/screens/product_detail_screen.dart';
import 'package:myshop/screens/user_product_screen.dart';
import 'package:provider/provider.dart';
import './screens/products_overview_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (ctx, auth, previousProducts) => Products(
            auth.userID,
            auth.token,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (ctx, auth, previousOrders) => Orders(
            auth.userID,
            auth.token,
            previousOrders == null ? [] : previousOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, child) => MaterialApp(
          title: 'Material App',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue[900],
            accentColor: Colors.lightBlueAccent,
            errorColor: Colors.pinkAccent,
            fontFamily: 'Cairo',
            textTheme: TextTheme(
              headline1: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
              bodyText1: TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ),
          home: auth.isAuth
              ? ProductsOverViewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authSnapshot) =>
                      authSnapshot.connectionState == ConnectionState.waiting
                          ? Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductScreen.routeName: (context) => UserProductScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
