import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Github Search Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  List<dynamic> _repositories = [];
  Future<List<dynamic>>? _futureRepositories;
  String? _searchInputError;

  Future<List<dynamic>> searchRepositories(String keywords) async {
    String url = "https://api.github.com/search/repositories?q=$keywords";
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> json = jsonDecode(response.body);
    return json['items'];
  }

  // Input Validation
  void _validateInput(String input) {
    if (input.trim().isEmpty) {
      setState(() {
        _searchInputError = "Please enter some keywords";
      });
    } else {
      setState(() {
        _searchInputError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textEditingController,
              onChanged: (input) => _validateInput(input),
              decoration: InputDecoration(
                labelText: 'Keywords',
                hintText: 'Enter some keywords',
                errorText: _searchInputError,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String keywords = _textEditingController.text;
                _validateInput(keywords);
                if (keywords.trim().isNotEmpty) {
                  setState(() {
                    _futureRepositories = searchRepositories(keywords);
                  });
                }
              },
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),
            _buildRepositoriesList(),
          ],
        ),
      ),
    );
  }

  // Repository List
  Widget _buildRepositoriesList() {
    return Expanded(
      child: _futureRepositories == null
          ? Container()
          : FutureBuilder<List<dynamic>>(
              future: _futureRepositories,
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  _repositories = snapshot.data!;
                  if (_repositories.isEmpty) {
                    return const Center(child: Text("Not Found Repository"));
                  } else {
                    return ListView.builder(
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        final repository = _repositories[index];
                        return Card(
                          // Add Card widget
                          elevation: 4, // Adjust elevation for shadow
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 0),
                          child: ListTile(
                            title: Text(repository["full_name"]),
                            subtitle: Text(
                                repository["description"] ?? "No description"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RepositoryDetails(repository: repository),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
    );
  }
}

// Repository Detail
class RepositoryDetails extends StatelessWidget {
  final Map<String, dynamic> repository;

  const RepositoryDetails({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    String? language = repository['language'];
    int stars = repository['stargazers_count'];
    int watchers = repository['watchers_count'];
    int forks = repository['forks'];
    int issues = repository['open_issues'];
    String ownerIconUrl = repository['owner']['avatar_url'];

    return Scaffold(
      appBar: AppBar(title: const Text("Repository Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${repository['full_name']}",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CircleAvatar(
                backgroundImage: NetworkImage(ownerIconUrl), radius: 36),
            const SizedBox(height: 8),
            language != null ? Text('Language: $language') : Container(),
            const SizedBox(height: 8),
            Text('Stars: $stars'),
            const SizedBox(height: 8),
            Text('Watchers: $watchers'),
            const SizedBox(height: 8),
            Text('Forks: $forks'),
            const SizedBox(height: 8),
            Text('Issues: $issues'),
          ],
        ),
      ),
    );
  }
}
