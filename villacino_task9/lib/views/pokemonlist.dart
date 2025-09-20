import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villacino_task9/controllers/pokemoncontroller.dart';

class PokemonList extends StatelessWidget {
  final PokemonController controller = Get.put(PokemonController());

  // Map full stat names to short names
  final Map<String, String> statShortNames = {
    'hp': 'HP',
    'attack': 'ATK',
    'defense': 'DEF',
    'special-attack': 'SP-ATK',
    'special-defense': 'SP-DEF',
    'speed': 'SPD',
  };

  @override
  Widget build(BuildContext context) {
    // Calculate number of columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 300).floor().clamp(2, 4);

    return Scaffold(
      appBar: AppBar(title: Text('Pokémon List')),
      body: Obx(
        () => Stack(
          children: [
            GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: controller.pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = controller.pokemonList[index];
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          pokemon['image'],
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pokemon['name'].toString().capitalizeFirst!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                children: (pokemon['types'] as List).map((
                                  type,
                                ) {
                                  return Chip(
                                    avatar: Icon(Icons.circle, size: 8),
                                    label: Text(
                                      type.toString().capitalizeFirst!,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: (pokemon['stats'] as List).map((
                                  stat,
                                ) {
                                  return Text(
                                    '${statShortNames[stat['name']] ?? stat['name']}: ${stat['value']}',
                                    style: TextStyle(fontSize: 12),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (controller.isLoading.value)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomAppBar(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.page.value > 1
                      ? () {
                          controller.page.value--;
                          controller.pokemonList.clear();
                          controller.fetchPokemons();
                        }
                      : null,
                  icon: Text('<<'),
                ),
                SizedBox(width: 8),
                // Generate page number buttons (show up to 5 pages for simplicity)
                ...List.generate(5, (index) {
                  final pageNum = controller.page.value - 3 + index;
                  if (pageNum < 1 ||
                      !controller.hasNextPage.value &&
                          pageNum > controller.page.value - 1) {
                    return SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: pageNum == controller.page.value - 1
                          ? null
                          : () {
                              controller.page.value = pageNum + 1;
                              controller.pokemonList.clear();
                              controller.fetchPokemons();
                            },
                      child: Text('${pageNum + 1}'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(40, 40),
                        padding: EdgeInsets.zero,
                        backgroundColor: pageNum == controller.page.value - 1
                            ? Colors.grey[300]
                            : null,
                      ),
                    ),
                  );
                }),
                SizedBox(width: 8),
                IconButton(
                  onPressed: controller.hasNextPage.value
                      ? () {
                          controller.fetchPokemons();
                        }
                      : null,
                  icon: Text('>>'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
