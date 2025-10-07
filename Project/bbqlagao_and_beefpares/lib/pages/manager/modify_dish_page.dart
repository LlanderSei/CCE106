// modify_dish_page.dart
import 'package:bbqlagao_and_beefpares/controllers/manager/inventory_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/menu_controller.dart';
import 'package:bbqlagao_and_beefpares/controllers/manager/category_controller.dart';
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_button.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' hide MenuController;

import 'package:bbqlagao_and_beefpares/widgets/gradient_checkbox.dart';
import 'package:gradient_icon/gradient_icon.dart';
import '../../models/dish.dart';
import '../../models/item.dart';
import '../../models/category.dart';
import '../../widgets/customtoast.dart';

class ModifyDishPage extends StatefulWidget {
  final String? dishId;
  final Dish? dish;

  const ModifyDishPage({super.key, this.dishId, this.dish});

  @override
  State<ModifyDishPage> createState() => _ModifyDishPageState();
}

class _ModifyDishPageState extends State<ModifyDishPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _imageUrlCtrl;
  late bool _isVisible;
  final MenuController _menuController = MenuController.instance;
  final InventoryController _inventoryController = InventoryController();
  List<Map<String, dynamic>> _selectedIngredients = [];
  List<Map<String, dynamic>> _selectedCategories = [];
  double _price = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.dish?.name ?? '');
    _descCtrl = TextEditingController(text: widget.dish?.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.dish?.price.toStringAsFixed(2) ?? '0.00',
    );
    _imageUrlCtrl = TextEditingController(text: widget.dish?.imageUrl ?? '');
    _isVisible = widget.dish?.isVisible ?? true;
    _price = widget.dish?.price ?? 0.0;
    if (widget.dish != null) {
      _selectedIngredients = List<Map<String, dynamic>>.from(
        widget.dish!.ingredients
            .where((ing) => ing['itemId'] != null)
            .map((ing) => {'id': ing['itemId'], 'quantity': ing['quantity']}),
      );
      _selectedCategories = List<Map<String, dynamic>>.from(
        widget.dish!.categories
            .where((cat) => cat['categoryId'] != null)
            .map(
              (cat) => {
                'id': cat['categoryId'],
                'name': cat['categoryName'] ?? '',
              },
            ),
      );
      _loadIngredientNames();
    }
  }

  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final isAvailable = await _computeAvailability();
      final dish = Dish(
        id: widget.dishId,
        name: _nameCtrl.text,
        description: _descCtrl.text,
        price: double.parse(_priceCtrl.text),
        isVisible: _isVisible,
        isAvailable: isAvailable,
        ingredients: _selectedIngredients
            .map((ing) => {'itemId': ing['id'], 'quantity': ing['quantity']})
            .toList(),
        categories: _selectedCategories
            .map(
              (cat) => {
                'categoryId': cat['id'],
                'categoryName': cat['name'] ?? cat['categoryName'] ?? '',
              },
            )
            .toList(),
        imageUrl: _imageUrlCtrl.text.isEmpty ? null : _imageUrlCtrl.text,
      );

      if (widget.dishId != null) {
        await _menuController.updateDish(widget.dishId!, dish);
      } else {
        await _menuController.addDish(dish);
      }

      if (mounted) {
        Toast.show(
          'Dish ${widget.dishId != null ? 'updated' : 'added'} successfully',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Toast.show('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadIngredientNames() async {
    final List<Map<String, dynamic>> updated = [];
    for (final ing in _selectedIngredients) {
      if (ing['id'] == null) continue;
      final doc = await FirebaseFirestore.instance
          .collection('inventory')
          .doc(ing['id'])
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        updated.add({
          'id': ing['id'],
          'name': data['name'] ?? 'Unknown',
          'quantity': ing['quantity'],
        });
      } else {
        if (mounted) {
          Toast.show('Item Unavailable/Deleted');
        }
      }
    }
    if (mounted) {
      setState(() {
        _selectedIngredients = updated;
      });
    }
  }

  void _incrementPrice() {
    setState(() {
      _price += 0.01;
      _priceCtrl.text = _price.toStringAsFixed(2);
    });
  }

  void _decrementPrice() {
    if (_price > 0) {
      setState(() {
        _price -= 0.01;
        _priceCtrl.text = _price.toStringAsFixed(2);
      });
    }
  }

  void _addIngredient() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _IngredientSelectionBottomSheet(
        inventoryController: _inventoryController,
        currentIngredients: _selectedIngredients,
        onSave: (updatedIngredients) {
          setState(() {
            _selectedIngredients = updatedIngredients;
          });
        },
      ),
    );
  }

  void _addCategories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CategorySelectionBottomSheet(
        selectedCategories: _selectedCategories,
        onSave: (selected) {
          setState(() {
            _selectedCategories = selected;
          });
        },
      ),
    );
  }

  void _updateIngredientQuantity(String id, int newQuantity) {
    setState(() {
      final index = _selectedIngredients.indexWhere((ing) => ing['id'] == id);
      if (index != -1 && newQuantity >= 0) {
        _selectedIngredients[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeIngredient(String id) {
    setState(() {
      _selectedIngredients.removeWhere((ing) => ing['id'] == id);
    });
  }

  Future<bool> _computeAvailability() async {
    for (final ing in _selectedIngredients) {
      if (ing['id'] == null) return false;
      final doc = await FirebaseFirestore.instance
          .collection('inventory')
          .doc(ing['id'])
          .get();
      if (!doc.exists || (doc.data()?['quantity'] ?? 0) < ing['quantity']) {
        return false;
      }
    }
    return true;
  }

  Widget _buildImagePreview() {
    if (_imageUrlCtrl.text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrlCtrl.text,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.dishId != null ? 'Edit Dish' : 'New Dish';
    final buttonText = widget.dishId != null ? 'Update Dish' : 'Add Dish';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decrementPrice,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                double.tryParse(value!) == null
                                ? 'Enter a valid price'
                                : null,
                            onChanged: (val) {
                              _price = double.tryParse(val) ?? 0.0;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _incrementPrice,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _imageUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Image URL'),
                    ),
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GradientButton(
                              onPressed: _addCategories,
                              child: const Text(
                                'Select Categories',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GradientButton(
                              height: double.infinity,
                              alignment: Alignment.center,
                              onPressed: _addIngredient,
                              child: const Text(
                                'Add Ingredients',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Categories: ${_selectedCategories.isEmpty ? "None" : _selectedCategories.map((c) => c["name"] ?? c["categoryName"] ?? "Unknown").join(", ")}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingredients: ${_selectedIngredients.isEmpty ? "None" : _selectedIngredients.map((i) => "${i["name"]} (x${i["quantity"]})").join(", ")}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Center(child: GradientCircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientCheckbox(
                  value: _isVisible,
                  onChanged: (val) => setState(() => _isVisible = val!),
                ),
                const Text('Visible to Customers'),
              ],
            ),
            SizedBox(
              child: GradientButton(
                onPressed: _isLoading
                    ? () {}
                    : () {
                        _onSavePressed();
                      },
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }
}

class _IngredientSelectionBottomSheet extends StatefulWidget {
  final InventoryController inventoryController;
  final List<Map<String, dynamic>> currentIngredients;
  final Function(List<Map<String, dynamic>>) onSave;

  const _IngredientSelectionBottomSheet({
    required this.inventoryController,
    required this.currentIngredients,
    required this.onSave,
  });

  @override
  State<_IngredientSelectionBottomSheet> createState() =>
      _IngredientSelectionBottomSheetState();
}

class _IngredientSelectionBottomSheetState
    extends State<_IngredientSelectionBottomSheet> {
  String _searchText = '';
  late List<Map<String, dynamic>> _tempIngredients;

  @override
  void initState() {
    super.initState();
    _tempIngredients = List.from(widget.currentIngredients);
  }

  int _getQty(String id) {
    final ing = _tempIngredients.firstWhere(
      (m) => m['id'] == id,
      orElse: () => {'quantity': 0},
    );
    return ing['quantity'] ?? 0;
  }

  void _setQty(String id, String name, int qty) {
    setState(() {
      final index = _tempIngredients.indexWhere((m) => m['id'] == id);
      if (index != -1) {
        if (qty <= 0) {
          _tempIngredients.removeAt(index);
        } else {
          _tempIngredients[index]['quantity'] = qty;
        }
      } else if (qty > 0) {
        _tempIngredients.add({'id': id, 'name': name, 'quantity': qty});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchText = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: widget.inventoryController.getItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GradientCircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No ingredients found'));
                }

                final items = snapshot.data!
                    .where(
                      (item) => item.name.toLowerCase().contains(_searchText),
                    )
                    .toList();

                return ListView.builder(
                  controller: scrollController,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final qty = _getQty(item.id!);
                    final isSelected = qty > 0;

                    return ListTile(
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (checked) {
                          if (checked!) {
                            _setQty(item.id!, item.name, 1);
                          } else {
                            _setQty(item.id!, item.name, 0);
                          }
                        },
                      ),
                      title: Text(item.name),
                      subtitle: Text(
                        'Stock: ${item.quantity}${isSelected ? ' | Selected: $qty' : ''}',
                      ),
                      trailing: isSelected
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () =>
                                      _setQty(item.id!, item.name, qty - 1),
                                ),
                                Text('$qty'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () =>
                                      _setQty(item.id!, item.name, qty + 1),
                                ),
                              ],
                            )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orangeAccent),
                    foregroundColor: Colors.orangeAccent,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                GradientButton(
                  onPressed: () {
                    widget.onSave(_tempIngredients);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySelectionBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCategories;
  final Function(List<Map<String, dynamic>>) onSave;

  const _CategorySelectionBottomSheet({
    required this.selectedCategories,
    required this.onSave,
  });

  @override
  State<_CategorySelectionBottomSheet> createState() =>
      _CategorySelectionBottomSheetState();
}

class _CategorySelectionBottomSheetState
    extends State<_CategorySelectionBottomSheet> {
  String _searchText = '';
  late List<Map<String, dynamic>> _currentSelected;
  final CategoryController _categoryController = CategoryController();

  @override
  void initState() {
    super.initState();
    // Create a deep copy of selected categories to avoid modifying original list
    _currentSelected = List.from(
      widget.selectedCategories.map((cat) => Map<String, dynamic>.from(cat)),
    );
  }

  bool _isSelected(String? id) {
    return _currentSelected.any((cat) => cat['id'] == id);
  }

  void _toggleCategory(Category category) {
    setState(() {
      final index = _currentSelected.indexWhere(
        (cat) => cat['id'] == category.id,
      );
      if (index != -1) {
        _currentSelected.removeAt(index);
      } else {
        _currentSelected.add({'id': category.id, 'name': category.name});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchText = val.toLowerCase()),
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: _categoryController.getCategories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GradientCircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found'));
                }

                final categories = snapshot.data!
                    .where(
                      (cat) => cat.name.toLowerCase().contains(_searchText),
                    )
                    .toList();

                return ListView.builder(
                  controller: scrollController,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category.name),
                      trailing: _isSelected(category.id)
                          ? const Icon(
                              Icons.check_circle,
                              color: Color(0xFFD84315),
                            )
                          : const Icon(Icons.circle_outlined),
                      onTap: () => _toggleCategory(category),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orangeAccent),
                    foregroundColor: Colors.orangeAccent,
                  ),
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                GradientButton(
                  onPressed: () {
                    widget.onSave(_currentSelected);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
