import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Esta clase representa una pantalla de prueba de conexión a Supabase.
class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => TestConnectionScreenState();
}

// Esta pantalla permite probar la conexión a Supabase
// e insertar un dato de prueba en la tabla 'test_connection'.
class TestConnectionScreenState extends State<TestConnectionScreen> {
  String status = 'Presiona el botón para probar la conexión';

  Future<void> insertTestData() async {
    setState(() {
      status = '⌛ Insertando...';
    });

    try {
      await Supabase.instance.client
          .from('test_connection')
          .insert({'name': 'Dato desde botón'});

      setState(() {
        status = '✅ Conexión exitosa: Dato insertado.';
      });
    } catch (e) {
      setState(() {
        status = '❌ Error al insertar: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba Supabase')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: insertTestData,
                child: const Text('Probar conexión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
