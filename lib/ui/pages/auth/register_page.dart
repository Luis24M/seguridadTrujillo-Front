import 'package:flutter/material.dart';
import 'package:maps/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre, _apellido, _email, _contrasena, _telefono;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) => _nombre = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Apellido'),
                onSaved: (value) => _apellido = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                onSaved: (value) => _telefono = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onSaved: (value) => _contrasena = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Llamada al método de registro
                    try {
                      await AuthService().registerUser(
                        _nombre!,
                        _apellido!,
                        _email!,
                        _contrasena!,
                        _telefono!,
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      // Mostrar un mensaje de error si falla
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error en el registro: $e')),
                      );
                    }
                  }
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
