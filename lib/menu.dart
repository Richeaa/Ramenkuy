import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemNavigator.pop()
import 'package:finalmobileprogramming/img_string.dart';
import 'order.dart';
import 'cart.dart';
import 'profile.dart';

class MainRamen extends StatelessWidget {
  final String? username;
  const MainRamen({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> menuItems = [
      {'name': 'Korean Chicken Ramen', 'image': imgFood1, 'price': 'Rp. 18k', 'basePrice': '18'},
      {'name': 'Spicy Miso Ramen', 'image': imgFood2, 'price': 'Rp. 20k', 'basePrice': '20'},
      {'name': 'Tonkotsu Ramen', 'image': imgFood3, 'price': 'Rp. 25k', 'basePrice': '25' },
      {'name': 'Shoyu Ramen', 'image': imgFood4, 'price': 'Rp. 18k', 'basePrice': '18'},
      {'name': 'Shio Ramen', 'image': imgFood5, 'price': 'Rp. 17k', 'basePrice': '17'},
      {'name': 'Beef Ramen', 'image': imgFood6, 'price': 'Rp. 22k', 'basePrice': '22'},
      {'name': 'Vegan Ramen', 'image': imgFood7, 'price': 'Rp. 15k', 'basePrice': '15'},
      {'name': 'Seafood Ramen', 'image': imgFood8, 'price': 'Rp. 24k', 'basePrice': '24'},
      {'name': 'Pork Ramen', 'image': imgFood9, 'price': 'Rp. 23k', 'basePrice': '23'},
      {'name': 'Curry Ramen', 'image': imgFood10, 'price': 'Rp. 19k', 'basePrice': '19'},
      {'name': 'Orange Juice', 'image': imgdrink1, 'price': 'Rp. 8k', 'basePrice': '8'},
      {'name': 'Apple Juice', 'image': imgdrink2, 'price': 'Rp. 8k', 'basePrice': '8'},
      {'name': 'Lemon Juice', 'image': imgdrink3, 'price': 'Rp. 10k', 'basePrice': '10'},
      {'name': 'Vodka', 'image': imgdrink4, 'price': 'Rp. 15k', 'basePrice': '15'},
      {'name': 'Hot Chocolate', 'image': imgdrink5, 'price': 'Rp. 12k', 'basePrice': '12'},
      {'name': 'Latte', 'image': imgdrink6, 'price': 'Rp. 13k', 'basePrice': '13'},
      {'name': 'Beer', 'image': imgdrink7, 'price': 'Rp. 15k', 'basePrice': '15'},
    ];

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmation(context);
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            username != null ? "Hi, $username" : "Hi, Rameners",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ready to choose your favorite ramen?",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/banner1.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Food & Beverages",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: menuItems.map((menuItem) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 42) / 2,
                    child: _RamenCard(menuItem: menuItem),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: const Color.fromARGB(255, 10, 60, 100),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 500),
                    pageBuilder: (context, animation, secondaryAnimation) => const OrderPage(),
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

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit App"),
          content: const Text("Do you want to exit?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}

class _RamenCard extends StatelessWidget {
  final Map<String, String> menuItem;

  const _RamenCard({required this.menuItem});

  @override
  Widget build(BuildContext context) {
    final String name = menuItem['name']!;
    final String imagePath = menuItem['image']!;
    final String price = menuItem['price']!;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 10),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () {
              // Add item to cart
              _addToCart(context, name, imagePath, price);
            },
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context, String name, String image, String price) {
    final existingItem = Cart.items.indexWhere((item) => item['name'] == name);
    final int basePrice = int.tryParse(price.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;

    if (existingItem != -1) {
      Cart.items[existingItem]['quantity'] += 1;
    } else {
      Cart.items.add({
        'name': name,
        'image': image,
        'basePrice': basePrice.toString(), 
        'quantity': 1,
      });
    }

    // Provide feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name added to cart!')),
    );
  }
}
