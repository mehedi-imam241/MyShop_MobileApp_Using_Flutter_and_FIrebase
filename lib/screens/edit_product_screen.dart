import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myshop/providers/product.dart';
import 'package:myshop/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  EditProductScreen({Key key}) : super(key: key);

  static const routeName = '/editProduct';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();

  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0.0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageFocusNode.addListener(() {
      if (!_imageFocusNode.hasFocus) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final produdctId = ModalRoute.of(context).settings.arguments as String;

      if (produdctId != null) {
        _editProduct = Provider.of<Products>(
          context,
          listen: false,
        ).findByID(produdctId);
        _initValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _saveForm() {
    if (!_form.currentState.validate()) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    if (_editProduct.id != null) {
      Provider.of<Products>(context, listen: false).updateProduct(
        _editProduct.id,
        _editProduct,
      );
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editProduct)
          .catchError((error) {
        return showDialog(
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
                ));
      }).then((value) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveForm();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      initialValue: _initValues['title'],
                      onSaved: (newValue) {
                        // setState(() {
                        _editProduct = Product(
                          id: _editProduct.id,
                          title: newValue,
                          description: _editProduct.description,
                          price: _editProduct.price,
                          imageUrl: _editProduct.imageUrl,
                          isFavourite: _editProduct.isFavourite,
                        );
                        // });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is empty';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is empty';
                        }
                        final number = num.tryParse(value);

                        if (number == null) {
                          return 'Enter a number';
                        }

                        return null;
                      },
                      onSaved: (newValue) {
                        // setState(() {
                        _editProduct = Product(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: _editProduct.description,
                          price: double.parse(newValue),
                          imageUrl: _editProduct.imageUrl,
                          isFavourite: _editProduct.isFavourite,
                        );
                        // });
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (newValue) {
                        // setState(() {
                        _editProduct = Product(
                          id: _editProduct.id,
                          title: _editProduct.title,
                          description: newValue,
                          price: _editProduct.price,
                          imageUrl: _editProduct.imageUrl,
                          isFavourite: _editProduct.isFavourite,
                        );
                        // });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is empty';
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text('Input a url')
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Flexible(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageFocusNode,
                            onFieldSubmitted: (value) {
                              _saveForm();
                            },
                            onSaved: (newValue) {
                              // setState(() {
                              _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                description: _editProduct.description,
                                price: _editProduct.price,
                                imageUrl: newValue,
                                isFavourite: _editProduct.isFavourite,
                              );
                              // });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'URL is empty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
