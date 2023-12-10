import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'checkout.dart';
import 'main.dart';

class ProductDetail extends StatelessWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String name = '${product.name} ${product.type} ${product.size}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent, // Transparent app bar
        elevation: 0,
      ),
      body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.center,
    colors: [Colors.lightBlueAccent, Colors.white],
    ),
    ),
    child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          product.imgLink != null
              ? Image.network(
            // product.imgLink!,
            '${product.imgLink}',
            //'https://firebasestorage.googleapis.com/v0/b/sunway-originals.appspot.com/o/product_images%2Ftee%2FClassic_Tee.png?alt=media&token=18330eae-4865-4a16-8da6-3051e7b58211',
            width: double.infinity,
            height: 210,
            fit: BoxFit.cover,
          )
              : Container(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Product Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              product.productID,
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
            '${product.stkBal.toStringAsFixed(2)} stocks left',
              style: TextStyle(fontSize: 10),
            ),
          ),
          // Product Price
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),

        ],
      ),),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

            ElevatedButton(
              onPressed: () {
                User? user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  // If the user is not authenticated, navigate to the login page
                  Navigator.pushNamed(context, '/login');
                  return;
                }

                // If the user is authenticated, show the password dialog
                // bool isAuthenticated = await showPasswordDialog(context);

                if (user != null) {
                  // If authentication is successful, generate a new PreOrderID and add details to the database

                  addToCart(product.productID, user.email!, product.name, product.category, product.color, product.price, product.size, context);

                  // Perform any additional actions after successful authentication and database update
                }// Add to Cart functionality
              },
              child: const Text('Add To Cart'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Check if the user is authenticated
                User? user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  // If the user is not authenticated, navigate to the login page
                  Navigator.pushNamed(context, '/login');
                  return;
                }

                // If the user is authenticated, show the password dialog
                // bool isAuthenticated = await showPasswordDialog(context);

                if (user != null) {
                  // If authentication is successful, generate a new PreOrderID and add details to the database
                  String userEmail = user.email!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(product: product, userEmail: userEmail),
                    ),
                  );
                  // String preOrderID = generatePreOrderID(user.email!);
                  // addPreOrderToDatabase(preOrderID, user.email!, context);

                  // Perform any additional actions after successful authentication and database update
                }// Pre-Order functionality
              },
              child: const Text('Pre-Order'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addToCart(String productID, String userEmail, String productName, String productCategory, String productColor, double productPrice, String productSize, context) async {
    String useremail = userEmail;
    String userID = useremail.substring(0, 8);
    DatabaseReference cartRef = FirebaseDatabase.instance.ref().child('Cart').child(userID).child(productID);

    // Check if the product already exists in the cart
    DatabaseEvent event = await cartRef.once();
    DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      int currentQuantity = (snapshot.value as Map<dynamic, dynamic>)['quantity'] ?? 0;
      Flushbar(
        message: 'Product added to cart!',
        duration: Duration(seconds: 2),
      )..show(context);
      // Product already exists, update the quantity

      cartRef.update({'quantity': currentQuantity + 1});
    } else {
      // Product doesn't exist, add it to the cart
      cartRef.set({
        'name': productName,
        'category': productCategory,
        'color': productColor,
        'price': productPrice,
        'quantity': 1,
        'size': productSize,
      });
      Flushbar(
        message: 'Product added to cart!',
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }
}

