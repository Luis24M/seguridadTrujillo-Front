import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class SplashPageController extends ChangeNotifier {
  final Permission _permission;
  String? routeName;

  SplashPageController(this._permission);

  Future<void> checkPermission() async {
    // Verificar permisos
    if(kIsWeb){
      routeName = '/home';
      notifyListeners();
      return;
    }

    if (await _permission.isGranted) {
      // Verificar si hay un usuario autenticado en Firebase
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        print('Usuario autenticado: ${user.email}');
        routeName = '/home';
      } else {
        print('Ningún usuario autenticado');
        routeName = '/login';
      }

    } else {
      // Si los permisos no están otorgados, redirigir a la página de permisos
      routeName = '/permissions';
    }
    // Notificar a los listeners sobre el cambio de ruta
    notifyListeners();
  }
}
