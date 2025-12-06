import 'package:flutter/material.dart';
import 'package:grade_project/home_page.dart';
import 'package:grade_project/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';

/// The main entry point for the Masareef application.
///
/// This function ensures that the Flutter bindings are initialized and then runs
/// the [MyApp] widget, which is the root of the application.
void main() {
  // Ensures that the Flutter binding is initialized before running the app.
  // This is necessary to use platform channels to call native code, which
  // is done by some plugins.
  WidgetsFlutterBinding.ensureInitialized();
  // Runs the root widget of the application.
  runApp(const MyApp());
}

/// The root widget of the Masareef application.
///
/// This widget is a [StatefulWidget] that manages the application's theme and
/// locale. It uses a [GlobalKey] to allow descendant widgets to access its
/// state and change the application's language.
class MyApp extends StatefulWidget {
  /// Creates the root widget of the application.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();

  /// A static method to allow descendant widgets to access [MyAppState].
  ///
  /// This method is used to find the [MyAppState] in the widget tree, which
  /// allows descendant widgets to call methods like [changeLanguage].
  ///
  /// Example:
  /// ```dart
  /// MyApp.of(context)?.changeLanguage(const Locale('ar', ''));
  /// ```
  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();
}

/// The state for the [MyApp] widget.
///
/// This class handles the logic for changing the application's locale and
/// persisting the user's language preference.
class MyAppState extends State<MyApp> {
  // The current locale of the application. Defaults to English.
  Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    // Loads the saved locale when the app starts.
    _loadLocale();
  }

  /// Loads the locale from [SharedPreferences].
  ///
  /// This method retrieves the saved language code from shared preferences and
  /// updates the application's locale. If no language code is found, it
  /// defaults to English.
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('languageCode') ?? 'en';
    setState(() {
      _locale = Locale(languageCode, '');
    });
  }

  /// Changes the application's language and saves the preference to [SharedPreferences].
  ///
  /// This method is called by descendant widgets to change the application's
  /// language. It takes a [Locale] as input and updates the state, which
  /// rebuilds the widget tree with the new language.
  Future<void> changeLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // MaterialApp is the root of the app's widget tree.
    // It provides many of the basic features that applications need, such as
    // routing, theming, and localization.
    return MaterialApp(
      // Hides the debug banner in the top-right corner of the screen.
      debugShowCheckedModeBanner: false,
      // Hides the semantics debugger overlay, which is used for inspecting the
      // semantics of the widget tree.
      showSemanticsDebugger: false,
      // Hides the performance overlay, which displays performance information
      // on top of the application.
      showPerformanceOverlay: false,
      // The title of the application, which is used by the operating system
      // to identify the app.
      title: 'Masareef',
      // Sets the global theme for the application, which defines the colors,
      // fonts, and other visual properties of the widgets.
      theme: appTheme,
      // Sets the current locale for the application, which determines the
      // language and formatting of the text and other elements.
      locale: _locale,
      // Provides delegates for internationalization, which are responsible for
      // loading the localized strings and other resources.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Defines the supported locales for the application.
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ar', ''), // Arabic, no country code
      ],
      // The default route of the application, which is the widget that is
      // displayed when the app is first launched.
      home: const HomePage(),
    );
  }
}
