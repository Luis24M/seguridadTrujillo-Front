import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ReportMapPage extends StatefulWidget {
  const ReportMapPage({super.key});

  @override
  ReportMapPageState createState() => ReportMapPageState();
}

class ReportMapPageState extends State<ReportMapPage> {
  final _formKey = GlobalKey<FormState>();
  String descripcion = '';
  String direccion = '';
  LatLng selectedLocation =
      const LatLng(-8.112, -79.03); // Ubicación inicial (Trujillo)

  void _onMapTapped(LatLng location) {
    setState(() {
      selectedLocation = location;
    });
  }

  final Set<Polygon> _trujilloPolygon = {
    Polygon(
      polygonId: const PolygonId('trujillo'),
      points: const [
        LatLng(-8.150677, -79.025044),
        LatLng(-8.149532, -79.023273),
        LatLng(-8.148547, -79.019770),
        LatLng(-8.145782, -79.016956),
        LatLng(-8.143253, -79.013326),
        LatLng(-8.141167, -79.008011),
        LatLng(-8.136253, -79.002627),
        LatLng(-8.132211, -78.999380),
        LatLng(-8.127284, -78.996467),
        LatLng(-8.127069, -78.989969),
        LatLng(-8.127529, -78.980012),
        LatLng(-8.112497, -78.994303),
        LatLng(-8.107110, -78.994971),
        LatLng(-8.103010, -79.001802),
        LatLng(-8.101168, -78.998055),
        LatLng(-8.096358, -78.995685),
        LatLng(-8.093481, -78.996246),
        LatLng(-8.092729, -78.994132),
        LatLng(-8.088847, -78.991692),
        LatLng(-8.088985, -78.995485),
        LatLng(-8.088341, -78.998193),
        LatLng(-8.087154, -79.002266),
        LatLng(-8.087475, -79.004688),
        LatLng(-8.085716, -79.015170),
        LatLng(-8.087451, -79.018207),
        LatLng(-8.088327, -79.021930),
        LatLng(-8.088537, -79.028435),
        LatLng(-8.086972, -79.034010),
        LatLng(-8.085879, -79.042170),
        LatLng(-8.083351, -79.049183),
        LatLng(-8.082787, -79.054937),
        LatLng(-8.090595, -79.057074),
        LatLng(-8.090631, -79.053857),
        LatLng(-8.104484, -79.060162),
        LatLng(-8.105967, -79.055024),
        LatLng(-8.118505, -79.058009),
        LatLng(-8.121774, -79.048866),
        LatLng(-8.116462, -79.044058),
        LatLng(-8.119290, -79.040736),
        LatLng(-8.119667, -79.040791),
        LatLng(-8.125749, -79.045828),
        LatLng(-8.128692, -79.042372),
        LatLng(-8.127529, -79.041347),
        LatLng(-8.128190, -79.040516),
        LatLng(-8.130016, -79.035548),
        LatLng(-8.132358, -79.032947),
        LatLng(-8.137220, -79.027442),
        LatLng(-8.148910, -79.026305),
        LatLng(-8.150722, -79.025550),
        LatLng(-8.143212, -79.013105),
      ],
      strokeWidth: 2,
      strokeColor: const Color.fromARGB(219, 232, 55, 55),
      fillColor: const Color.fromARGB(146, 33, 219, 243).withOpacity(0.1),
    ),
  };

  Future<void> reportIncident() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Obtener el token de autenticación de Firebase
      User? user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado')),
        );
        return;
      }
      final url = Uri.parse('http://localhost:3000/incidentes/reportar-incidente');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Token de autenticación
        },
        body: jsonEncode({
          'uid': user!.uid,
          'id_tipo_incidente': tiposIncidentes.indexOf(tipoIncidente!) + 1,
          'latitud': selectedLocation.latitude,
          'longitud': selectedLocation.longitude,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidente reportado exitosamente')),
        );

        // Limpiar los campos del formulario
        _formKey.currentState!.reset();
        setState(() {
          tipoIncidente = null;
          descripcion = '';
          selectedLocation = const LatLng(-8.112, -79.03); // Reiniciar la ubicación a la inicial
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al reportar el incidente')),
        );
      }
    }
  }


  String? tipoIncidente;
  List<String> tiposIncidentes = ['Robo', 'Secuestro', 'Incendio', 'Asesinato'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onTap: _onMapTapped,
              polygons: _trujilloPolygon,
              initialCameraPosition: CameraPosition(
                target: selectedLocation,
                zoom: 12.0,
              ),
              myLocationEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: selectedLocation,
                ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Tipo de Incidente'),
                    value: tipoIncidente,
                    items: tiposIncidentes.map((String tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tipoIncidente = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Por favor selecciona un tipo' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    onSaved: (value) => descripcion = value ?? '',
                    validator: (value) =>
                        value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: reportIncident,
                    child: const Text('Reportar Incidente'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
