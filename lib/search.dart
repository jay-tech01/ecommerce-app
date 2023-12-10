import 'package:capstoneproject/product_detail.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _searchController;
  List<Product> products = [];
  List<Product> displayedProducts = [];
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Products');


  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchDataFromFirebase();
  }

  void _fetchDataFromFirebase() async {
    try {
      DatabaseEvent event = await _database.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? productsData = snapshot.value as Map<dynamic, dynamic>?;

      if (productsData != null) {
        List<Product> productList = [];
        productsData.forEach((key, value) {
          String prodname = value['name'] ?? '';
          String prodcat = value['category'] ??'';
          String prodtype = value['type'] ??'';
          String prodcolour = value['colour'] ??'';
          String prodsize = value['size'] ??'';
          String prodsubcat = value['subCategory'] ??'';

          String prodType = '$prodtype $prodsubcat';
          String prodDispName = '$prodname - $prodcolour ($prodsize)';
          Product product = Product(
            productID: key,
            //productID: 'aB',
            imgLink: value['imgLink'] ?? '',
            name : value['name'] ?? '',
            type : prodType,
            title: prodDispName,
            category: value['category'] ?? '',
            subcategory: value['subCategory'] ?? '',
            color: value['color'] ?? '',
            price: (value['price'] ?? 0).toDouble(),
            stkBal:(value['stkNo'] ?? 0).toInt(),
            size: value['size'] ?? '',
          );
          productList.add(product);
        });

        setState(() {
          products = productList;
          displayedProducts = products;

        });
      }
    } catch (error) {
      print('Failed to fetch data: $error');
    }


  }

  void _filterProducts(String query) {
    setState(() {
      displayedProducts = products.where((product) {
        // Check if the query matches any of the product details
        return product.type.toLowerCase().contains(query.toLowerCase()) ||
            product.title.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()) ||
            product.color.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 2/3,

                ),
                itemCount: displayedProducts.length,
                itemBuilder: (context, index) {
                  final product = displayedProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetail(
                                  product: product), // Pass the product
                        ),
                      );
                    },
                    child: ProductCard(product: product),
                  );
                },
              );
            },
    ),
          ),
        ],
      ),
    );
  }
}