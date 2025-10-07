import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bbqlagao_and_beefpares/models/dish.dart';

class MenuController {
  // Singleton instance
  static final MenuController _instance = MenuController._internal();
  static MenuController get instance => _instance;
  MenuController._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'menu';

  // Methods for staff that fetch all dishes regardless of status
  Stream<List<Dish>> getAllDishesForStaff() => _firestore
      .collection(_collection)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Dish.fromFirestore(doc)).toList(),
      );

  Stream<List<Dish>> getDishesByCategoryForStaff(String category) {
    if (category == 'All') return getAllDishesForStaff();

    if (category == 'Misc') {
      return getAllDishesForStaff().map(
        (dishes) => dishes.where((dish) => dish.categories.isEmpty).toList(),
      );
    }

    return getAllDishesForStaff().map(
      (dishes) => dishes
          .where(
            (dish) =>
                dish.categories.any((cat) => cat['categoryName'] == category),
          )
          .toList(),
    );
  }

  Stream<List<String>> getAllCategoriesForStaff() =>
      _firestore.collection(_collection).snapshots().map((snapshot) {
        final Set<String> categories = {};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final dishCategories = List<Map<String, dynamic>>.from(
            data['categories'] ?? [],
          );
          for (final cat in dishCategories) {
            final name = cat['categoryName'];
            if (name is String && name.isNotEmpty) {
              categories.add(name);
            }
          }
        }
        return categories.toList()..sort();
      });

  Future<void> addDish(Dish dish) async {
    await _firestore.collection(_collection).add(dish.toFirestore());
    Toast.show('Menu added successfully');
  }

  Future<void> updateDish(String id, Dish dish) async {
    await _firestore.collection(_collection).doc(id).update(dish.toFirestore());
    Toast.show('Menu updated successfully');
  }

  Future<void> deleteDish(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
    Toast.show('Menu deleted successfully');
  }
}
