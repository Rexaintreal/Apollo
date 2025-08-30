import 'package:flutter/material.dart';
import 'package:apollo/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'package:apollo/themes/theme_provider.dart';
import 'components/dancing_cat.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      builder: (context, child) {
        return Stack(
          children: [
            child!,          
            const DancingCat(),
          ],
        );
      },
      home: const HomePage(),
    );
  }
}
