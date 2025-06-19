import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'paciente';
  String? _error;

  Future<void> _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || _selectedRole.isEmpty) {
      setState(() => _error = 'Todos los campos son obligatorios');
      return;
    }

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        await Supabase.instance.client.from('users').insert({
          'id': res.user!.id,
          'email': email,
          'role': _selectedRole,
          'name': null,
        });

        if (!mounted) return;
        if (res.user!.role == 'paciente') {
          Navigator.pushReplacementNamed(context, '/homepatient');
        } else if (res.user!.role == 'profesional') {
          // Asumiendo que el rol 'profesional' redirige a la pantalla de inicio general
          Navigator.pushReplacementNamed(context, '/homeprofessional');
        }
      }
    } catch (e) {
      setState(() => _error = '❌ ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text('Registro en Eirix', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 20),
            Text('Rol', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              dropdownColor: theme.colorScheme.surface,
              style: theme.textTheme.bodyMedium,
              items: const [
                DropdownMenuItem(value: 'paciente', child: Text('Paciente')),
                DropdownMenuItem(value: 'profesional', child: Text('Profesional')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color(0xFF1A1A1A),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _signup,
              child: const Text('Registrarme'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('¿Ya tienes cuenta? Inicia sesión',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            )
          ],
        ),
      ),
    );
  }
}
