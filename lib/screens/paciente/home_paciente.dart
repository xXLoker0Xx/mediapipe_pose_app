import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

Future<bool> _confirmLogout(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Deseas cerrar sesión y salir de la app?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Sí'),
        ),
      ],
    ),
  );

  return shouldLogout ?? false;
}

class HomePacienteScreen extends StatelessWidget {
  const HomePacienteScreen({super.key});

  @override
  Widget build(BuildContext context) {


    final List<_HomeOption> opciones = [
      _HomeOption("📋 Historial", Icons.history, '/historial'),
      _HomeOption("📆 Rutinas", Icons.list_alt, '/rutinas'),
      _HomeOption("🧘 Ejercicio", Icons.fitness_center, '/camera'),
      _HomeOption("👤 Perfil", Icons.person, '/perfil'),
    ];
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async{
        if (didPop) return;

        final salir = await _confirmLogout(context);
        if (salir) {
          await Supabase.instance.client.auth.signOut();
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          centerTitle: true,
        ),
        body: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: opciones.map((op) => _OptionCard(op)).toList(),
        ),
      ),
    );

  }
}

class _HomeOption {
  final String title;
  final IconData icon;
  final String route;
  const _HomeOption(this.title, this.icon, this.route);
}

class _OptionCard extends StatelessWidget {
  final _HomeOption option;
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
              color: Theme.of(context).colorScheme.primary.withAlpha(76),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon, size: 48, color: Theme.of(context).colorScheme.primary),
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