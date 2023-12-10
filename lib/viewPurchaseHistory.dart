import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class viewPaidHistoryPage extends StatefulWidget {
  final String status;
  final String userEmail;
  viewPaidHistoryPage({required this.status, required this.userEmail});

  @override
  _viewPaidHistoryPageState createState() => _viewPaidHistoryPageState();
}

class _viewPaidHistoryPageState extends State<viewPaidHistoryPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Pre_Order');
  List<PreOrder> preOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchPreOrders();
  }

  void _fetchPreOrders() async {
    try {
      DatabaseEvent event = await _database.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? preOrdersData = snapshot.value as Map<dynamic, dynamic>?;


      if (preOrdersData != null) {
        List<PreOrder> filteredPreOrders = [];

        preOrdersData.forEach((key, preOrderDetails) {
          // Check the conditions for filtering
          if (preOrderDetails['UserID'] == '19069905' && preOrderDetails['payment_status'] == 'Paid') {
            PreOrder preOrder = PreOrder(
              preOrderID: key,
              date: preOrderDetails['date'],
              paymentStatus: preOrderDetails['payment_status'],
              pickupStatus: preOrderDetails['pickup_status'],
              prodID: preOrderDetails['prodID'],
              userID: preOrderDetails['UserID'],
              username: preOrderDetails['username'],
            );
            filteredPreOrders.add(preOrder);
          }
        });

        setState(() {
          preOrders = filteredPreOrders;
        });
      }
    } catch (error) {
      print('Failed to fetch pre-orders: $error');
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Pre Orders'),
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
    child: ListView.builder(
        itemCount: preOrders.length,
        itemBuilder: (context, index) {
          return PreOrderCard(preOrder: preOrders[index]);
        },
      ),
    ),);
  }
}


class viewReadyToPickUpPage extends StatefulWidget {
  final String status;
  final String userEmail;
  viewReadyToPickUpPage({required this.status, required this.userEmail});

  @override
  _viewReadyToPickUpPageState createState() => _viewReadyToPickUpPageState();
}

class _viewReadyToPickUpPageState extends State<viewReadyToPickUpPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Pre_Order');
  List<PreOrder> preOrders = [];


  // final int bb = (preOrders[index]);

  @override
  void initState() {
    super.initState();
    _fetchPreOrders();
  }

  void _fetchPreOrders() async {
    try {
      DatabaseEvent event = await _database.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? preOrdersData = snapshot.value as Map<dynamic, dynamic>?;


      if (preOrdersData != null) {
        List<PreOrder> filteredPreOrders = [];

        preOrdersData.forEach((key, preOrderDetails) {
          // Check the conditions for filtering
          if (preOrderDetails['UserID'] == '19069905' && preOrderDetails['payment_status'] == 'Paid') {
            PreOrder preOrder = PreOrder(
              preOrderID: key,
              date: preOrderDetails['date'],
              paymentStatus: preOrderDetails['payment_status'],
              pickupStatus: preOrderDetails['pickup_status'],
              prodID: preOrderDetails['prodID'],
              userID: preOrderDetails['UserID'],
              username: preOrderDetails['username'],
            );
            filteredPreOrders.add(preOrder);
          }
        });

        setState(() {
          preOrders = filteredPreOrders;
        });
      }
    } catch (error) {
      print('Failed to fetch pre-orders: $error');
    }
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Pre Orders'),
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
        child: ListView.builder(
          itemCount: preOrders.length,
          itemBuilder: (context, index) {
            return PreOrderCard(preOrder: preOrders[index]);
          },
        ),
      ),);
  }
}


class PreOrder {
  final String preOrderID;
  final String date;
  final String paymentStatus;
  final String pickupStatus;
  final String prodID;
  final String userID;
  final String username;

  PreOrder({
    required this.preOrderID,
    required this.date,
    required this.paymentStatus,
    required this.pickupStatus,
    required this.prodID,
    required this.userID,
    required this.username,
  });
}

class PreOrderCard extends StatelessWidget {
  final PreOrder preOrder;

  PreOrderCard({required this.preOrder});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text('Pre Order ID: ${preOrder.preOrderID}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${preOrder.date}'),
            Text('Payment Status: ${preOrder.paymentStatus}'),
            Text('Pickup Status: ${preOrder.pickupStatus}'),
            Text('Product ID: ${preOrder.prodID}'),
            Text('User ID: ${preOrder.userID}'),
            Text('Username: ${preOrder.username}'),
          ],
        ),
      ),
    );
  }
}
