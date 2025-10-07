import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../controllers/customer/cart_controller.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String role;
  final String? provider;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.role,
    this.provider,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'customer',
      provider: data['provider'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      if (provider != null) 'provider': provider,
    };
  }
}

class UserProvider with ChangeNotifier {
  User? _user;
  CartController? _cartController;

  User? get user => _user;
  CartController? get cartController => _cartController;

  void setUser(User user) {
    _user = user;
    // Initialize cart controller for the user
    if (_cartController == null && user.id != null) {
      _cartController = CartController(user.id!);
      _cartController!.loadCart();
    }
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _cartController = null;
    notifyListeners();
  }
}
