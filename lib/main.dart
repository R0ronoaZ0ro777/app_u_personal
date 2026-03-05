import 'package:flutter/material.dart';
import 'screen/horarios.dart';
import 'screen/promNotas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Colors.tealAccent.shade200,
          secondary: Colors.tealAccent.shade100,
        ),
        primaryColor: Colors.tealAccent.shade200,
        scaffoldBackgroundColor: const Color(0xFF0F1720), // very dark blue-gray
        cardColor: const Color(0xFF111827), // slightly lighter for cards
        dialogBackgroundColor: const Color(0xFF0B1220),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B1220),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF14B8A6),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF071018),
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 6, 15),
              foregroundColor: Colors.white,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                'App Principal',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        crossAxisCount: 2,
        shrinkWrap: true, // ajusta el tamaño real para evitar errores de desbordamientos
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ActionCard(
            icon: Icons.schedule,
            label: 'Horario de clases',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Horarios()));
            },
          ),
          _ActionCard(
            icon: Icons.book,
            label: 'Promedio de Notas',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PromNotas()));
            },
          ),
          _ActionCard(
            icon: Icons.assignment,
            label: 'Accion 3',
            onTap: () {
              // Navegar a la pantalla de accion 3
            },
          ),
          _ActionCard(
            icon: Icons.settings,
            label: 'Accion 4',
            onTap: () {
              // Navegar a la pantalla de accion 4
            },
          ),
        ]
      ),
    );
  }
}
class _ActionCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  const _ActionCard({required this.label, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 80),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 32),
                  const SizedBox(height: 8),
                  Text(label, textAlign: TextAlign.center),
                ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}