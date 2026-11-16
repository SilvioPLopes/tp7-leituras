// Integrante: Silvio Lopes — TP7: App de Organização de Leituras.
import 'package:flutter/material.dart';

import 'pages/lista_livros_page.dart';
import 'services/livros_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LeiturasApp());
}

class LeiturasApp extends StatelessWidget {
  const LeiturasApp({super.key, this.storage});
  final LivrosStorage? storage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Organização de Leituras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF65528A)),
        scaffoldBackgroundColor: const Color(0xFFFAF8F4),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: ListaLivrosPage(storage: storage ?? LivrosStorage()),
    );
  }
}
