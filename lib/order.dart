import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cart.dart';
import 'menu.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _incrementQuantity(int index) {
    setState(() {
      Cart.items[index]['quantity'] += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (Cart.items[index]['quantity'] > 1) {
        Cart.items[index]['quantity'] -= 1;
      } else {
        Cart.items.removeAt(index);
      }
    });
  }

  void _placeOrder() async {
  if (Cart.items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Your cart is empty!")),
    );
    return;
  }

     int totalOrderPrice = 0;
    for (var item in Cart.items) {
    final int basePrice = int.tryParse(item['basePrice'] ?? '0') ?? 0;
    final int quantity = item['quantity'] as int;
    totalOrderPrice += basePrice * quantity;
    }

  final String formattedTotalPrice = "${totalOrderPrice}k";


    try {
      await _firestore.collection('orders').add({
        'items': Cart.items,
        'totalPrice': formattedTotalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the cart after placing the order
      setState(() {
        Cart.items.clear();
      });

      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Order Placed"),
          content: Text(
            "Thank you for your order!\n\nTotal Price: Rp ${totalOrderPrice}k",
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error placing order: $e")),
    );
  }
}

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Do you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Stay in the app
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Exit the app
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmation(context);
        return shouldExit; // Prevent exiting unless user confirms
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: const Text(
            "Your Order",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Cart.items.isEmpty
                  ? const Center(
                      child: Text(
                        "Your cart is empty!",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
  padding: const EdgeInsets.all(16.0),
  itemCount: Cart.items.length,
  itemBuilder: (context, index) {
    final item = Cart.items[index];
    final int basePrice = int.tryParse(item['basePrice'] ?? '0') ?? 0; // Ensure basePrice is an integer
    final int quantity = item['quantity'] as int; // Cast quantity to an integer
    final int totalPrice = basePrice * quantity; // Calculate total price 

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Image.asset(
          item['image']!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          item['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rp ${totalPrice.toString()}k", // Display updated total price
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _decrementQuantity(index),
                ),
                Text(
                  '${item['quantity']}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () => _incrementQuantity(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  },
)
,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 10, 60, 100),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              onPressed: _placeOrder,
              child: const Text(
                "Place Order",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: const Color.fromARGB(255, 10, 60, 100),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const MainRamen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                  (route) => false,
                );
                break;
              case 1:
                break;
              case 2:
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                  (route) => false,
                );
                break;
            }
          },
        ),
      ),
    );
  }
}
