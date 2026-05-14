import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:locora/firebase_options.dart';
import 'package:locora/utils/cloudinary_config.dart';
import 'package:locora/utils/persistance.dart';
import 'package:locora/wrapper/auth_gate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  CloudinaryConfig.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Application());
}

class Application extends StatefulWidget {
  const Application({super.key});

  // ignore: library_private_types_in_public_api
  static _ApplicationState of(BuildContext context) {
    return context.findAncestorStateOfType<_ApplicationState>()!;
  }

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    final theme = await getTheme();

    setState(() {
      _isDarkMode = theme == 'dark';
    });
  }

  Future<void> toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });

    await saveTheme(value ? 'dark' : 'light');
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    final fThemeData = _isDarkMode
        ? FThemes.neutral.dark
        : FThemes.neutral.light;

    final theme =
        const {
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.fuchsia,
        }.contains(defaultTargetPlatform)
        ? fThemeData.touch
        : fThemeData.desktop;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      theme: theme.toApproximateMaterialTheme(),
      builder: (_, child) => FTheme(
        data: theme,
        child: FToaster(child: FTooltipGroup(child: child!)),
      ),
      home: const FScaffold(child: AuthGate()),
    );
  }
}
