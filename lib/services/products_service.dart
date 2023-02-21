import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_products_app/models/model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier{

  final String _baseUrl = 'flutter-varios-d08d9-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  late Product selectedProduct;
  late File newPictureFile;

  final storage = const FlutterSecureStorage();

  bool isLoading = true;
  bool isSaving = false;

  ProductsService(){
    loadProducts();
  }

  Future loadProducts () async {

    isLoading = true;
    notifyListeners();

    final url = Uri.https( _baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode( resp.body);

    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap( value );
      tempProduct.id = key;
      products.add( tempProduct );
    });

    isLoading = false;
    notifyListeners();
    return products;
  }

  Future saveOrCreateProduct ( Product product ) async {
    isSaving = true;
    notifyListeners();

    if( product.id == '' ){
      await createProduct(product);
    } else {
      await updateProduct(product);
    }
    
    isSaving = false;
    notifyListeners();
  }

  Future updateProduct ( Product product ) async {

    final url = Uri.https( _baseUrl, 'products/${product.id}.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.put(url, body: product.toJson() );

    final decodedData = resp.body;

    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;

    return product.id!;

  }

  Future<String> createProduct( Product product ) async {

    final url = Uri.https( _baseUrl, 'products.json', {
      'auth': await storage.read(key: 'token') ?? ''
    });
    final resp = await http.post( url, body: product.toJson() );

    final decodedData = json.decode( resp.body );

    product.id = decodedData['name'];

    products.add(product);
    
    return '';
  }

  void updateSelectedProductImage( String path ){

    selectedProduct.picture = path;
    newPictureFile = File.fromUri( Uri(path: path));

    notifyListeners();
  }

}