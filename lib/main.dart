import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
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
  var historial = <WordPair>[];

  GlobalKey? historialListKey;

  void getSiguiente() {
    historial.insert(0, current);
    var animatedList = historialListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFav({WordPair? idea}) {
    idea = idea ?? current;
    if (favlist.contains(idea)) {
      favlist.remove(idea);
    } else {
      favlist.add(idea);
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
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavPage();
        break;
      default:
        throw UnimplementedError(
            'No hay Widget disponible para: $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
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
              child: page,
            )),
          ],
        ),
      );
    });
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
          Expanded(
            flex: 3,
            child: HistorialListView(),
          ),
          SizedBox(
            height: 20,
          ),
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
          ),
          Spacer(
            flex: 2,
          )
        ],
      ),
    );
  }
}

class FavPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favlist.isEmpty) {
      return Center(
        child: Text("Aún no hay favoritos en la lista"),
      );
    } else {}

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Se han elegido ${appState.favlist.length} favoritos'),
        ),
        for (var idea in appState.favlist)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(idea.asLowerCase),
          )
      ],
    );
  }
}

class HistorialListView extends StatefulWidget {
  const HistorialListView({Key? key}) : super(key: key);

  @override
  State<HistorialListView> createState() => _HistorialListViewState();
}

class _HistorialListViewState extends State<HistorialListView> {
  final _key = GlobalKey();

  static const Gradient _maskinGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.historialListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds) => _maskinGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100.0),
        initialItemCount: appState.historial.length,
        itemBuilder: (context, index, animation) {
          final idea = appState.historial[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                  onPressed: () {
                    appState.toggleFav(idea: idea);
                  },
                  icon: appState.favlist.contains(idea)
                      ? Icon(
                          Icons.favorite,
                          size: 12,
                        )
                      : SizedBox(),
                  label: Text(
                    idea.asLowerCase,
                    semanticsLabel: idea.asPascalCase,
                  )),
            ),
          );
        },
      ),
    );
  }
}
