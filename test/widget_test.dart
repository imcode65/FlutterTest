// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter2/main.dart';
import 'package:flutter2/repository_service.dart';

class MockClient extends Mock implements http.Client {}

@GenerateMocks([http.Client])
void main() {
  testWidgets('Testing empty input validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    Finder textFieldFinder = find.byType(TextField);
    Finder buttonFinder = find.byType(ElevatedButton);

    await tester.enterText(textFieldFinder, '');
    await tester.tap(buttonFinder);
    await tester.pump();

    String errorText = 'Please enter some keywords';
    expect(find.text(errorText), findsOneWidget);
  });

  test('Testing searchRepositories function', () async {
    final client = MockClient();
    const sampleResponse = '''
    {
      "items": [
        {
          "id": 1,
          "full_name": "repository1",
          "description": "description 1"
        },
        {
          "id": 2,
          "full_name": "repository2",
          "description": "description 2"
        }
      ]
    }
    ''';

    // when(client.get(
    //         Uri.parse('https://api.github.com/search/repositories?q=flutter')))
    //     .thenAnswer((_) async => http.Response(sampleResponse, 200));

    when(client.get(
            Uri.parse('https://api.github.com/search/repositories?q=flutter')))
        .thenAnswer((_) async => http.Response(sampleResponse, 200));

    List<dynamic> repositories = await searchRepositories('flutter', client);

    expect(repositories.length, 2);
    expect(repositories[0]['full_name'], 'repository1');
  });
}
