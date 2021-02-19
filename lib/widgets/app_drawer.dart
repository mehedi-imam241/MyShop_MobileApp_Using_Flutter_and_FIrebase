import 'package:flutter/material.dart';
import 'package:myshop/providers/auth.dart';
import 'package:myshop/screens/order_screen.dart';
import 'package:myshop/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          AppBar(
            title: Text('Hello'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text(
              'Shop',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text(
              'Orders',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(OrderScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text(
              'Manage Products',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
