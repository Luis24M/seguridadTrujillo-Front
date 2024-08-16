import 'package:flutter/material.dart';
import 'package:maps/ui/pages/auth/login_page.dart';
import 'package:maps/ui/pages/auth/register_page.dart';
import 'package:maps/ui/pages/home/home_page.dart';
import 'package:maps/ui/pages/incident/incidents_page.dart';
import 'package:maps/ui/pages/splash/splash_page.dart';
import 'package:maps/ui/request_permission/request_permission_page.dart';
import 'package:maps/ui/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes() {
  return {
    Routes.SPLASH: (_)=>const SplashPage(),
    Routes.LOGIN: (_)=> const LoginPage(),
    Routes.REGISTER: (_)=>const RegisterPage(),
    Routes.PERMISSIONS: (_)=>const RequestPermissionPage(), 
    Routes.HOME: (_)=>const HomePage(),
    Routes.ICIDENTFORM: (_)=> const IncidentsMapPage(),
    
  };
}