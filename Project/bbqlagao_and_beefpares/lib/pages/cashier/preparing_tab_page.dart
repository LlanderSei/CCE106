//preparing_tab_page.dart
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:bbqlagao_and_beefpares/widgets/gradient_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bbqlagao_and_beefpares/controllers/general/order_controller.dart';
import 'package:bbqlagao_and_beefpares/models/order.dart';
import 'package:bbqlagao_and_beefpares/widgets/customtoast.dart';
import 'package:gradient_icon/gradient_icon.dart';
import 'package:bbqlagao_and_beefpares/pages/cashier/order_details_page.dart';

class PreparingTabPage extends StatelessWidget {
  const PreparingTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController _controller = OrderController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Preparing',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text('Actions', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Order>>(
            stream: _controller.getOrdersByStatus('preparing'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: GradientCircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No preparing orders found.'));
              }
              final orders = snapshot.data!;
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.orange[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Order #${order.orderId.toString()}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(order.name),
                                Text('Dine-in'),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: GradientIcon(
                                  offset: Offset.zero,
                                  icon: Icons.restaurant,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set1,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await _controller.updateOrderStatus(order.id!, 'serving');
                                    Toast.show('Order set to serving');
                                  } catch (e) {
                                    Toast.show('Error: $e');
                                  }
                                },
                              ),
                              IconButton(
                                icon: GradientIcon(
                                  offset: Offset.zero,
                                  icon: Icons.visibility,
                                  gradient: LinearGradient(
                                    colors: GradientColorSets.set2,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetailsPage(order: order),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}