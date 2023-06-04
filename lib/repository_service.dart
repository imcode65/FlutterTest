import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> searchRepositories(String keywords,
    [http.Client? httpClient]) async {
  final String url = "https://api.github.com/search/repositories?q=$keywords";
  final http.Client client = httpClient ?? http.Client();

  final http.Response response = await client.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> json = jsonDecode(response.body);
    return json['items'] as List<dynamic>;
  } else {
    throw Exception('Failed to load repositories');
  }
}
