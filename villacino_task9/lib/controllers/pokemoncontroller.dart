import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';

class PokemonController extends GetxController {
  var pokemonList = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var page = 1.obs;
  final int limit = 20;
  var hasNextPage = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    if (!hasNextPage.value || isLoading.value) return;

    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=${(page.value - 1) * limit}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];
        hasNextPage.value = data['next'] != null;

        for (var pokemon in results) {
          final detailResponse = await http.get(Uri.parse(pokemon['url']));
          if (detailResponse.statusCode == 200) {
            final detailData = jsonDecode(detailResponse.body);
            pokemonList.add({
              'name': detailData['name'],
              'image': detailData['sprites']['front_default'],
              'types': detailData['types'].map((t) => t['type']['name']).toList(),
              'stats': detailData['stats'].map((s) => {
                    'name': s['stat']['name'],
                    'value': s['base_stat'],
                  }).toList(),
            });
          }
        }
        page.value++;
      } else {
        Get.snackbar('Error', 'Failed to load Pokémon data');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}