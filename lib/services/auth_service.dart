import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://localhost:3000';

  // Método para registrar usuario
  Future<void> registerUser(String nombre, String apellido, String email, String contrasena, String telefono) async {
    try {
      // Enviar datos al backend para registrar en Firebase y MySQL
      final url = Uri.parse('http://localhost:3000/usuarios/registro');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'email': email,
          'contrasena': contrasena,
          'telefono': telefono,
        }),
      );

      if (response.statusCode == 201) {
        print('Usuario registrado exitosamente en el backend');
      } else {
        print('Error al registrar el usuario en el backend: ${response.body}');
      }
    } catch (e) {
      print('Error al registrar el usuario: $e');
    }
  }

  // Método para iniciar sesión


  Future<void> loginUser(String email, String contrasena) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      User? user = userCredential.user;

      if (user != null) {
        final url = Uri.parse('$baseUrl/login');
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${await user.getIdToken()}',
          },
          body: jsonEncode({
            'uid': user.uid,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['token'];  // Asumiendo que el backend devuelve un token

          // Guardar el token en SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          print('Usuario autenticado: ${data['nombre']}');
        } else {
          print('Error en el inicio de sesión: ${response.body}');
        }
      }
    } catch (e) {
      print('Error en el inicio de sesión: $e');
    }
  }

}