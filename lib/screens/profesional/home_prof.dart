// 📁 lib/screens/profesional/home_profesional_screen.dart
import 'package:flutter/material.dart';

class HomeProfesionalScreen extends StatelessWidget {
  const HomeProfesionalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_ProfesionalOption> opciones = [
      _ProfesionalOption("👥 Pacientes", Icons.group, '/pacientes'),
      _ProfesionalOption("📈 Dashboard", Icons.insights, '/dashboard_profesional'),
      _ProfesionalOption("📋 Rutinas", Icons.fitness_center, '/rutinas_profesional'),
      _ProfesionalOption("👤 Perfil", Icons.person, '/perfil'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inicio Profesional"),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: opciones.map((op) => _OptionCard(op)).toList(),
      ),
    );
  }
}

class _ProfesionalOption {
  final String title;
  final IconData icon;
  final String route;
  const _ProfesionalOption(this.title, this.icon, this.route);
}

class _OptionCard extends StatelessWidget {
  final _ProfesionalOption option;
  const _OptionCard(this.option);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, option.route),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon, size: 48, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 12),
            Text(
              option.title,
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


// 🗺️ Rutas recomendadas a registrar en main.dart:
// '/profesional': (context) => const HomeProfesionalScreen(),
// '/pacientes': (context) => const PlaceholderScreen(title: 'Pacientes'),
// '/dashboard_profesional': (context) => const PlaceholderScreen(title: 'Dashboard Profesional'),
// '/rutinas_profesional': (context) => const PlaceholderScreen(title: 'Rutinas Profesionales')
