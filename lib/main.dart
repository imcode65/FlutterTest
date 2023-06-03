import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Github Search Home Page'),
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

  Future<List<dynamic>> searchRepositories(String keywords) async {
    String url = "https://api.github.com/search/repositories?q=$keywords";
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> json = jsonDecode(response.body);
    return json['items'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(
                labelText: 'Keywords',
                hintText: 'Enter some keywords',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String keywords = _textEditingController.text;
                setState(() {
                  _futureRepositories = searchRepositories(keywords);
                });
              },
              child: Text('Search'),
            ),
            SizedBox(height: 16),
            _buildRepositoriesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRepositoriesList() {
    return Expanded(
      child: _futureRepositories == null
          ? Container()
          : FutureBuilder<List<dynamic>>(
              future: _futureRepositories,
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  _repositories = snapshot.data!;
                  return ListView.builder(
                    itemCount: _repositories.length,
                    itemBuilder: (context, index) {
                      final repository = _repositories[index];
                      return ListTile(
                        title: Text(repository["full_name"]),
                        subtitle:
                            Text(repository["description"] ?? "No description"),
                      );
                    },
                  );
                }
              },
            ),
    );
  }
}
