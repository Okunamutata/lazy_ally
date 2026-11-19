import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:material_ui/material_ui.dart';
import 'package:lazy_ally/lazy_ally.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lazy_ally_example/custom_styles/custom_schemes.dart';
import 'package:lazy_ally_example/custom_styles/custom_themes.dart';
import 'package:lazy_ally_example/widgets/motion_examples.dart';

const String _cacheKey = 'lazy_ally_cache';

/// `LazyAlly.loadLazyAllyPreferences` — reads back whatever `_saveCache` last wrote, or
/// `null` on first launch. LazyAlly does not care *how* this reads; here
/// that's `shared_preferences` plus a plain `jsonDecode`, but a file, a
/// backend call, or a different local-storage package would work exactly
/// the same way from LazyAlly's side.
// Future<LazyAllyPreferences?> _loadLazyAllyPreferences() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   final String? raw = prefs.getString(_cacheKey);
//   if (raw == null) return null;
//   return LazyAllyPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
// }

Future<LazyAllyPreferences?> getLazyAllyPreferences() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? raw = prefs.getString(_cacheKey);
  if (raw == null) return null;
  return LazyAllyPreferences.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

/// `LazyAlly.onLazyAllyPreferencesChanged` — the counterpart to `_loadLazyAllyPreferences`. Called with
/// a fresh snapshot on every cache-worthy change; not debounced, since
/// `shared_preferences` writes are cheap enough here that it doesn't matter
/// — an app backed by something more expensive (a network call) would want
/// to debounce inside this function itself.
Future<void> _saveCache(LazyAllyPreferences cache) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(_cacheKey, jsonEncode(cache.toJson()));
}

void main() async => runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();
    final LazyAllyPreferences? prefs = await getLazyAllyPreferences();

    runApp(
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
        textScaleMin: 0.85,
        textScaleMax: 1.8,

        // region Optional — everything below has a working default
        //if your using a future at instead, use
        //loadLazyAllyPreferences: _loadLazyAllyPreferences,
        loadLazyAllyPreferences: () => prefs,

        onLazyAllyPreferencesChanged: _saveCache,
        customColorSchemes: exampleCustomColorSchemes,
        customThemes: exampleCustomThemes,
        // endregion
        child: const ExampleApp(),
      ),
    );
  },
  (Object error, StackTrace stackTrace) {
    log('$error :\n${stackTrace.toString()} ');
  },
);

/// This is the pattern LazyAlly is built around: `MyApp`'s `context` is
/// already a descendant of the `LazyAllyProvider` installed by the `LazyAlly`
/// widget above, so `context.lazyAllyTheme` resolves correctly here.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LazyAlly example',
      theme: context.lazyAllyTheme,
      // reduceMotion is an advisory MediaQuery signal — the Flutter
      // framework's widgets (implicit animations, page transitions, ripples,
      // Switch/Checkbox toggles, and MaterialApp's own theme cross-fade
      // here) never check it themselves, only code that explicitly reads it
      // does (see motion_examples.dart). Suppressing each one you actually
      // use is the app's job; this is that job for the one MaterialApp
      // itself owns.
      themeAnimationDuration: context.lazyAlly.reduceMotion
          ? Duration.zero
          : kThemeAnimationDuration,
      home: const HomePage(),
    );
  }
}

/// A section heading that's also announced as a heading to assistive
/// technology (`Semantics(header: true)`), so a screen-reader user can jump
/// between "Appearance", "Custom theme", etc. the same way a sighted user
/// scans the page visually — plain [Text] alone doesn't carry that.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LazyAlly example')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (_) => const LazyAllyPanel(),
        ),
        tooltip: 'Accessibility and display settings',
        child: const Icon(Icons.accessibility_new_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const MotionExamplesSection(),
          const SizedBox(height: 32),
          const _SectionHeading('Active theme colors'),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              for (final (String label, Color color) in <(String, Color)>[
                ('Primary', Theme.of(context).colorScheme.primary),
                ('Secondary', Theme.of(context).colorScheme.secondary),
                ('Tertiary', Theme.of(context).colorScheme.tertiary),
                ('Error', Theme.of(context).colorScheme.error),
              ])
                Expanded(
                  child: Column(
                    children: <Widget>[
                      ExcludeSemantics(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          color: color,
                        ),
                      ),
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),

          Divider(),
          const SizedBox(height: 32),
          const _SectionHeading('Multiple theme support'),
          const SizedBox(height: 8),
          LazyAllyCustomThemeSelector(
            itemBuilder:
                (
                  BuildContext context,
                  String? name,
                  bool selected,
                  VoidCallback onSelect,
                ) {
                  final String label = name == null
                      ? 'Default'
                      : '${name[0].toUpperCase()}${name.substring(1)}';
                  return FilterChip(
                    avatar: name == null
                        ? null
                        : const Icon(Icons.eco_outlined, size: 16),
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => onSelect(),
                  );
                },
          ),
          const SizedBox(height: 32),
          const _SectionHeading(
            'Multiple color scheme support\n(overrides color-blind above while selected)',
          ),
          const SizedBox(height: 8),
          LazyAllyCustomSchemeSelector(
            itemBuilder:
                (
                  BuildContext context,
                  String? name,
                  bool selected,
                  VoidCallback onSelect,
                ) {
                  final String label = name == null
                      ? 'Default'
                      : '${name[0].toUpperCase()}${name.substring(1)}';
                  return FilterChip(
                    avatar: name == null
                        ? null
                        : const Icon(Icons.palette_outlined, size: 16),
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => onSelect(),
                  );
                },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
