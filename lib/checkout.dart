import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'main.dart';


class CheckoutPage extends StatelessWidget {
  final Product product;

  final String userEmail;

  const CheckoutPage({Key? key, required this.product, required this.userEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.lightBlueAccent,
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
          children: [
            ListTile(
              title: Text(product.name),
              subtitle: Text('1 x \$${product.price.toStringAsFixed(2)}'),
            ),

            const Divider(),
            ListTile(
              title: const Text('Grand Total'),
              subtitle: Text('\$${(1 * product.price).toStringAsFixed(2)}'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // Generate PreOrderID
                String preOrderID = generatePreOrderID(userEmail);
                addPreOrderToDatabase(preOrderID, userEmail, context);

              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),);
  }


  String generatePreOrderID(userEmail) {
    // Generate a new PreOrderID
    DateTime now = DateTime.now();
    String timestamp = now.toString();
    String timestampnomiliS = timestamp.substring(0, 19);
    String useremail = userEmail;
    String userID = useremail.substring(0, 8);
    return '$timestampnomiliS $userID'; // Replace with your actual logic
  }

  Future<void> addPreOrderToDatabase(String preOrderID, String userEmail,
      context) async {
    DateTime now = DateTime.now();
    String timestamp = now.toString();
    String date = timestamp.substring(0, 10);
    String time = timestamp.substring(11, 19);
    DatabaseReference preOrderRef = FirebaseDatabase.instance.ref().child(
        'Pre_Order').child(preOrderID);

    // Create a map with the Pre_Order details
    Map<String, dynamic> preOrderDetails = {
      'date': '$date',
      'time': '$time',
      'payment_status': 'Not Paid',
      'pickup_status': 'Waiting Store To Prepare',
      'prodID': product.productID,
      'UserID': userEmail,
      // Replace with the actual username logic
    };

    try {
      preOrderRef.set(preOrderDetails);
      await updateStockBalance(product.productID);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product ordered successfully'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                },
                child: Text('Okay'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Failed to add PreOrder to the database: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to place order. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Okay'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> updateStockBalance(String productID) async {
    try {
      // Get the current stock balance

      DatabaseReference productRef = FirebaseDatabase.instance.ref().child(
          'Products').child('$productID');
      DatabaseEvent event = await productRef.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? productData = snapshot.value as Map<
          dynamic,
          dynamic>?;

      if (productData != null) {
        int currentStockBalance = productData['stkNo'] ?? 0;

        // Update the stock balance in the Products table
        await productRef.update({'stkNo': currentStockBalance - 1});
      }
    } catch (error) {
      print('Failed to update stock balance: $error');
      // Handle the error, e.g., show an error message to the user
    }
  }

}