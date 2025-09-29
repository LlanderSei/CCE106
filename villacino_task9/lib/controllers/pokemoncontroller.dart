import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get/get.dart';
import 'package:villacino_task9/models/pokemon.dart';
import 'dart:async';

class PokemonController extends GetxController {
  var pokemonList = <Pokemon>[].obs;
  var isLoading = false.obs;
  var page = 1.obs;
  final int limit = 20;
  var hasNextPage = true.obs;
  var pageInput = ''.obs;
  Map<int, Map<String, dynamic>> cache =
      {}; // Cache for pages: {page: {'list': List<Pokemon>, 'hasNext': bool}}
  Map<String, Pokemon> pokemonCache =
      {}; // Cache for individual Pokémon by name
  var allPokemon = <Map<String, dynamic>>[].obs; // List of {'name': , 'url': }
  var searchQuery = ''.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchAllPokemon();
    fetchPokemons();
    pageInput.value = page.value.toString();
  }

  @override
  void onReady() {
    super.onReady();
    searchQuery.listen((query) {
      _debounce?.cancel();
      if (query.isEmpty) {
        page.value = 1;
        fetchPokemons();
      } else {
        _debounce = Timer(Duration(milliseconds: 500), () {
          fetchPokemons();
        });
      }
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> fetchAllPokemon() async {
    try {
      final countResponse = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1'),
      );
      if (countResponse.statusCode == 200) {
        final countData = jsonDecode(countResponse.body);
        final int count = countData['count'];

        final response = await http.get(
          Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$count'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          allPokemon.value = List<Map<String, dynamic>>.from(
            data['results'],
          ).where((p) => p['name'] != null && p['url'] != null).toList();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load all Pokémon names: $e');
    }
  }

  Future<void> fetchPokemons() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      if (searchQuery.value.isEmpty) {
        // Normal pagination mode
        if (cache.containsKey(page.value)) {
          var cached = cache[page.value]!;
          pokemonList.value = cached['list'];
          hasNextPage.value = cached['hasNext'];
        } else {
          final response = await http.get(
            Uri.parse(
              'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=${(page.value - 1) * limit}',
            ),
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final List results = data['results']
                .where((p) => p['name'] != null && p['url'] != null)
                .toList();
            bool hn = data['next'] != null;

            List<Pokemon> newList = [];
            for (var pokemon in results) {
              final detailResponse = await http.get(Uri.parse(pokemon['url']));
              if (detailResponse.statusCode == 200) {
                final detailData = jsonDecode(detailResponse.body);
                var poke = Pokemon.fromJson(detailData);
                if (poke.name != null) {
                  newList.add(poke);
                  pokemonCache[poke.name!] = poke;
                }
              }
            }
            pokemonList.value = newList;
            hasNextPage.value = hn;
            cache[page.value] = {'list': newList, 'hasNext': hn};
          } else {
            throw Get.snackbar('Error', 'Failed to load Pokémon data');
          }
        }
      } else {
        // Search mode
        final lowerQuery = searchQuery.value.toLowerCase();
        var matching = allPokemon
            .where(
              (p) =>
                  p['name'] != null &&
                  p['name'].toLowerCase().contains(lowerQuery),
            )
            .toList();
        matching.sort((a, b) => a['name'].compareTo(b['name']));

        List<Pokemon> newList = [];
        for (var p in matching.take(limit)) {
          final name = p['name'] as String? ?? 'unknown';
          if (pokemonCache.containsKey(name)) {
            newList.add(pokemonCache[name]!);
          } else {
            final detailResponse = await http.get(Uri.parse(p['url']));
            if (detailResponse.statusCode == 200) {
              final detailData = jsonDecode(detailResponse.body);
              var poke = Pokemon.fromJson(detailData);
              if (poke.name != null) {
                newList.add(poke);
                pokemonCache[poke.name!] = poke;
              }
            }
          }
        }
        pokemonList.value = newList;
        hasNextPage.value = matching.length > limit;
      }
      pageInput.value = page.value.toString();
    } catch (e) {
      throw Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void goToPage(String input) {
    if (input.isEmpty || isLoading.value) return;
    final int? newPage = int.tryParse(input);
    if (newPage != null && newPage >= 1) {
      page.value = newPage;
      fetchPokemons();
    } else {
      Get.snackbar('Error', 'Invalid page number');
      pageInput.value = page.value.toString();
    }
  }

  void previousPage() {
    if (page.value > 1) {
      page.value--;
      fetchPokemons();
    }
  }

  void nextPage() {
    if (hasNextPage.value) {
      page.value++;
      fetchPokemons();
    }
  }
}
