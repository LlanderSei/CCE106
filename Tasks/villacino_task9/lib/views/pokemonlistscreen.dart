import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villacino_task9/controllers/pokemoncontroller.dart';
import '../toast.dart';

class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final PokemonController controller = Get.put(PokemonController());
  late TextEditingController searchController;

  // Map full stat names to short names
  final Map<String, String> statShortNames = {
    'hp': 'HP',
    'attack': 'ATK',
    'defense': 'DEF',
    'special-attack': 'Sp.ATK',
    'special-defense': 'Sp.DEF',
    'speed': 'SPD',
  };

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 300).floor().clamp(2, 4);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Pokédex'),
              Text('I HATE NIGGERS!', style: TextStyle(fontSize: 10)),
            ],
          ),
        ),
        backgroundColor: Color.fromARGB(251, 253, 207, 56),
      ),
      resizeToAvoidBottomInset: true,
      body: Obx(
        () => Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search Pokémon by name',
                  border: OutlineInputBorder(),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            controller.searchQuery.value = '';
                          },
                        )
                      : null,
                ),
                onChanged: (value) => controller.updateSearch(value),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GridView.builder(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 5,
                      childAspectRatio:
                          1.1, // Decreased to increase fixed card height
                    ),
                    itemCount: controller.pokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = controller.pokemonList[index];
                      // Build stat widgets without trailing '/'
                      List<Widget> statWidgets = [];
                      for (int i = 0; i < pokemon.stats!.length; i++) {
                        statWidgets.add(
                          Text(
                            '${statShortNames[pokemon.stats![i]['name']] ?? pokemon.stats![i]['name']}: ${pokemon.stats![i]['value']}',
                            style: TextStyle(fontSize: 11),
                          ),
                        );
                        if (i < pokemon.stats!.length - 1) {
                          statWidgets.add(
                            Text(' / ', style: TextStyle(fontSize: 11)),
                          );
                        }
                      }

                      return Card(
                        color: Colors.amber[100],
                        clipBehavior:
                            Clip.hardEdge, // Clip content if it overflows
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                pokemon.image ?? '',
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: Colors.red,
                                    ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      pokemon.name!.capitalizeFirst!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      pokemon.types!
                                          .map((t) => t.capitalizeFirst)
                                          .join(' / '),
                                      style: TextStyle(fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                    Divider(height: 4, thickness: 1),
                                    Text(
                                      '\u{1F4CF} ${pokemon.height! / 10} m / \u{2696} ${pokemon.weight! / 10} kg',
                                      style: TextStyle(fontSize: 11),
                                      maxLines: 2,
                                      overflow: TextOverflow.visible,
                                      softWrap: true,
                                    ),
                                    Divider(height: 4, thickness: 1),
                                    Wrap(
                                      spacing: 2,
                                      runSpacing: 2,
                                      children: statWidgets,
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
            Visibility(
              visible: controller.searchQuery.value.isEmpty,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed:
                          (controller.page.value > 1 &&
                              !controller.isLoading.value)
                          ? controller.previousPage
                          : null,
                      onLongPress: () => Toast.show(context, 'Previous Page'),
                      icon: Icon(Icons.arrow_circle_left),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        controller: TextEditingController(
                          text: controller.pageInput.value,
                        ),
                        onSubmitted: (value) {
                          controller.goToPage(value);
                        },
                        onChanged: (value) =>
                            controller.pageInput.value = value,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          (controller.hasNextPage.value &&
                              !controller.isLoading.value)
                          ? controller.nextPage
                          : null,
                      onLongPress: () => Toast.show(context, 'Next Page'),
                      icon: Icon(Icons.arrow_circle_right),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
