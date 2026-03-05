import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
        backgroundColor: Colors.blueAccent,
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
              // Navegar a la pantalla de horario de clases
            },
          ),
          _ActionCard(
            icon: Icons.book,
            label: 'Accion 2',
            onTap: () {
              // Navegar a la pantalla de accion 2
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