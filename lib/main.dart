import 'package:capstoneproject/product_detail.dart';
import 'package:capstoneproject/viewPurchaseHistory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'search.dart';
import 'login.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunway Originals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Empty and transparent app bar
          elevation: 0, // Remove app bar shadow
        ),
      ),
      routes: {
        '/': (context) => const HomePage(), // Route for the homepage
        '/search': (context) => const SearchPage(), // Route for search
        '/profile': (context) => const ProfilePage(), // Route for profile
        '/cart': (context) => CartPage(), // Route for cart
        '/login': (context) => LoginPage() // Route for login
      },
    );
  }
}





//HomePage
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Products');
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
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
            subcategory: value['subCategory'] ??'',
            color: value['color'] ?? '',
            price: (value['price'] ?? 0).toDouble(),
            stkBal:(value['stkNo'] ?? 0).toInt(),
            size: value['size'] ?? '',
          );
          productList.add(product);
        });

        setState(() {
          products = productList;
        });
      }
    } catch (error) {
      print('Failed to fetch data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;


    String name = '';
    return WillPopScope(
        onWillPop: () => _onBackPressed(context),

    child: Scaffold(
      appBar: AppBar(
        title: const Text('Sunway Originals'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.lightBlueAccent, // Set the app bar background color to transparent
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Navigate to the ChatPage when the chat icon is pressed
              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage()));
            },
          ),
        ],
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
          children: <Widget>[
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 2/3,

                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product_main = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetail(product: product_main), // Pass the product
                            ),
                          );
                        },
                        child: ProductCard(product: product_main),
                      );
                      // return ProductCard(product: product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),


      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',


          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',

          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // Navigate to Cart page when tapping "Cart"
            Navigator.pushNamed(context, '/cart');
          } else if (index == 2) {
            // Navigate to Profile page when tapping "Profile"
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    ),
    );
  }
  Future<bool> _onBackPressed(BuildContext context) async {
    return (await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Do you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Allow exit
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Stay in the app
              },
              child: Text('No'),
            ),
          ],
        ))) ?? false; // Return false if the dialog is dismissed
  }

}


class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: SizedBox(
        height : 500,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            product.imgLink != null
                ? Image.network(
              // product.imgLink!,
              '${product.imgLink}',
              //'https://firebasestorage.googleapis.com/v0/b/sunway-originals.appspot.com/o/product_images%2Ftee%2FClassic_Tee.png?alt=media&token=18330eae-4865-4a16-8da6-3051e7b58211',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            )
                : SizedBox(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${product.type}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${product.title}',
                style: const TextStyle(fontSize: 11),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'RM${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String imgLink;
  final String productID;
  final String title;
  final String name;
  final String type;
  final double price;
  final String category;
  final String subcategory;
  final String color;
  final int stkBal;
  final String size;

  Product({
    required this.imgLink,
    required this.title,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.color,
    required this.productID,
    required this.name,
    required this.type,
    required this.stkBal,
    required this.size
  });


}













//Cart
class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final DatabaseReference _cartReference =
  FirebaseDatabase.instance.ref().child('Cart');
  bool isAllSelected = false;
  bool isItemSelected = false;
  List<CartItem> cartItems = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCartData();
  }

  void _fetchCartData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String email = '${user.email}';
        String userID = email.substring(0, 8);
        DatabaseEvent event = await _cartReference.child('$userID').once();


        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? cartData = snapshot.value as Map<dynamic,
            dynamic>?;

        if (cartData != null) {
          List<CartItem> cartItemList = [];
          cartData.forEach((userID, products) {
            products.forEach((productID, value) {
              String quantityS =  value['quantity'] ?? '';
              int quantity = value ?? 0;
              CartItem cartItem = CartItem(
                productID: productID,
                name: value['name'] ?? '',
                variant: value['variant'] ?? '',
                price: value['price'] ?? 0.0,
                quantity: quantity,


              );
              cartItemList.add(cartItem);
            });
          });

          setState(() {
            cartItems = cartItemList;
          });
        }
      } else {
        // Handle when user is not logged in
        print('User is not logged in.');
        // Set cartItems to an empty list or handle it as needed
        setState(() {
          cartItems = [];
        });
      }
    } catch (error) {
      print('Failed to fetch cart data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Shopping Cart'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Checkbox(
            value: isAllSelected,
            onChanged: (value) {
              setState(() {
                isAllSelected = value!;
                isItemSelected = value;
              });
            },
          ),
          Text(isItemSelected ? '1 item selected' : ''),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              if (isItemSelected) {
                // Show a confirmation dialog to delete items
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Selected Items?'),
                      content: const Text('Are you sure you want to delete the selected items?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Delete selected items
                            setState(() {
                              cartItems.removeWhere((item) => item.isSelected);
                              isAllSelected = false;
                              isItemSelected = false;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('No'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Show an alert dialog when no item is selected
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('No Product Selected!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }

            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Colors.lightBlueAccent, Colors.white],
          ),
        ),
        child: user != null
            ? buildCartWithProducts()
            : buildLoginPrompt(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const <BottomNavigationBarItem>[

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',


          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',

          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // Navigate to Cart page when tapping "Cart"
            Navigator.pushNamed(context, '/');
          } else if (index == 2) {
            // Navigate to Profile page when tapping "Profile"
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
      // bottomNavigationBar: buildBottomNavigationBar(),
    );
  }



  Widget buildCartWithProducts() {
    return ListView.builder(
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return CartItemCard(cartItem: cartItems[index], onSelected: (bool? value) { }, onQuantityChanged: (int value) {  },);
      },
    );
  }

  Widget buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Login to view / use your cart',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }


}

class CartItem {
  final String productID;
  final String name;
  final String variant;
  final double price;
  final int quantity;
  bool isSelected;


  CartItem({
    required this.productID,
    required this.name,
    required this.variant,
    required this.price,
    required this.quantity,
    this.isSelected = false,

  });
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;

  final ValueChanged<bool?> onSelected;
  final ValueChanged<int> onQuantityChanged;



  const CartItemCard({Key? key, required this.cartItem,
    required this.onSelected,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // int quantity = '${cartItem.quantity}';
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Checkbox(
          value: cartItem.isSelected,
          onChanged: onSelected,
        ),
        title: Text(cartItem.name),
        subtitle: Text('${cartItem.variant} - \$${cartItem.price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (cartItem.quantity > 1) {
                  onQuantityChanged(cartItem.quantity - 1);
                }
              },
            ),
            Text('${cartItem.quantity}'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onQuantityChanged(cartItem.quantity + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

}












//Profile
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = '${user.email}';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        title: Text('Profile'),
        automaticallyImplyLeading: false,
        actions: <Widget>[

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              _signOut(context);
            },
          ),

        ],
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
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[

                  SizedBox(width: 8),
                  // User's Name or Login Button
                  user != null ?
                  Text(
                    'User: ${user.email}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )

                      :ElevatedButton(
                    onPressed: () {
                      // Navigate to the login page when the button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text('Log In'),
                  ),

                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "User's Purchase History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),


            // Horizontal scrollable section for recent purchases
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          navigateToPurchaseHistory(context, 'Paid', user!.email!);
                        },
                        child: Expanded(
                          child: Column(
                            children: [
                              Icon(Icons.payment, color: Colors.green),
                              Text('Paid'),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          navigateToReadyToPickUp(context, 'Paid', user!.email!);
                        },
                        child: Expanded(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle, color: Colors.blue),
                              Text('Ready to Pick Up'),
                          ],
                        ),
                      ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.schedule, color: Colors.orange),
                            Text('Pre-Ordered'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            Text('Canceled'),
                          ],
                        ),
                      ),


                    ],
                  ),

                  // Spacer between rows
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/cart');
          }
        },
      ),
    );
  }
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Update the login status and refresh the UI
      checkLoginStatus(context);
      // Optionally navigate to the login page or any other desired screen
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Error signing out: $e');
      // Handle error, show error message, etc.
    }
  }

  void checkLoginStatus(BuildContext context) {
    // Check if the user is currently logged in
    User? user = FirebaseAuth.instance.currentUser;
  }
  void navigateToPurchaseHistory(BuildContext context, String status, String userEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => viewPaidHistoryPage(status: status, userEmail: userEmail),
      ),
    );
  }
  void navigateToReadyToPickUp(BuildContext context, String status, String userEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => viewReadyToPickUpPage(status: status, userEmail: userEmail),
      ),
    );
  }
}

class PurchaseCard extends StatelessWidget {
  final String prodID;
  final String productName;

  const PurchaseCard({
    Key? key,
    required this.prodID,
    required this.productName,
    // Add other necessary details
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(right: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              productName,
              style: TextStyle(fontSize: 16),
            ),
          ),
          // Add other necessary details
        ],
      ),
    );
  }

}