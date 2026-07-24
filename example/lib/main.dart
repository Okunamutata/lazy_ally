import 'package:flutter/material.dart';
import 'package:lazy_ally/lazy_ally.dart';

void main() => runApp(
  LazyAlly(
    light: ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: Colors.teal,
      useMaterial3: true,
    ),
    dark: ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.teal,
      useMaterial3: true,
    ),
    extraDark: ThemeData(
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.teal,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
    ),
    // Reasonable defaults if omitted: min 0.85, max 1.6, seeded from the
    // OS text scaler on first build.
    textScaleMin: 0.85,
    textScaleMax: 1.8,
    child: const ExampleApp(),
  ),
);

/// This is the pattern LazyAlly is built around: `MyApp`'s `context` is
/// already a descendant of the `LazyAllyScope` installed by the `LazyAlly`
/// widget above, so `context.lazyAllyTheme` resolves correctly here.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LazyAlly example',
      theme: context.lazyAllyTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // A few "semantic" colors standing in for something like chart series or
  // status tags — exactly the kind of color cvdSafeColor is meant for, not
  // neutral chrome like backgrounds or surfaces.
  static const _seriesColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final ally = context.lazyAlly;

    return AnimatedBuilder(
      animation: ally,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('LazyAlly example')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Appearance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: kLazyAllyLight, label: Text('Light')),
                  ButtonSegment(value: kLazyAllyDark, label: Text('Dark')),
                  ButtonSegment(
                    value: kLazyAllyExtraDark,
                    label: Text('Extra dark'),
                  ),
                ],
                selected: {ally.mode},
                onSelectionChanged: (s) => ally.setMode(s.first),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Color-blind friendly'),
                subtitle: const Text('Okabe-Ito palette for the series below'),
                value: ally.colorBlind,
                onChanged: ally.setColorBlind,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 0; i < _seriesColors.length; i++)
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: ally.cvdSafeColor(_seriesColors[i], i),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Text scale — ${ally.textScaleFactor.toStringAsFixed(2)}x',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: ally.textScaleFactor,
                min: ally.textScaleMin,
                max: ally.textScaleMax,
                onChanged: ally.setTextScaleFactor,
              ),
              const SizedBox(height: 24),
              const Text(
                'This text respects the slider above via the MediaQuery '
                'LazyAlly applies around your whole app — no per-widget '
                'wiring required.',
              ),
            ],
          ),
        );
      },
    );
  }
}
