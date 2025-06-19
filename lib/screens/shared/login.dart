import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Email y contraseña son obligatorios.');
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _error = 'Email no válido.');
      return;
    }

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final data = await Supabase.instance.client
        .from('users')
        .select('role')
        .eq('id', res.user!.id)
        .single();

      if (!mounted) return;
      if (data['role'] == 'paciente') {
        Navigator.pushReplacementNamed(context, '/homepatient');
      } else if (data['role'] == 'profesional') {
        // Asumiendo que el rol 'profesional' redirige a la pantalla de inicio general
        Navigator.pushReplacementNamed(context, '/homeprofessional');
      }
    } catch (e) {
      setState(() => _error = '❌ Credenciales incorrectas o usuario no existe.');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Eirix', style: theme.textTheme.headlineLarge),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Entrar'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text('¿No tienes cuenta? Regístrate',
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            )
          ],
        ),
      ),
    );
  }
}
