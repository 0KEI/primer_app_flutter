import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favlist = <WordPair>[];

  void getSiguiente() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFav() {
    if (favlist.contains(current)) {
      favlist.remove(current);
    } else {
      favlist.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Inicio')),
                NavigationRailDestination(
                    icon: Icon(Icons.favorite), label: Text('Favoritos')),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
                print("Selección: $value");
              },
            ),
          ),
          Expanded(
              child: Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: GeneratorPage(),
          )),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  final WordPair idea;

  const BigCard({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final TextStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          idea.asLowerCase,
          style: TextStyle,
          semanticsLabel: "${idea.first} ${idea.second}",
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var idea = appState.current;
    IconData icon;
    if (appState.favlist.contains(idea)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(idea: appState.current),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFav();
                },
                icon: Icon(icon),
                label: Text('Me gusta'),
              ),
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    print("Botón presionado!");
                    appState.getSiguiente();
                  },
                  child: Text("Siguiente")),
            ],
          )
        ],
      ),
    );
  }
}
