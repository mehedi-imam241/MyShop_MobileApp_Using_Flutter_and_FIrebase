import 'package:flutter/material.dart';
import 'package:myshop/providers/orders.dart';
import 'package:myshop/widgets/app_drawer.dart';
import 'package:myshop/widgets/order_item.dart' as orderItemWidget;
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key key}) : super(key: key);

  static const routeName = '/orders';

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool init = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (init) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<Orders>(context).fetchAndSetOrders();
      } catch (e) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error!'),
            content: Text('An unknown error occured'),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
    init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final _orders = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : ListView.builder(
              itemBuilder: (context, index) => orderItemWidget.OrderItem(
                order: _orders.orders[index],
              ),
              itemCount: _orders.orders.length,
            ),
    );
  }
}
